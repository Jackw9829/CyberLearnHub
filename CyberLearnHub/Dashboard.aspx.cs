using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!IsPostBack)
                LoadDashboard((int)Session["UserID"]);
        }

        private void LoadDashboard(int uid)
        {
            lblUsername.Text = Server.HtmlEncode(Session["Username"] as string ?? "");
            LoadStats(uid);
            LoadXPStreak(uid);
            LoadMyCourses(uid);
            LoadActivity(uid);
        }

        private void LoadStats(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Enrollments WHERE UserID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    lblStatEnrolled.Text = cmd.ExecuteScalar().ToString();
                }

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*),
                           SUM(CASE WHEN Passed=1 THEN 1 ELSE 0 END),
                           MAX(Percentage)
                    FROM   dbo.QuizResults
                    WHERE  UserID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            lblStatAttempts.Text = r.IsDBNull(0) ? "0" : Convert.ToInt32(r[0]).ToString();
                            lblStatPassed.Text   = r.IsDBNull(1) ? "0" : Convert.ToInt32(r[1]).ToString();
                            lblStatBest.Text     = r.IsDBNull(2) ? "N/A" : Convert.ToInt32(r[2]) + "%";
                        }
                    }
                }
            }
        }

        private void LoadMyCourses(int uid)
        {
            string sql = @"
                SELECT c.CourseID, c.Title,
                    CASE
                        WHEN EXISTS(
                            SELECT 1 FROM dbo.QuizResults qr
                            JOIN dbo.Quizzes qz ON qz.QuizID = qr.QuizID
                            WHERE qr.UserID = @uid AND qz.CourseID = c.CourseID AND qr.Passed = 1
                        ) THEN 'Passed'
                        WHEN EXISTS(
                            SELECT 1 FROM dbo.QuizResults qr
                            JOIN dbo.Quizzes qz ON qz.QuizID = qr.QuizID
                            WHERE qr.UserID = @uid AND qz.CourseID = c.CourseID
                        ) THEN 'Failed'
                        ELSE 'None'
                    END AS QuizStatus
                FROM dbo.Enrollments e
                JOIN dbo.Courses c ON c.CourseID = e.CourseID
                WHERE e.UserID = @uid
                ORDER BY e.EnrollDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                pnlNoCourses.Visible = true;
                return;
            }

            rptMyCourses.DataSource = dt;
            rptMyCourses.DataBind();
        }

        private void LoadActivity(int uid)
        {
            string sql = @"
                SELECT TOP 5 c.Title, qr.Score, qr.TotalQuestions, qr.Passed, qr.AttemptDate
                FROM dbo.QuizResults qr
                JOIN dbo.Quizzes qz ON qz.QuizID   = qr.QuizID
                JOIN dbo.Courses c  ON c.CourseID   = qz.CourseID
                WHERE qr.UserID = @uid
                ORDER BY qr.AttemptDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                pnlNoActivity.Visible = true;
                return;
            }

            pnlActivity.Visible    = true;
            rptActivity.DataSource = dt;
            rptActivity.DataBind();
        }

        private void LoadXPStreak(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT x.TotalXP, x.Level,
                       CASE WHEN s.LastPassDate IS NULL THEN 0
                            WHEN s.LastPassDate >= CAST(DATEADD(day,-1,GETDATE()) AS DATE) THEN ISNULL(s.CurrentStreak,0)
                            ELSE 0 END AS DisplayStreak
                FROM   (SELECT @uid AS UserID) base
                LEFT JOIN dbo.UserXP      x ON x.UserID = @uid
                LEFT JOIN dbo.UserStreaks  s ON s.UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        int xp     = r.IsDBNull(0) ? 0 : r.GetInt32(0);
                        int level  = r.IsDBNull(1) ? 1 : r.GetInt32(1);
                        int streak = r.IsDBNull(2) ? 0 : r.GetInt32(2);
                        lblXP.Text     = xp + " XP";
                        lblLevel.Text  = "LVL " + level;
                        lblStreak.Text = streak > 0 ? streak + "-day streak" : "No active streak";
                    }
                }
            }
        }

        protected string GetQuizStatusBadge(string status)
        {
            switch (status)
            {
                case "Passed": return "<span class=\"quiz-status-badge qs-passed\">&#10003; Passed</span>";
                case "Failed": return "<span class=\"quiz-status-badge qs-failed\">&#10007; Failed</span>";
                default:       return "<span class=\"quiz-status-badge qs-none\">Not Started</span>";
            }
        }
    }
}
