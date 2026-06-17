using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace CyberLearnHub.Admin
{
    public partial class AdminDefault : AdminBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadStats();
        }

        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();
                lblUsers.Text      = Scalar(conn, "SELECT COUNT(*) FROM dbo.Users");
                lblCourses.Text    = Scalar(conn, "SELECT COUNT(*) FROM dbo.Courses");
                lblEnrolments.Text = Scalar(conn, "SELECT COUNT(*) FROM dbo.Enrollments");
                lblAttempts.Text   = Scalar(conn, "SELECT COUNT(*) FROM dbo.QuizResults");

            }
        }

        private static string Scalar(SqlConnection conn, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
                return cmd.ExecuteScalar()?.ToString() ?? "0";
        }
    }
}
