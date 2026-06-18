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
                LoadFailStats();
                LoadScoreDistribution();
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

        private void LoadFailStats()
        {
            System.Data.DataTable dt = new System.Data.DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qq.QuestionID, qq.QuestionText, qq.QuestionType, qq.Difficulty,
                       qz.Title AS QuizTitle, c.CourseID,
                       COUNT(*) AS Attempts,
                       SUM(CASE WHEN qa.IsCorrect=0 THEN 1 ELSE 0 END) * 100 / COUNT(*) AS FailRate
                FROM dbo.QuizAnswers qa
                JOIN dbo.QuizQuestions qq ON qq.QuestionID = qa.QuestionID
                JOIN dbo.Quizzes qz       ON qz.QuizID = qq.QuizID
                JOIN dbo.Courses c        ON c.CourseID = qz.CourseID
                GROUP BY qq.QuestionID, qq.QuestionText, qq.QuestionType, qq.Difficulty,
                         qz.Title, c.CourseID
                HAVING COUNT(*) >= 5
                ORDER BY FailRate DESC", conn))
            {
                conn.Open();
                using (var da = new System.Data.SqlClient.SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0) { pnlNoFailStats.Visible = true; return; }
            pnlFailStats.Visible    = true;
            rptFailStats.DataSource = dt;
            rptFailStats.DataBind();
        }

        private void LoadScoreDistribution()
        {
            var rows = new System.Collections.Generic.List<DistRow>();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qz.QuizID, qz.Title,
                       SUM(CASE WHEN qr.Percentage <  50 THEN 1 ELSE 0 END) AS B0,
                       SUM(CASE WHEN qr.Percentage >= 50 AND qr.Percentage < 70 THEN 1 ELSE 0 END) AS B50,
                       SUM(CASE WHEN qr.Percentage >= 70 AND qr.Percentage < 90 THEN 1 ELSE 0 END) AS B70,
                       SUM(CASE WHEN qr.Percentage >= 90 THEN 1 ELSE 0 END) AS B90,
                       COUNT(*) AS Total
                FROM dbo.QuizResults qr
                JOIN dbo.Quizzes qz ON qz.QuizID = qr.QuizID
                GROUP BY qz.QuizID, qz.Title
                HAVING COUNT(*) > 0
                ORDER BY qz.Title", conn))
            {
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        int total = r.GetInt32(6);
                        rows.Add(new DistRow
                        {
                            QuizTitle     = r.GetString(1),
                            TotalAttempts = total,
                            BarsHtml      = BuildBars(r.GetInt32(2), r.GetInt32(3), r.GetInt32(4), r.GetInt32(5), total)
                        });
                    }
                }
            }
            rptDistribution.DataSource = rows;
            rptDistribution.DataBind();
        }

        private static string BuildBars(int b0, int b50, int b70, int b90, int total)
        {
            var sb = new System.Text.StringBuilder();
            sb.Append("<div style=\"display:flex;flex-direction:column;gap:6px;\">");
            AppendBar(sb, "0-49%",   b0,  total, "var(--cyber-danger)");
            AppendBar(sb, "50-69%",  b50, total, "var(--cyber-amber)");
            AppendBar(sb, "70-89%",  b70, total, "var(--cyber-accent)");
            AppendBar(sb, "90-100%", b90, total, "var(--cyber-accent2)");
            sb.Append("</div>");
            return sb.ToString();
        }

        private static void AppendBar(System.Text.StringBuilder sb,
            string label, int count, int total, string color)
        {
            int pct = total > 0 ? count * 100 / total : 0;
            sb.AppendFormat(
                "<div style=\"display:flex;align-items:center;gap:10px;\">" +
                "<span style=\"font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--cyber-muted);width:48px;text-align:right;\">{0}</span>" +
                "<div style=\"flex:1;background:var(--cyber-border);border-radius:2px;height:16px;overflow:hidden;\">" +
                "<div style=\"width:{1}%;background:{2};height:100%;border-radius:2px;\"></div></div>" +
                "<span style=\"font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);width:24px;\">{3}</span>" +
                "</div>",
                label, pct, color, count);
        }

        private class DistRow
        {
            public string QuizTitle     { get; set; }
            public int    TotalAttempts { get; set; }
            public string BarsHtml      { get; set; }
        }
    }
}
