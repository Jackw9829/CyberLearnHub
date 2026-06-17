using System;
using System.IO;
using System.Data.SqlClient;
using System.Web.UI;

namespace CyberLearnHub.Admin
{
    public partial class CourseForm : AdminBasePage
    {
        private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" };
        private const long MaxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

        private int _id;

        protected void Page_Load(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"], out _id);

            if (!IsPostBack)
            {
                if (_id > 0)
                {
                    litPageTitle.Text = "Edit Course";
                    LoadCourse(_id);
                }
            }
        }

        private void LoadCourse(int id)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Title, Description, Category, Difficulty, ImageUrl, IsPublished FROM dbo.Courses WHERE CourseID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("ManageCourses.aspx"); return; }
                    txtTitle.Text       = r["Title"] as string ?? "";
                    txtDescription.Text = r["Description"] as string ?? "";
                    txtCategory.Text    = r["Category"] as string ?? "";
                    ddlDifficulty.SelectedValue = r["Difficulty"] as string ?? "";
                    txtThumbnail.Text   = r["ImageUrl"] as string ?? "";
                    chkPublished.Checked = Convert.ToBoolean(r["IsPublished"]);
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            int.TryParse(Request.QueryString["id"], out _id);

            string title = txtTitle.Text.Trim();
            string desc  = txtDescription.Text.Trim();
            string cat   = txtCategory.Text.Trim();
            string diff  = ddlDifficulty.SelectedValue;
            bool   pub   = chkPublished.Checked;

            // Resolve image: uploaded file takes priority over URL
            string imageUrl = txtThumbnail.Text.Trim();

            if (fuImage.HasFile)
            {
                string result = SaveUploadedImage();
                if (result == null) return; // validation failed, error already shown
                imageUrl = result;
            }

            if (_id > 0)
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.Courses
                    SET Title=@t, Description=@d, Category=@c,
                        Difficulty=@diff, ImageUrl=@img, IsPublished=@pub
                    WHERE CourseID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@t",    title);
                    cmd.Parameters.AddWithValue("@d",    desc);
                    cmd.Parameters.AddWithValue("@c",    cat);
                    cmd.Parameters.AddWithValue("@diff", diff);
                    cmd.Parameters.AddWithValue("@img",  imageUrl);
                    cmd.Parameters.AddWithValue("@pub",  pub ? 1 : 0);
                    cmd.Parameters.AddWithValue("@id",   _id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO dbo.Courses (Title, Description, Category, Difficulty, ImageUrl, IsPublished)
                    VALUES (@t, @d, @c, @diff, @img, @pub)", conn))
                {
                    cmd.Parameters.AddWithValue("@t",    title);
                    cmd.Parameters.AddWithValue("@d",    desc);
                    cmd.Parameters.AddWithValue("@c",    cat);
                    cmd.Parameters.AddWithValue("@diff", diff);
                    cmd.Parameters.AddWithValue("@img",  imageUrl);
                    cmd.Parameters.AddWithValue("@pub",  pub ? 1 : 0);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            Response.Redirect("ManageCourses.aspx?saved=1");
        }

        private string SaveUploadedImage()
        {
            var file = fuImage.PostedFile;

            // Validate extension
            string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (Array.IndexOf(AllowedExtensions, ext) < 0)
            {
                ShowError("Only image files are allowed (JPG, PNG, GIF, WebP, BMP).");
                return null;
            }

            // Validate size
            if (file.ContentLength > MaxFileSizeBytes)
            {
                ShowError("Image file is too large. Maximum size is 5 MB.");
                return null;
            }

            // Validate MIME type prefix
            if (!file.ContentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
            {
                ShowError("The uploaded file does not appear to be an image.");
                return null;
            }

            // Save to ~/Uploads/Courses/ with a unique filename
            string uploadDir = Server.MapPath("~/Uploads/Courses/");
            if (!Directory.Exists(uploadDir))
                Directory.CreateDirectory(uploadDir);

            string fileName = Guid.NewGuid().ToString("N") + ext;
            string savePath = Path.Combine(uploadDir, fileName);
            file.SaveAs(savePath);

            return "~/Uploads/Courses/" + fileName;
        }

        private void ShowError(string message)
        {
            lblImgError.Text    = "&gt; " + message;
            lblImgError.Visible = true;
        }
    }
}
