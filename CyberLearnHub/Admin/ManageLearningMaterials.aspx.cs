using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Admin
{
    public partial class ManageLearningMaterials : AdminBasePage
    {
        private int _courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!int.TryParse(Request.QueryString["courseId"], out _courseId) || _courseId <= 0)
            {
                Response.Redirect("ManageCourses.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCourseName();
                LoadMaterials();
                if (Request.QueryString["saved"] == "1")
                    ShowAlert("&gt; Material saved.", true);
            }
        }

        private void LoadCourseName()
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT Title FROM dbo.Courses WHERE CourseID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", _courseId);
                conn.Open();
                litCourseName.Text = Server.HtmlEncode(cmd.ExecuteScalar()?.ToString() ?? "");
            }
        }

        private void LoadMaterials()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT MaterialID, CourseID, Title, MaterialType, SortOrder, UploadedDate
                FROM   dbo.LearningMaterials
                WHERE  CourseID = @cid
                ORDER  BY SortOrder, UploadedDate", conn))
            {
                cmd.Parameters.AddWithValue("@cid", _courseId);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0) { pnlEmpty.Visible = true; return; }
            rptMaterials.DataSource = dt;
            rptMaterials.DataBind();
        }

        protected void lbDelete_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(((LinkButton)sender).CommandArgument, out int id)) return;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.Progress           WHERE MaterialID = @id", conn))
                { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
                using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.LearningMaterials  WHERE MaterialID = @id", conn))
                { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
            }

            pnlEmpty.Visible = false;
            LoadMaterials();
            ShowAlert("&gt; Material deleted.", true);
        }

        protected string GetTypeBadge(string type)
        {
            if (string.IsNullOrEmpty(type)) return "";
            string cls = type == "Video"   ? "badge-pub"
                       : type == "PDF"     ? "badge-admin"
                       : type == "Article" ? "badge-member"
                       : "badge-draft";
            return string.Format("<span class=\"badge {0}\">{1}</span>", cls, Server.HtmlEncode(type));
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }
    }
}
