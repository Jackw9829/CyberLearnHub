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
            string courseName;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT qr.QuizID, qz.CourseID, qr.Score, qr.TotalQuestions, qr.Passed, c.Title
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
            sb.AppendFormat("<div class=\"score-course\">// {0}</div>", Server.HtmlEncode(courseName));
            sb.Append("</div>");
            pnlScore.Controls.Add(new System.Web.UI.LiteralControl(sb.ToString()));

            hlRetake.NavigateUrl = "~/Quiz.aspx?courseId=" + courseId;
            hlBack.NavigateUrl   = "~/CourseDetail.aspx?id=" + courseId;

            if (Request.QueryString["expired"] == "1")
            {
                pnlScore.Controls.AddAt(0, new System.Web.UI.LiteralControl(
                    "<div style=\"background:rgba(255,59,92,0.1);border:1px solid rgba(255,59,92,0.3);color:var(--cyber-danger);font-family:'Share Tech Mono',monospace;font-size:12px;padding:10px 16px;border-radius:6px;margin-bottom:16px;\">&gt; Time expired - quiz auto-submitted.</div>"));
            }

            LoadReview(quizId, resultId);
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
