using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CyberLearnHub
{
    public partial class ManageLabs : AdminBasePage
    {
        private static readonly string[] BlockedExtensions =
            { ".exe", ".bat", ".sh", ".ps1", ".cmd", ".msi", ".dll" };

        private string connStr = ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadLabsGrid();

                string editId = Request.QueryString["edit"];
                if (!string.IsNullOrEmpty(editId))
                {
                    int id;
                    if (int.TryParse(editId, out id) && id > 0)
                    {
                        LoadLabForEdit(id);
                        bool isDraft = Request.QueryString["draft"] == "1";
                        if (isDraft)
                        {
                            // Clear the placeholder title so user fills in the real one
                            txtTitle.Text = "";
                            litFormTitle.Text = "New Lab";
                            ShowStatus("Draft created. Fill in the details, upload materials, then click Save Lab.", true);
                        }
                    }
                }
            }
        }

        // ── Grid ────────────────────────────────────────────────────────────────

        private void LoadLabsGrid()
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT LabId, Title, Difficulty, Points, IsActive FROM dbo.Labs WHERE Title <> '(Draft)' ORDER BY LabId", conn))
            {
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            gvLabs.DataSource = dt;
            gvLabs.DataBind();
        }

        protected void gvLabs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int labId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditLab")
                LoadLabForEdit(labId);
            else if (e.CommandName == "DeleteLab")
                DeleteLab(labId);
        }

        // ── Lab form ────────────────────────────────────────────────────────────

        protected void btnShowAddForm_Click(object sender, EventArgs e)
        {
            // Create a draft lab immediately so we have a LabId for file uploads
            int newLabId;
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.Labs (Title, Description, TargetInfo, FlagHash, Points, Difficulty, IsActive, CreatedDate, CreatedBy)
                VALUES (@Title, @Description, @TargetInfo, @FlagHash, @Points, @Difficulty, @IsActive, GETDATE(), @CreatedBy);
                SELECT SCOPE_IDENTITY();", conn))
            {
                cmd.Parameters.AddWithValue("@Title",       "(Draft)");
                cmd.Parameters.AddWithValue("@Description", "");
                cmd.Parameters.AddWithValue("@TargetInfo",  "");
                cmd.Parameters.AddWithValue("@FlagHash",    ComputeSha256(Guid.NewGuid().ToString()));
                cmd.Parameters.AddWithValue("@Points",      10);
                cmd.Parameters.AddWithValue("@Difficulty",  "Easy");
                cmd.Parameters.AddWithValue("@IsActive",    false);
                cmd.Parameters.AddWithValue("@CreatedBy",   Convert.ToInt32(Session["UserID"]));
                conn.Open();
                newLabId = Convert.ToInt32(cmd.ExecuteScalar());
            }

            Response.Redirect("~/Admin/ManageLabs.aspx?edit=" + newLabId + "&draft=1");
        }

        protected void btnCancelForm_Click(object sender, EventArgs e)
        {
            // If cancelling a draft, silently delete it
            int labId = Convert.ToInt32(hdnLabId.Value);
            if (labId > 0 && IsDraftLab(labId))
                DeleteLabData(labId);

            pnlForm.Visible = false;
            ClearForm();
            LoadLabsGrid();
        }

        private void ClearForm()
        {
            hdnLabId.Value               = "0";
            txtTitle.Text                = "";
            txtDescription.Text          = "";
            txtTargetInfo.Text           = "";
            txtFlag.Text                 = "";
            txtPoints.Text               = "10";
            ddlDifficulty.SelectedValue  = "Easy";
            chkIsActive.Checked          = true;
            pnlMaterialsList.Visible     = false;
            pnlUploadRow.Visible         = false;
        }

        private void LoadLabForEdit(int labId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT LabId, Title, Description, TargetInfo, Points, Difficulty, IsActive FROM dbo.Labs WHERE LabId = @LabId",
                conn))
            {
                cmd.Parameters.AddWithValue("@LabId", labId);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        hdnLabId.Value              = r["LabId"].ToString();
                        txtTitle.Text               = r["Title"].ToString();
                        txtDescription.Text         = r["Description"].ToString();
                        txtTargetInfo.Text          = r["TargetInfo"] == DBNull.Value ? "" : r["TargetInfo"].ToString();
                        txtPoints.Text              = r["Points"].ToString();
                        ddlDifficulty.SelectedValue = r["Difficulty"].ToString();
                        chkIsActive.Checked         = Convert.ToBoolean(r["IsActive"]);
                        txtFlag.Text                = "";
                    }
                }
            }

            litFormTitle.Text        = "Edit Lab";
            lblFlagHint.Visible      = true;
            pnlMaterialsList.Visible = true;
            pnlUploadRow.Visible     = true;
            pnlForm.Visible          = true;

            LoadMaterials(labId);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int    labId       = Convert.ToInt32(hdnLabId.Value);
            string title       = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            string targetInfo  = txtTargetInfo.Text.Trim();
            string flagPlain   = txtFlag.Text.Trim();
            bool   isActive    = chkIsActive.Checked;
            string difficulty  = ddlDifficulty.SelectedValue;

            int points;
            if (!int.TryParse(txtPoints.Text.Trim(), out points))
            {
                ShowStatus("Points must be a valid number.", false);
                return;
            }

            if (string.IsNullOrEmpty(title))
            {
                ShowStatus("Title is required.", false);
                return;
            }

            // Draft labs have a random placeholder flag — require a real flag before saving
            if (string.IsNullOrEmpty(flagPlain) && IsDraftLab(labId))
            {
                ShowStatus("Please set a flag before saving.", false);
                return;
            }

            if (labId == 0 && string.IsNullOrEmpty(flagPlain))
            {
                ShowStatus("Flag is required when creating a new lab.", false);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                if (labId == 0)
                {
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO dbo.Labs (Title, Description, TargetInfo, FlagHash, Points, Difficulty, IsActive, CreatedDate, CreatedBy)
                        VALUES (@Title, @Description, @TargetInfo, @FlagHash, @Points, @Difficulty, @IsActive, GETDATE(), @CreatedBy);
                        SELECT SCOPE_IDENTITY();",
                        conn))
                    {
                        cmd.Parameters.AddWithValue("@Title",       title);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@TargetInfo",  targetInfo);
                        cmd.Parameters.AddWithValue("@FlagHash",    ComputeSha256(flagPlain));
                        cmd.Parameters.AddWithValue("@Points",      points);
                        cmd.Parameters.AddWithValue("@Difficulty",  difficulty);
                        cmd.Parameters.AddWithValue("@IsActive",    isActive);
                        cmd.Parameters.AddWithValue("@CreatedBy",   Convert.ToInt32(Session["UserID"]));
                        labId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    Response.Redirect("~/Admin/ManageLabs.aspx?edit=" + labId);
                    return;
                }
                else
                {
                    string sql = string.IsNullOrEmpty(flagPlain)
                        ? @"UPDATE dbo.Labs
                            SET Title=@Title, Description=@Description, TargetInfo=@TargetInfo,
                                Points=@Points, Difficulty=@Difficulty, IsActive=@IsActive
                            WHERE LabId=@LabId"
                        : @"UPDATE dbo.Labs
                            SET Title=@Title, Description=@Description, TargetInfo=@TargetInfo,
                                FlagHash=@FlagHash, Points=@Points, Difficulty=@Difficulty, IsActive=@IsActive
                            WHERE LabId=@LabId";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Title",       title);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@TargetInfo",  targetInfo);
                        cmd.Parameters.AddWithValue("@Points",      points);
                        cmd.Parameters.AddWithValue("@Difficulty",  difficulty);
                        cmd.Parameters.AddWithValue("@IsActive",    isActive);
                        cmd.Parameters.AddWithValue("@LabId",       labId);
                        if (!string.IsNullOrEmpty(flagPlain))
                            cmd.Parameters.AddWithValue("@FlagHash", ComputeSha256(flagPlain));
                        cmd.ExecuteNonQuery();
                    }

                    ShowStatus("Lab updated successfully.", true);
                }
            }

            pnlForm.Visible = false;
            ClearForm();
            LoadLabsGrid();
        }

        private void DeleteLab(int labId)
        {
            DeleteLabData(labId);
            ShowStatus("Lab deleted successfully.", true);
            LoadLabsGrid();
        }

        private void DeleteLabData(int labId)
        {
            DeleteAllMaterialFiles(labId);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM dbo.LabMaterials WHERE LabId = @LabId", conn))
                {
                    cmd.Parameters.AddWithValue("@LabId", labId);
                    cmd.ExecuteNonQuery();
                }

                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM dbo.UserLabProgress WHERE LabId = @LabId", conn))
                {
                    cmd.Parameters.AddWithValue("@LabId", labId);
                    cmd.ExecuteNonQuery();
                }

                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM dbo.Labs WHERE LabId = @LabId", conn))
                {
                    cmd.Parameters.AddWithValue("@LabId", labId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void DeleteAllMaterialFiles(int labId)
        {
            string labFolder = Server.MapPath(string.Format("~/LabMaterials/{0}", labId));
            if (Directory.Exists(labFolder))
            {
                try { Directory.Delete(labFolder, recursive: true); }
                catch { /* best-effort */ }
            }
        }

        // ── Materials ───────────────────────────────────────────────────────────

        private void LoadMaterials(int labId)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT MaterialId, FileName, FileSize, UploadedDate FROM dbo.LabMaterials WHERE LabId = @LabId ORDER BY UploadedDate",
                conn))
            {
                cmd.Parameters.AddWithValue("@LabId", labId);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            // Add display-formatted file size column
            dt.Columns.Add("FileSizeDisplay", typeof(string));
            foreach (DataRow row in dt.Rows)
                row["FileSizeDisplay"] = FormatFileSize(Convert.ToInt64(row["FileSize"]));

            rptMaterials.DataSource = dt;
            rptMaterials.DataBind();

            lblNoMaterials.Visible = dt.Rows.Count == 0;
        }

        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteMaterial") return;

            int materialId = Convert.ToInt32(e.CommandArgument);
            int labId      = Convert.ToInt32(hdnLabId.Value);

            // Get file path before deleting the row
            string filePath = "";
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT FilePath FROM dbo.LabMaterials WHERE MaterialId = @MaterialId AND LabId = @LabId",
                conn))
            {
                cmd.Parameters.AddWithValue("@MaterialId", materialId);
                cmd.Parameters.AddWithValue("@LabId",      labId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null) filePath = result.ToString();
            }

            // Delete DB row
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "DELETE FROM dbo.LabMaterials WHERE MaterialId = @MaterialId", conn))
            {
                cmd.Parameters.AddWithValue("@MaterialId", materialId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            // Delete physical file
            if (!string.IsNullOrEmpty(filePath))
            {
                string physicalPath = Server.MapPath(filePath);
                if (File.Exists(physicalPath))
                {
                    try { File.Delete(physicalPath); }
                    catch { /* best-effort */ }
                }
            }

            ShowStatus("Material deleted.", true);
            LoadMaterials(labId);
        }

        protected void btnUploadMaterial_Click(object sender, EventArgs e)
        {
            int labId = Convert.ToInt32(hdnLabId.Value);
            if (labId == 0)
            {
                ShowStatus("Save the lab first before uploading materials.", false);
                return;
            }

            if (!fuMaterial.HasFile)
            {
                ShowStatus("Please choose a file to upload.", false);
                pnlMaterialsList.Visible = true;
                pnlUploadRow.Visible     = true;
                LoadMaterials(labId);
                return;
            }

            // Extension block check
            string originalName = Path.GetFileName(fuMaterial.FileName);
            string ext = Path.GetExtension(originalName).ToLowerInvariant();
            foreach (string blocked in BlockedExtensions)
            {
                if (ext == blocked)
                {
                    ShowStatus(string.Format("File type '{0}' is not allowed for security reasons.", ext), false);
                    pnlMaterialsList.Visible = true;
                pnlUploadRow.Visible     = true;
                    LoadMaterials(labId);
                    return;
                }
            }

            // Sanitize filename — strip any path separators, keep the base name
            string safeName = Path.GetFileName(originalName)
                .Replace("..", "")
                .Replace("/",  "")
                .Replace("\\", "");
            if (string.IsNullOrWhiteSpace(safeName))
                safeName = "file" + ext;

            // Build target folder and path
            string labFolder = Server.MapPath(string.Format("~/LabMaterials/{0}", labId));
            if (!Directory.Exists(labFolder))
                Directory.CreateDirectory(labFolder);

            // If a file with the same name already exists, prefix with a timestamp
            string targetPath = Path.Combine(labFolder, safeName);
            if (File.Exists(targetPath))
                safeName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + safeName;
            targetPath = Path.Combine(labFolder, safeName);

            fuMaterial.SaveAs(targetPath);

            long fileSize    = new FileInfo(targetPath).Length;
            string appRelPath = string.Format("~/LabMaterials/{0}/{1}", labId, safeName);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.LabMaterials (LabId, FileName, FilePath, FileSize, UploadedDate, UploadedBy)
                VALUES (@LabId, @FileName, @FilePath, @FileSize, GETDATE(), @UploadedBy)", conn))
            {
                cmd.Parameters.AddWithValue("@LabId",      labId);
                cmd.Parameters.AddWithValue("@FileName",   originalName);
                cmd.Parameters.AddWithValue("@FilePath",   appRelPath);
                cmd.Parameters.AddWithValue("@FileSize",   fileSize);
                cmd.Parameters.AddWithValue("@UploadedBy", Convert.ToInt32(Session["UserID"]));
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ShowStatus(string.Format("'{0}' uploaded successfully.", originalName), true);
            pnlMaterials.Visible = true;
            LoadMaterials(labId);
        }

        // ── Helpers ─────────────────────────────────────────────────────────────

        private void ShowStatus(string message, bool success)
        {
            lblStatusMsg.Text     = message;
            lblStatusMsg.CssClass = success ? "status-msg success" : "status-msg error";
            lblStatusMsg.Visible  = true;
        }

        private static string FormatFileSize(long bytes)
        {
            if (bytes >= 1024 * 1024)
                return string.Format("{0:0.#} MB", bytes / (1024.0 * 1024.0));
            if (bytes >= 1024)
                return string.Format("{0:0.#} KB", bytes / 1024.0);
            return bytes + " B";
        }

        private bool IsDraftLab(int labId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Title FROM dbo.Labs WHERE LabId = @LabId", conn))
            {
                cmd.Parameters.AddWithValue("@LabId", labId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != null && result.ToString() == "(Draft)";
            }
        }

        private string ComputeSha256(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
                var sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("X2"));
                return sb.ToString();
            }
        }
    }
}
