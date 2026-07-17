using System;
using System.IO;
using System.Data.SqlClient;

namespace CyberLearnHub.Admin
{
    public partial class LearningMaterialForm : AdminBasePage
    {
        private static readonly string[] AllowedImageExt = { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" };
        private const long MaxImageBytes = 5  * 1024 * 1024;  // 5 MB
        private const long MaxPdfBytes   = 20 * 1024 * 1024;  // 20 MB

        private int _id, _courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"],       out _id);
            int.TryParse(Request.QueryString["courseId"], out _courseId);

            if (_courseId <= 0) { Response.Redirect("ManageCourses.aspx"); return; }
            hlBack.NavigateUrl = "ManageLearningMaterials.aspx?courseId=" + _courseId;

            if (!IsPostBack && _id > 0)
            {
                litPageTitle.Text = "Edit Material";
                LoadMaterial(_id);
            }
        }

        private void LoadMaterial(int id)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Title, MaterialType, FilePath, Content, SortOrder FROM dbo.LearningMaterials WHERE MaterialID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    string mType   = r["MaterialType"] as string ?? "Article";
                    string filePath = r["FilePath"]    as string ?? "";
                    string content  = r["Content"]     as string ?? "";

                    txtTitle.Text        = r["Title"] as string ?? "";
                    txtSortOrder.Text    = r["SortOrder"]?.ToString() ?? "0";
                    hdnMaterialType.Value = mType;

                    switch (mType)
                    {
                        case "Video":
                            txtVideoUrl.Text  = filePath;
                            txtVideoDesc.Text = content;
                            break;
                        case "PDF":
                            txtPdfUrl.Text  = filePath;
                            txtPdfDesc.Text = content;
                            break;
                        case "Image":
                            txtImageUrl.Text     = filePath;
                            txtImageCaption.Text = content;
                            break;
                        case "Link":
                            txtLinkUrl.Text  = filePath;
                            txtLinkDesc.Text = content;
                            break;
                        default: // Article
                            txtContent.Text = content;
                            break;
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"],       out _id);
            int.TryParse(Request.QueryString["courseId"], out _courseId);
            int.TryParse(txtSortOrder.Text.Trim(),        out int sort);

            string mType   = hdnMaterialType.Value;
            string title   = txtTitle.Text.Trim();
            string filePath, content;

            var validTypes = new System.Collections.Generic.HashSet<string>
                { "Article", "Video", "PDF", "Image", "Link" };
            if (!validTypes.Contains(mType)) mType = "Article";

            if (string.IsNullOrWhiteSpace(title))
            {
                ShowAlert("&gt; Title is required.", false); return;
            }

            // Gather filePath + content based on type
            switch (mType)
            {
                case "Video":
                    filePath = txtVideoUrl.Text.Trim();
                    content  = txtVideoDesc.Text.Trim();
                    if (string.IsNullOrWhiteSpace(filePath))
                    { ShowAlert("&gt; Video URL is required.", false); return; }
                    break;

                case "PDF":
                    if (fuPdf.HasFile)
                    {
                        string saved = SaveFile(fuPdf.PostedFile, "PDF");
                        if (saved == null) return;
                        filePath = saved;
                    }
                    else
                    {
                        filePath = txtPdfUrl.Text.Trim();
                    }
                    content = txtPdfDesc.Text.Trim();
                    break;

                case "Image":
                    if (fuImage.HasFile)
                    {
                        string saved = SaveFile(fuImage.PostedFile, "Image");
                        if (saved == null) return;
                        filePath = saved;
                    }
                    else
                    {
                        filePath = txtImageUrl.Text.Trim();
                    }
                    content = txtImageCaption.Text.Trim();
                    break;

                case "Link":
                    filePath = txtLinkUrl.Text.Trim();
                    content  = txtLinkDesc.Text.Trim();
                    if (string.IsNullOrWhiteSpace(filePath))
                    { ShowAlert("&gt; URL is required.", false); return; }
                    break;

                default: // Article
                    filePath = "";
                    content  = txtContent.Text.Trim();
                    break;
            }

            if (_id > 0)
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.LearningMaterials
                    SET Title=@t, MaterialType=@mt, FilePath=@fp, Content=@c, SortOrder=@s
                    WHERE MaterialID=@id", conn))
                {
                    AddParams(cmd, title, mType, filePath, content, sort);
                    cmd.Parameters.AddWithValue("@id", _id);
                    conn.Open(); cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO dbo.LearningMaterials (CourseID, Title, MaterialType, FilePath, Content, SortOrder)
                    VALUES (@cid, @t, @mt, @fp, @c, @s)", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", _courseId);
                    AddParams(cmd, title, mType, filePath, content, sort);
                    conn.Open(); cmd.ExecuteNonQuery();
                }
            }

            Response.Redirect("ManageLearningMaterials.aspx?courseId=" + _courseId + "&saved=1");
        }

        // Saves an uploaded file; returns app-relative path or null on error
        private string SaveFile(System.Web.HttpPostedFile file, string category)
        {
            string uploadDir;
            if (category == "PDF")
            {
                if (file.ContentLength > MaxPdfBytes)
                { ShowAlert("&gt; PDF is too large (max 20 MB).", false); return null; }
                if (!file.FileName.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase) &&
                    file.ContentType != "application/pdf")
                { ShowAlert("&gt; Only PDF files are allowed.", false); return null; }
                uploadDir = Server.MapPath("~/Uploads/Materials/");
            }
            else // Image
            {
                if (file.ContentLength > MaxImageBytes)
                { ShowAlert("&gt; Image is too large (max 5 MB).", false); return null; }
                string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (Array.IndexOf(AllowedImageExt, ext) < 0)
                { ShowAlert("&gt; Only image files are allowed (JPG, PNG, GIF, WebP).", false); return null; }
                if (!file.ContentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
                { ShowAlert("&gt; The uploaded file does not appear to be an image.", false); return null; }
                uploadDir = Server.MapPath("~/Uploads/Materials/");
            }

            if (!Directory.Exists(uploadDir)) Directory.CreateDirectory(uploadDir);
            string ext2     = Path.GetExtension(file.FileName).ToLowerInvariant();
            string fileName = Guid.NewGuid().ToString("N") + ext2;
            file.SaveAs(Path.Combine(uploadDir, fileName));
            return "~/Uploads/Materials/" + fileName;
        }

        private static void AddParams(SqlCommand cmd, string t, string mt, string fp, string c, int s)
        {
            cmd.Parameters.AddWithValue("@t",  t);
            cmd.Parameters.AddWithValue("@mt", mt);
            cmd.Parameters.AddWithValue("@fp", fp);
            cmd.Parameters.AddWithValue("@c",  c);
            cmd.Parameters.AddWithValue("@s",  s);
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }
    }
}
