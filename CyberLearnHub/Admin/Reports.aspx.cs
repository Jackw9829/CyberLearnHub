using System;
using System.Data;
using System.Data.SqlClient;

namespace CyberLearnHub.Admin
{
    public partial class Reports : AdminBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStats();
                LoadCoursePerformance();
                LoadRecentActivity();
                LoadUserProgress();
            }
        }

        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();
                lblTotalUsers.Text       = Scalar(conn, "SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 1");
                lblTotalCourses.Text     = Scalar(conn, "SELECT COUNT(*) FROM dbo.Courses WHERE IsPublished = 1");
                lblTotalEnrollments.Text = Scalar(conn, "SELECT COUNT(*) FROM dbo.Enrollments");
                lblTotalAttempts.Text    = Scalar(conn, "SELECT COUNT(*) FROM dbo.QuizResults");

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*),
                           SUM(CASE WHEN Passed=1 THEN 1 ELSE 0 END)
                    FROM   dbo.QuizResults", conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read() && !r.IsDBNull(0) && r.GetInt32(0) > 0)
                        {
                            int total  = r.GetInt32(0);
                            int passed = r.IsDBNull(1) ? 0 : r.GetInt32(1);
                            lblPassRate.Text = (passed * 100 / total) + "%";
                        }
                    }
                }
            }
        }

        private void LoadCoursePerformance()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT c.Title,
                       (SELECT COUNT(*) FROM dbo.Enrollments  WHERE CourseID = c.CourseID) AS EnrollCount,
                       (SELECT COUNT(*) FROM dbo.QuizResults qr JOIN dbo.Quizzes qz ON qz.QuizID=qr.QuizID WHERE qz.CourseID=c.CourseID) AS AttemptCount,
                       (SELECT COUNT(*) FROM dbo.QuizResults qr JOIN dbo.Quizzes qz ON qz.QuizID=qr.QuizID WHERE qz.CourseID=c.CourseID AND qr.Passed=1) AS PassCount,
                       ISNULL((SELECT AVG(qr.Percentage) FROM dbo.QuizResults qr JOIN dbo.Quizzes qz ON qz.QuizID=qr.QuizID WHERE qz.CourseID=c.CourseID), 0) AS AvgScore
                FROM   dbo.Courses c
                WHERE  c.IsPublished = 1
                ORDER  BY EnrollCount DESC", conn))
            {
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            // Compute pass rate column
            dt.Columns.Add("PassRate", typeof(int));
            foreach (DataRow row in dt.Rows)
            {
                int attempts = (int)row["AttemptCount"];
                int passes   = (int)row["PassCount"];
                row["PassRate"] = attempts > 0 ? passes * 100 / attempts : 0;
            }

            rptCourses.DataSource = dt;
            rptCourses.DataBind();
        }

        private void LoadRecentActivity()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 20
                       u.FullName, c.Title AS CourseTitle,
                       qr.Score, qr.TotalQuestions, qr.Percentage, qr.Passed, qr.AttemptDate
                FROM   dbo.QuizResults qr
                JOIN   dbo.Users   u  ON u.UserID   = qr.UserID
                JOIN   dbo.Quizzes qz ON qz.QuizID  = qr.QuizID
                JOIN   dbo.Courses c  ON c.CourseID  = qz.CourseID
                ORDER  BY qr.AttemptDate DESC", conn))
            {
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            rptActivity.DataSource = dt;
            rptActivity.DataBind();
        }

        private void LoadUserProgress()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT u.UserID, u.FullName, u.Email,
                       (SELECT COUNT(*) FROM dbo.Enrollments  WHERE UserID=u.UserID) AS EnrolledCourses,
                       (SELECT COUNT(*) FROM dbo.QuizResults  WHERE UserID=u.UserID) AS QuizzesTaken,
                       (SELECT COUNT(*) FROM dbo.QuizResults  WHERE UserID=u.UserID AND Passed=1) AS QuizzesPassed,
                       (SELECT MAX(Percentage) FROM dbo.QuizResults WHERE UserID=u.UserID) AS BestScore
                FROM   dbo.Users u
                WHERE  u.IsActive = 1
                ORDER  BY EnrolledCourses DESC, u.FullName", conn))
            {
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            rptUserProgress.DataSource = dt;
            rptUserProgress.DataBind();
        }

        private static string Scalar(SqlConnection conn, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
                return cmd.ExecuteScalar()?.ToString() ?? "0";
        }
    }
}
