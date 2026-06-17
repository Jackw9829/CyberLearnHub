using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class MyCourses : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!IsPostBack)
                LoadCourses((int)Session["UserID"]);
        }

        private void LoadCourses(int uid)
        {
            string sql = @"
                SELECT c.CourseID, c.Title, c.Category, c.Difficulty, c.ImageUrl,
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
                    END AS QuizStatus,
                    (
                        SELECT MAX(qr2.Percentage)
                        FROM dbo.QuizResults qr2
                        JOIN dbo.Quizzes qz2 ON qz2.QuizID = qr2.QuizID
                        WHERE qr2.UserID = @uid AND qz2.CourseID = c.CourseID
                    ) AS BestScore
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

            lblCount.Text = dt.Rows.Count.ToString();

            if (dt.Rows.Count == 0)
            {
                pnlEmpty.Visible = true;
                return;
            }

            rptCourses.DataSource = dt;
            rptCourses.DataBind();
        }

        protected string GetThumbHtml(string imageUrl)
        {
            if (!string.IsNullOrEmpty(imageUrl))
                return string.Format("<img src=\"{0}\" alt=\"course\" />",
                    Server.HtmlEncode(ResolveUrl(imageUrl)));
            return "<i class=\"ti ti-shield-lock thumb-icon\"></i>";
        }

        protected string GetDiffBadge(string diff)
        {
            if (string.IsNullOrEmpty(diff)) return "";
            string cls = diff == "Beginner" ? "badge-beg"
                       : diff == "Intermediate" ? "badge-int"
                       : "badge-adv";
            return string.Format("<span class=\"badge-diff {0}\">{1}</span>", cls, Server.HtmlEncode(diff));
        }

        protected string GetCatBadge(string cat)
        {
            if (string.IsNullOrEmpty(cat)) return "";
            return string.Format("<span class=\"badge-diff badge-cat\">{0}</span>", Server.HtmlEncode(cat));
        }

        protected string GetQuizBadge(string status)
        {
            switch (status)
            {
                case "Passed": return "<span class=\"quiz-status-badge qs-passed\">&#10003; Passed</span>";
                case "Failed": return "<span class=\"quiz-status-badge qs-failed\">&#10007; Failed</span>";
                default:       return "<span class=\"quiz-status-badge qs-none\">Not Started</span>";
            }
        }

        protected string GetBestScore(object bestScore, string quizStatus)
        {
            if (quizStatus == "None" || bestScore == DBNull.Value || bestScore == null)
                return "";
            return string.Format("<div class=\"mc-card-score\">Best: <span>{0}%</span></div>",
                Convert.ToInt32(bestScore));
        }
    }
}
