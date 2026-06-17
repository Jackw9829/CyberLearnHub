using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class CourseListing : Page
    {
        private HashSet<int> _enrolledIds = new HashSet<int>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategories();
                LoadCourses();
            }
        }

        private void LoadCategories()
        {
            ddlCategory.Items.Clear();
            ddlCategory.Items.Add(new System.Web.UI.WebControls.ListItem("All Categories", ""));

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT DISTINCT Category FROM dbo.Courses WHERE IsPublished = 1 AND Category IS NOT NULL ORDER BY Category", conn))
            {
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                    while (r.Read())
                        ddlCategory.Items.Add(r.GetString(0));
            }
        }

        private void LoadCourses()
        {
            // Build enrolled set for the current logged-in user
            _enrolledIds.Clear();
            int uid = 0;
            if (Session["UserID"] != null)
            {
                uid = (int)Session["UserID"];
                LoadEnrolledIds(uid);
            }

            string category   = ddlCategory.SelectedValue;
            string difficulty = ddlDifficulty.SelectedValue;
            string search     = txtSearch.Text.Trim();

            string sql = @"
                SELECT CourseID, Title, Description, Category, Difficulty, ImageUrl
                FROM   dbo.Courses
                WHERE  IsPublished = 1
                  AND  (@Category   = '' OR Category      = @Category)
                  AND  (@Difficulty = '' OR Difficulty = @Difficulty)
                  AND  (@Search     = '' OR Title LIKE '%' + @Search + '%'
                                        OR Description LIKE '%' + @Search + '%')
                ORDER BY CreatedDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Category",   category);
                cmd.Parameters.AddWithValue("@Difficulty", difficulty);
                cmd.Parameters.AddWithValue("@Search",     search);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            rptCourses.DataSource = dt;
            rptCourses.DataBind();

            int count = dt.Rows.Count;
            lblCount.Text = string.Format("&gt; <span>{0}</span> course{1} found", count, count == 1 ? "" : "s");
            pnlEmpty.Visible = (count == 0);
        }

        private void LoadEnrolledIds(int userId)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT CourseID FROM dbo.Enrollments WHERE UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                    while (r.Read())
                        _enrolledIds.Add(r.GetInt32(0));
            }
        }

        // Called from Repeater item template
        protected bool IsEnrolled(int courseId) => _enrolledIds.Contains(courseId);

        protected string GetCategoryBadge(string cat)
        {
            if (string.IsNullOrEmpty(cat)) return "";
            return string.Format("<span class=\"badge badge-cat\">{0}</span>", Server.HtmlEncode(cat));
        }

        protected string GetDifficultyBadge(string level)
        {
            if (string.IsNullOrEmpty(level)) return "";
            string cls = level == "Beginner" ? "badge-beg"
                       : level == "Intermediate" ? "badge-int"
                       : "badge-adv";
            return string.Format("<span class=\"badge {0}\">{1}</span>", cls, Server.HtmlEncode(level));
        }

        protected void btnFilter_Click(object sender, EventArgs e) => LoadCourses();

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ddlCategory.SelectedIndex   = 0;
            ddlDifficulty.SelectedIndex = 0;
            txtSearch.Text = "";
            LoadCourses();
        }
    }
}
