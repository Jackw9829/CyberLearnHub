using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class QuizResult : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!int.TryParse(Request.QueryString["attemptId"], out int resultId) || resultId <= 0)
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
                LoadResult(resultId, (int)Session["UserID"]);
        }

        private void LoadResult(int resultId, int uid)
        {
            int courseId, quizId, score, total;
            bool passed;
            string courseName, quizTitle;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qr.QuizID, qz.CourseID, qr.Score, qr.TotalQuestions, qr.Passed, c.Title, qz.Title
                FROM   dbo.QuizResults qr
                JOIN   dbo.Quizzes qz ON qz.QuizID   = qr.QuizID
                JOIN   dbo.Courses c  ON c.CourseID   = qz.CourseID
                WHERE  qr.ResultID = @rid AND qr.UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@rid", resultId);
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("~/AccessDenied.aspx"); return; }
                    quizId     = r.GetInt32(0);
                    courseId   = r.GetInt32(1);
                    score      = r.GetInt32(2);
                    total      = r.GetInt32(3);
                    passed     = r.GetBoolean(4);
                    courseName = r.GetString(5);
                    quizTitle  = r.GetString(6);
                }
            }

            int pct = total > 0 ? score * 100 / total : 0;
            string cssClass  = passed ? "passed" : "failed";
            string iconClass = passed ? "ti-circle-check" : "ti-circle-x";
            string verdict   = passed ? "PASSED" : "FAILED";

            var sb = new StringBuilder();
            sb.AppendFormat("<div class=\"score-card {0}\">", cssClass);
            sb.AppendFormat("<div class=\"score-icon\"><i class=\"ti {0}\"></i></div>", iconClass);
            sb.AppendFormat("<div class=\"score-label\">{0}</div>", verdict);
            sb.AppendFormat("<div class=\"score-number\">{0}%</div>", pct);
            sb.AppendFormat("<div class=\"score-total\">{0} / {1} correct</div>", score, total);
            sb.AppendFormat("<div class=\"score-quiz\" style=\"font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:600;color:var(--cyber-heading);margin-bottom:4px;\">{0}</div>",
                Server.HtmlEncode(quizTitle));
            sb.AppendFormat("<div class=\"score-course\">// {0}</div>", Server.HtmlEncode(courseName));
            sb.Append("</div>");
            pnlScore.Controls.Add(new System.Web.UI.LiteralControl(sb.ToString()));

            hlRetake.NavigateUrl = "~/Quiz.aspx?courseId=" + courseId + "&quizId=" + quizId;
            hlBack.NavigateUrl   = "~/CourseDetail.aspx?id=" + courseId;

            if (Request.QueryString["expired"] == "1")
            {
                pnlScore.Controls.AddAt(0, new System.Web.UI.LiteralControl(
                    "<div style=\"background:rgba(255,59,92,0.1);border:1px solid rgba(255,59,92,0.3);color:var(--cyber-danger);font-family:'Share Tech Mono',monospace;font-size:12px;padding:10px 16px;border-radius:6px;margin-bottom:16px;\">&gt; Time expired - quiz auto-submitted.</div>"));
            }

            LoadReview(quizId, resultId);
            LoadQuizLeaderboard(quizId, uid);

            if (passed)
            {
                // Check whether the student has now passed every quiz in the course
                if (AllQuizzesPassed(uid, courseId))
                {
                    int certId = IssueCertificate(uid, courseId, quizId, resultId, pct, courseName);
                    if (certId > 0)
                    {
                        hlCert.NavigateUrl = "~/GetCertificate.ashx?id=" + certId;
                        pnlCertBtn.Visible = true;
                    }
                }
                else
                {
                    // Show how many quizzes remain
                    int[] progress = QuizProgress(uid, courseId);
                    lblCertProgress.Text  = string.Format(
                        "Certificate unlocks when you pass all quizzes in this course. Progress: {0} / {1} passed.",
                        progress[0], progress[1]);
                    pnlCertProgress.Visible = true;
                }
            }
        }

        private void LoadReview(int quizId, int resultId)
        {
            var items = new List<ReviewItem>();

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qq.QuestionID, qq.QuestionText, qq.QuestionType,
                       qq.OptionA, qq.OptionB, qq.OptionC, qq.OptionD,
                       qq.CorrectOption, qq.Explanation,
                       qa.SubmittedAnswer, qa.IsCorrect
                FROM   dbo.QuizQuestions qq
                LEFT JOIN dbo.QuizAnswers qa
                       ON qa.QuestionID = qq.QuestionID AND qa.ResultID = @rid
                WHERE  qq.QuizID = @qid
                ORDER  BY qq.QuestionID", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                cmd.Parameters.AddWithValue("@rid", resultId);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        string qType   = r["QuestionType"] as string ?? "MultipleChoice";
                        string correct = r["CorrectOption"].ToString();

                        string correctText;
                        if (qType == "FillBlank")       correctText = r["OptionA"].ToString();
                        else if (qType == "TrueFalse")  correctText = correct == "A" ? "True" : "False";
                        else correctText = correct == "A" ? r["OptionA"].ToString()
                                         : correct == "B" ? r["OptionB"].ToString()
                                         : correct == "C" ? r["OptionC"].ToString()
                                         :                  r["OptionD"].ToString();

                        string submitted = r["SubmittedAnswer"] as string ?? "";
                        string submittedDisplay = submitted;
                        if (qType == "TrueFalse")
                            submittedDisplay = submitted == "A" ? "True" : submitted == "B" ? "False" : "Not answered";
                        else if (qType == "MultipleChoice" && submitted.Length == 1)
                        {
                            string optCol = submitted == "A" ? "OptionA" : submitted == "B" ? "OptionB"
                                          : submitted == "C" ? "OptionC" : submitted == "D" ? "OptionD" : null;
                            if (optCol != null) submittedDisplay = r[optCol] as string ?? submitted;
                        }
                        if (string.IsNullOrEmpty(submitted)) submittedDisplay = "Not answered";

                        items.Add(new ReviewItem
                        {
                            QuestionText = r["QuestionText"].ToString(),
                            QuestionType = qType,
                            CorrectOption = correct,
                            CorrectText   = correctText,
                            YourAnswer    = submittedDisplay,
                            IsCorrect     = r["IsCorrect"] != DBNull.Value && (bool)r["IsCorrect"],
                            Explanation   = r["Explanation"] as string ?? ""
                        });
                    }
                }
            }

            rptReview.DataSource = items;
            rptReview.DataBind();
        }

        private void LoadQuizLeaderboard(int quizId, int currentUid)
        {
            var sb = new StringBuilder();
            sb.Append("<table style=\"width:100%;border-collapse:collapse;\">");
            sb.Append("<thead><tr>");
            string thStyle = "font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1.5px;text-transform:uppercase;padding:0 12px 8px;text-align:left;border-bottom:1px solid var(--cyber-border);";
            sb.AppendFormat("<th style=\"{0}\">#</th>", thStyle);
            sb.AppendFormat("<th style=\"{0}\">Student</th>", thStyle);
            sb.AppendFormat("<th style=\"{0}\">Best Score</th>", thStyle);
            sb.AppendFormat("<th style=\"{0}\">Attempts</th>", thStyle);
            sb.Append("</tr></thead><tbody>");

            bool hasRows = false;
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 5
                    ROW_NUMBER() OVER (ORDER BY MAX(qr.Percentage) DESC) AS Rank,
                    u.UserID, u.FullName,
                    MAX(qr.Percentage) AS BestPct,
                    COUNT(*) AS Attempts
                FROM dbo.QuizResults qr
                JOIN dbo.Users u ON u.UserID = qr.UserID
                WHERE qr.QuizID = @qid
                GROUP BY u.UserID, u.FullName
                ORDER BY BestPct DESC", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        hasRows = true;
                        int    uid      = r.GetInt32(1);
                        int    rank     = (int)r.GetInt64(0);
                        string name     = Server.HtmlEncode(r.GetString(2));
                        int    bestPct  = Convert.ToInt32(r["BestPct"]);
                        int    attempts = r.GetInt32(4);
                        bool   isMe     = uid == currentUid;
                        string rowStyle = isMe ? "background:rgba(0,212,255,0.06);" : "";
                        string tdStyle  = "padding:10px 12px;font-size:13px;color:var(--cyber-text);border-bottom:1px solid rgba(26,48,80,0.4);";

                        sb.AppendFormat(
                            "<tr style=\"{0}\"><td style=\"{1}\">{2}</td><td style=\"{1}\">{3}{4}</td>" +
                            "<td style=\"padding:10px 12px;font-family:'Rajdhani',sans-serif;font-size:15px;font-weight:700;color:var(--cyber-accent2);border-bottom:1px solid rgba(26,48,80,0.4);\">{5}%</td>" +
                            "<td style=\"padding:10px 12px;font-size:13px;color:var(--cyber-muted);border-bottom:1px solid rgba(26,48,80,0.4);\">{6}</td></tr>",
                            rowStyle, tdStyle, rank, name,
                            isMe ? " <span style=\"font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--cyber-accent);\">YOU</span>" : "",
                            bestPct, attempts);
                    }
                }
            }

            sb.Append("</tbody></table>");

            if (hasRows)
            {
                litLeaderboard.Text    = sb.ToString();
                pnlLeaderboard.Visible = true;
            }
        }

        private bool AllQuizzesPassed(int uid, int courseId)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT
                    (SELECT COUNT(*) FROM dbo.Quizzes WHERE CourseID = @cid) AS Total,
                    (SELECT COUNT(DISTINCT qr.QuizID)
                     FROM dbo.QuizResults qr
                     JOIN dbo.Quizzes qz ON qz.QuizID = qr.QuizID
                     WHERE qr.UserID = @uid AND qz.CourseID = @cid AND qr.Passed = 1) AS Passed", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@cid", courseId);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        int total  = r.GetInt32(0);
                        int passed = r.GetInt32(1);
                        return total > 0 && passed >= total;
                    }
                }
            }
            return false;
        }

        private int[] QuizProgress(int uid, int courseId)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT
                    (SELECT COUNT(*) FROM dbo.Quizzes WHERE CourseID = @cid),
                    (SELECT COUNT(DISTINCT qr.QuizID)
                     FROM dbo.QuizResults qr
                     JOIN dbo.Quizzes qz ON qz.QuizID = qr.QuizID
                     WHERE qr.UserID = @uid AND qz.CourseID = @cid AND qr.Passed = 1)", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@cid", courseId);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                        return new[] { r.GetInt32(1), r.GetInt32(0) };
                }
            }
            return new[] { 0, 0 };
        }

        private int IssueCertificate(int uid, int courseId, int quizId, int resultId,
                                      int percentage, string courseName)
        {
            try
            {
                string userName = Session["FullName"] as string
                               ?? Session["Username"] as string
                               ?? "Student";
                string dir     = Server.MapPath("~/Uploads/Certificates/");
                string appPath = CertificateHelper.Generate(
                    userName, courseName, percentage, DateTime.Now, dir);

                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    MERGE dbo.Certificates AS target
                    USING (SELECT @uid AS UserID, @cid AS CourseID) AS source
                        ON target.UserID=source.UserID AND target.CourseID=source.CourseID
                    WHEN MATCHED THEN
                        UPDATE SET QuizID=@qid, ResultID=@rid, FilePath=@fp, IssuedDate=GETDATE()
                    WHEN NOT MATCHED THEN
                        INSERT (UserID,CourseID,QuizID,ResultID,FilePath)
                        VALUES (@uid,@cid,@qid,@rid,@fp);
                    SELECT CertificateID FROM dbo.Certificates WHERE UserID=@uid AND CourseID=@cid;", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    cmd.Parameters.AddWithValue("@cid", courseId);
                    cmd.Parameters.AddWithValue("@qid", quizId);
                    cmd.Parameters.AddWithValue("@rid", resultId);
                    cmd.Parameters.AddWithValue("@fp",  appPath);
                    conn.Open();
                    object scalar = cmd.ExecuteScalar();
                    if (scalar == null || scalar == DBNull.Value) return 0;
                    return Convert.ToInt32(scalar);
                }
            }
            catch (Exception ex)
            {
                pnlScore.Controls.Add(new System.Web.UI.LiteralControl(
                    "<div style=\"background:rgba(255,59,92,0.1);border:1px solid rgba(255,59,92,0.4);color:var(--cyber-danger);font-family:'Share Tech Mono',monospace;font-size:11px;padding:12px 16px;border-radius:6px;margin-top:12px;word-break:break-all;\">" +
                    "&gt; Certificate error: " + System.Web.HttpUtility.HtmlEncode(ex.GetType().Name + ": " + ex.Message) +
                    "</div>"));
                return 0;
            }
        }

        private class ReviewItem
        {
            public string QuestionText  { get; set; }
            public string QuestionType  { get; set; }
            public string CorrectOption { get; set; }
            public string CorrectText   { get; set; }
            public string YourAnswer    { get; set; }
            public bool   IsCorrect     { get; set; }
            public string Explanation   { get; set; }
        }
    }
}
