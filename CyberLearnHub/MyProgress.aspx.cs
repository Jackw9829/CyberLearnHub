using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class MyProgress : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }
            if (!IsPostBack)
                LoadProgress((int)Session["UserID"]);
        }

        private void LoadProgress(int uid)
        {
            LoadStats(uid);
            LoadXPStreak(uid);
            LoadCourseProgress(uid);
            LoadHistory(uid);
        }

        private void LoadStats(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM dbo.Enrollments WHERE UserID=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    lblEnrolled.Text = cmd.ExecuteScalar().ToString();
                }
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*),
                           SUM(CASE WHEN Passed=1 THEN 1 ELSE 0 END),
                           MAX(Percentage)
                    FROM dbo.QuizResults WHERE UserID=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            lblAttempts.Text = r.IsDBNull(0) ? "0" : Convert.ToInt32(r[0]).ToString();
                            lblPassed.Text   = r.IsDBNull(1) ? "0" : Convert.ToInt32(r[1]).ToString();
                            lblBest.Text     = r.IsDBNull(2) ? "N/A" : Convert.ToInt32(r[2]) + "%";
                        }
                    }
                }
            }
        }

        private void LoadXPStreak(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT x.TotalXP, x.Level,
                       CASE WHEN s.LastPassDate IS NULL THEN 0
                            WHEN s.LastPassDate >= CAST(DATEADD(day,-1,GETDATE()) AS DATE) THEN ISNULL(s.CurrentStreak,0)
                            ELSE 0 END AS DisplayStreak,
                       ISNULL(s.LongestStreak,0)
                FROM (SELECT @uid AS UserID) base
                LEFT JOIN dbo.UserXP      x ON x.UserID = @uid
                LEFT JOIN dbo.UserStreaks  s ON s.UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        int xp            = r.IsDBNull(0) ? 0 : r.GetInt32(0);
                        int level         = r.IsDBNull(1) ? 1 : r.GetInt32(1);
                        int streak        = r.IsDBNull(2) ? 0 : r.GetInt32(2);
                        int longest       = r.IsDBNull(3) ? 0 : r.GetInt32(3);

                        int xpInLevel     = xp % 500;
                        int xpBarPct      = xpInLevel * 100 / 500;

                        lblXP.Text           = xp + " XP";
                        lblStreak.Text       = streak.ToString();
                        lblLevelFull.Text    = "Level " + level;
                        lblXPNext.Text       = xpInLevel + " / 500 XP to next level";
                        lblLongestStreak.Text= "Longest streak: " + longest + " day" + (longest == 1 ? "" : "s");
                        ViewState["XPBarPct"] = xpBarPct;
                    }
                }
            }
        }

        private void LoadCourseProgress(int uid)
        {
            string sql = @"
                SELECT c.CourseID, c.Title,
                    CASE
                        WHEN EXISTS(SELECT 1 FROM dbo.QuizResults qr JOIN dbo.Quizzes qz ON qz.QuizID=qr.QuizID
                                    WHERE qr.UserID=@uid AND qz.CourseID=c.CourseID AND qr.Passed=1) THEN 'Passed'
                        WHEN EXISTS(SELECT 1 FROM dbo.QuizResults qr JOIN dbo.Quizzes qz ON qz.QuizID=qr.QuizID
                                    WHERE qr.UserID=@uid AND qz.CourseID=c.CourseID) THEN 'Failed'
                        ELSE 'None'
                    END AS QuizStatus,
                    ISNULL((SELECT MAX(qr.Percentage) FROM dbo.QuizResults qr JOIN dbo.Quizzes qz ON qz.QuizID=qr.QuizID
                             WHERE qr.UserID=@uid AND qz.CourseID=c.CourseID), 0) AS BestPct,
                    ISNULL((SELECT COUNT(*) FROM dbo.QuizResults qr JOIN dbo.Quizzes qz ON qz.QuizID=qr.QuizID
                             WHERE qr.UserID=@uid AND qz.CourseID=c.CourseID), 0) AS Attempts,
                    ISNULL((SELECT TOP 1 cert.CertificateID FROM dbo.Certificates cert
                             WHERE cert.UserID=@uid AND cert.CourseID=c.CourseID), 0) AS CertID
                FROM dbo.Enrollments e
                JOIN dbo.Courses c ON c.CourseID=e.CourseID
                WHERE e.UserID=@uid
                ORDER BY e.EnrollDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (dt.Rows.Count == 0) { pnlNoCourses.Visible = true; return; }
            pnlCourses.Visible    = true;
            rptCourses.DataSource = dt;
            rptCourses.DataBind();
        }

        private void LoadHistory(int uid)
        {
            string sql = @"
                SELECT TOP 50 qr.ResultID, c.Title AS CourseTitle,
                       qr.Score, qr.TotalQuestions, qr.Percentage, qr.Passed, qr.AttemptDate
                FROM dbo.QuizResults qr
                JOIN dbo.Quizzes qz ON qz.QuizID=qr.QuizID
                JOIN dbo.Courses c  ON c.CourseID=qz.CourseID
                WHERE qr.UserID=@uid
                ORDER BY qr.AttemptDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (dt.Rows.Count == 0) { pnlNoHistory.Visible = true; return; }
            pnlHistory.Visible    = true;
            rptHistory.DataSource = dt;
            rptHistory.DataBind();
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Passed": return "<span class=\"badge-passed\">PASSED</span>";
                case "Failed": return "<span class=\"badge-failed\">FAILED</span>";
                default:       return "<span class=\"badge-none\">NOT STARTED</span>";
            }
        }

        protected string GetCertLink(int courseId, int certId)
        {
            if (certId <= 0) return "<span style=\"color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:10px;\">-</span>";
            return string.Format(
                "<a href=\"~/GetCertificate.ashx?id={0}\" runat=\"server\" style=\"font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-accent2);text-decoration:none;\"><i class=\"ti ti-file-certificate\" style=\"margin-right:4px;\"></i>Download</a>",
                certId);
        }
    }
}
