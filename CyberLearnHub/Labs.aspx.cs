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
    public partial class Labs : Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;

        // Holds the feedback message to re-apply after repeater rebind
        private int    _msgLabId = 0;
        private string _msgText  = "";
        private string _msgCss   = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
                LoadLabs();
        }

        private void LoadLabs()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            string query = @"
                SELECT
                    l.LabId, l.Title, l.Description, l.TargetInfo,
                    l.Points, l.Difficulty,
                    CAST(ISNULL(p.IsSolved, 0) AS BIT) AS IsSolved
                FROM dbo.Labs l
                LEFT JOIN dbo.UserLabProgress p
                    ON p.LabId = l.LabId AND p.UserID = @UserID
                WHERE l.IsActive = 1
                ORDER BY l.LabId";

            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            rptLabs.DataSource = dt;
            rptLabs.DataBind();

            lblNoLabs.Visible = dt.Rows.Count == 0;
        }

        protected void rptLabs_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var row   = (DataRowView)e.Item.DataItem;
            int labId = Convert.ToInt32(row["LabId"]);

            // Restore flag feedback message after rebind
            if (_msgLabId != 0 && labId == _msgLabId)
            {
                var lbl = (Label)e.Item.FindControl("lblFlagMsg");
                if (lbl != null)
                {
                    lbl.Text     = _msgText;
                    lbl.CssClass = _msgCss;
                }
            }

            // Load materials for this lab card
            DataTable materials = GetMaterialsForLab(labId);
            if (materials.Rows.Count > 0)
            {
                var pnl = (Panel)e.Item.FindControl("pnlLabMaterials");
                var rpt = (Repeater)e.Item.FindControl("rptLabMaterials");
                if (pnl != null && rpt != null)
                {
                    rpt.DataSource = materials;
                    rpt.DataBind();
                    pnl.Visible = true;
                }
            }
        }

        private DataTable GetMaterialsForLab(int labId)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT MaterialId, FileName, FileSize, FilePath FROM dbo.LabMaterials WHERE LabId = @LabId ORDER BY UploadedDate",
                conn))
            {
                cmd.Parameters.AddWithValue("@LabId", labId);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            dt.Columns.Add("FileSizeDisplay", typeof(string));
            foreach (DataRow r in dt.Rows)
                r["FileSizeDisplay"] = FormatFileSize(Convert.ToInt64(r["FileSize"]));

            return dt;
        }

        protected void rptLabs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DownloadVpn")
            {
                DownloadVpnConfig();
            }
            else if (e.CommandName == "SubmitFlag")
            {
                int labId       = Convert.ToInt32(e.CommandArgument);
                TextBox txtFlag = (TextBox)e.Item.FindControl("txtFlag");
                Label lblMsg    = (Label)e.Item.FindControl("lblFlagMsg");

                SubmitFlag(labId, txtFlag.Text.Trim(), lblMsg);
            }
            else if (e.CommandName == "DownloadMaterial")
            {
                int materialId = Convert.ToInt32(e.CommandArgument);
                DownloadMaterial(materialId);
            }
        }

        private void DownloadVpnConfig()
        {
            string vpnFilePath = Server.MapPath("~/VPNConfigs/student2.ovpn");

            if (!File.Exists(vpnFilePath))
                return;

            Response.Clear();
            Response.ContentType = "application/octet-stream";
            Response.AppendHeader("Content-Disposition", "attachment; filename=cyberlearnhub-lab.ovpn");
            Response.TransmitFile(vpnFilePath);
            Response.End();
        }

        private void DownloadMaterial(int materialId)
        {
            string fileName = "";
            string filePath = "";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT FileName, FilePath FROM dbo.LabMaterials WHERE MaterialId = @MaterialId",
                conn))
            {
                cmd.Parameters.AddWithValue("@MaterialId", materialId);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        fileName = r["FileName"].ToString();
                        filePath = r["FilePath"].ToString();
                    }
                }
            }

            if (string.IsNullOrEmpty(filePath)) return;

            string physicalPath = Server.MapPath(filePath);
            if (!File.Exists(physicalPath)) return;

            Response.Clear();
            Response.ContentType = "application/octet-stream";
            Response.AppendHeader("Content-Disposition",
                string.Format("attachment; filename=\"{0}\"", fileName.Replace("\"", "")));
            Response.TransmitFile(physicalPath);
            Response.End();
        }

        private void SubmitFlag(int labId, string submittedFlag, Label lblFlagMsg)
        {
            if (string.IsNullOrEmpty(submittedFlag))
            {
                lblFlagMsg.Text     = "Please enter a flag.";
                lblFlagMsg.CssClass = "flag-msg error";
                return;
            }

            int    userId        = Convert.ToInt32(Session["UserID"]);
            string submittedHash = ComputeSha256(submittedFlag);
            string correctHash   = "";
            int    points        = 0;

            _msgLabId = labId;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT FlagHash, Points FROM dbo.Labs WHERE LabId = @LabId", conn))
                {
                    cmd.Parameters.AddWithValue("@LabId", labId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            correctHash = r["FlagHash"].ToString();
                            points      = Convert.ToInt32(r["Points"]);
                        }
                    }
                }

                bool isCorrect = string.Equals(submittedHash, correctHash,
                    StringComparison.OrdinalIgnoreCase);

                int  existingProgressId = 0;
                bool alreadySolved      = false;

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ProgressId, IsSolved FROM dbo.UserLabProgress WHERE UserID = @UserID AND LabId = @LabId",
                    conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@LabId",  labId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            existingProgressId = Convert.ToInt32(r["ProgressId"]);
                            alreadySolved      = Convert.ToBoolean(r["IsSolved"]);
                        }
                    }
                }

                if (existingProgressId == 0)
                {
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO dbo.UserLabProgress (UserID, LabId, IsSolved, AttemptCount, SolvedDate)
                        VALUES (@UserID, @LabId, @IsSolved, 1, @SolvedDate)", conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID",    userId);
                        cmd.Parameters.AddWithValue("@LabId",     labId);
                        cmd.Parameters.AddWithValue("@IsSolved",  isCorrect);
                        cmd.Parameters.AddWithValue("@SolvedDate",
                            isCorrect ? (object)DateTime.Now : DBNull.Value);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE dbo.UserLabProgress
                        SET AttemptCount = AttemptCount + 1,
                            IsSolved   = CASE WHEN @IsCorrect = 1 THEN 1 ELSE IsSolved END,
                            SolvedDate = CASE WHEN @IsCorrect = 1 AND IsSolved = 0 THEN @SolvedDate ELSE SolvedDate END
                        WHERE ProgressId = @ProgressId", conn))
                    {
                        cmd.Parameters.AddWithValue("@IsCorrect",  isCorrect);
                        cmd.Parameters.AddWithValue("@SolvedDate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@ProgressId", existingProgressId);
                        cmd.ExecuteNonQuery();
                    }
                }

                if (isCorrect)
                {
                    _msgText = alreadySolved
                        ? "Correct! (already solved earlier)"
                        : string.Format("Correct! +{0} XP", points);
                    _msgCss = "flag-msg success";
                }
                else
                {
                    _msgText = "Incorrect flag. Try again.";
                    _msgCss  = "flag-msg error";
                }
            }

            LoadLabs();
        }

        private static string FormatFileSize(long bytes)
        {
            if (bytes >= 1024 * 1024)
                return string.Format("{0:0.#} MB", bytes / (1024.0 * 1024.0));
            if (bytes >= 1024)
                return string.Format("{0:0.#} KB", bytes / 1024.0);
            return bytes + " B";
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
