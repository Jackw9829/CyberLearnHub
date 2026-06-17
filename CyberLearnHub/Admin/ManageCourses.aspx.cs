using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Admin
{
    public partial class ManageCourses : AdminBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
                if (Request.QueryString["saved"] == "1")
                    ShowAlert("&gt; Course saved successfully.", true);
            }
        }

        private void LoadCourses()
        {
            string sql = @"
                SELECT c.CourseID, c.Title, c.Category, c.Difficulty, c.IsPublished,
                       (SELECT COUNT(*) FROM dbo.Enrollments WHERE CourseID = c.CourseID) AS EnrollCount
                FROM   dbo.Courses c
                ORDER  BY c.CreatedDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0) { pnlEmpty.Visible = true; return; }

            rptCourses.DataSource = dt;
            rptCourses.DataBind();
        }

        protected void lbDelete_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(((LinkButton)sender).CommandArgument, out int id)) return;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();
                // Delete child records first to respect FK constraints
                Execute(conn, "DELETE FROM dbo.QuizResults   WHERE QuizID IN (SELECT QuizID FROM dbo.Quizzes WHERE CourseID = @id)", id);
                Execute(conn, "DELETE FROM dbo.QuizQuestions WHERE QuizID IN (SELECT QuizID FROM dbo.Quizzes WHERE CourseID = @id)", id);
                Execute(conn, "DELETE FROM dbo.Quizzes       WHERE CourseID = @id", id);
                Execute(conn, "DELETE FROM dbo.Enrollments   WHERE CourseID = @id", id);
                Execute(conn, "DELETE FROM dbo.Courses       WHERE CourseID = @id", id);
            }

            LoadCourses();
            ShowAlert("&gt; Course deleted.", true);
        }

        private static void Execute(SqlConnection conn, string sql, int id)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text       = msg;
            pnlAlert.CssClass   = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible    = true;
        }
    }
}
