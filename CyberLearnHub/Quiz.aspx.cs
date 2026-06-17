using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Quiz : Page
    {
        private int _courseId;
        private int _quizId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!int.TryParse(Request.QueryString["courseId"], out _courseId) || _courseId <= 0)
            {
                Response.Redirect("~/CourseListing.aspx");
                return;
            }

            int uid = (int)Session["UserID"];
            if (!IsEnrolled(uid, _courseId))
            {
                Response.Redirect("~/CourseDetail.aspx?id=" + _courseId);
                return;
            }

            if (!IsPostBack)
                LoadQuiz(uid);
        }

        private void LoadQuiz(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT Title FROM dbo.Courses WHERE CourseID = @id AND IsPublished = 1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", _courseId);
                    object result = cmd.ExecuteScalar();
                    if (result == null) { Response.Redirect("~/Error.aspx"); return; }
                    lblCourseName.Text = Server.HtmlEncode(result.ToString());
                }

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 QuizID FROM dbo.Quizzes WHERE CourseID = @cid", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", _courseId);
                    object result = cmd.ExecuteScalar();
                    if (result == null)
                    {
                        pnlQuiz.Visible  = false;
                        pnlAlert.Visible = true;
                        lblAlert.Text    = "&gt; No quiz available for this course yet.";
                        return;
                    }
                    _quizId = (int)result;
                    ViewState["QuizID"] = _quizId;
                }
            }

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT QuestionID, QuestionText, QuestionType,
                       OptionA, OptionB, OptionC, OptionD, CorrectOption
                FROM   dbo.QuizQuestions
                WHERE  QuizID = @qid
                ORDER  BY QuestionID", conn))
            {
                cmd.Parameters.AddWithValue("@qid", _quizId);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                pnlQuiz.Visible  = false;
                pnlAlert.Visible = true;
                lblAlert.Text    = "&gt; No questions available for this quiz yet.";
                return;
            }

            // Store grading data in ViewState — never sent to client
            var correctAnswers = new Dictionary<int, string>(); // qid → CorrectOption or answer text
            var questionTypes  = new Dictionary<int, string>(); // qid → QuestionType

            foreach (DataRow row in dt.Rows)
            {
                int    qid    = (int)row["QuestionID"];
                string qType  = row["QuestionType"] as string ?? "MultipleChoice";
                string correct = row["CorrectOption"] as string ?? "A";

                questionTypes[qid] = qType;

                // For FillBlank, store the actual answer text (OptionA)
                correctAnswers[qid] = qType == "FillBlank"
                    ? (row["OptionA"] as string ?? "")
                    : correct;
            }

            ViewState["CorrectAnswers"] = correctAnswers;
            ViewState["QuestionTypes"]  = questionTypes;
            ViewState["CourseID"]       = _courseId;

            // Remove grading columns before binding (don't expose answers)
            dt.Columns.Remove("CorrectOption");

            rptQuestions.DataSource = dt;
            rptQuestions.DataBind();

            int count = dt.Rows.Count;
            lblProgress.Text = string.Format("{0} question{1}", count, count == 1 ? "" : "s");
        }

        // Helper used in .aspx markup for the type pill badge
        protected string GetTypePill(string qType)
        {
            switch (qType)
            {
                case "TrueFalse":  return "<span class=\"qtype-pill qtype-tf\">True / False</span>";
                case "FillBlank":  return "<span class=\"qtype-pill qtype-fill\">Fill in the Blank</span>";
                default:           return "<span class=\"qtype-pill qtype-mcq\">Multiple Choice</span>";
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            var correctAnswers = ViewState["CorrectAnswers"] as Dictionary<int, string>;
            var questionTypes  = ViewState["QuestionTypes"]  as Dictionary<int, string>;
            int courseId       = ViewState["CourseID"] != null ? (int)ViewState["CourseID"] : _courseId;
            int quizId         = ViewState["QuizID"]   != null ? (int)ViewState["QuizID"]   : 0;
            int uid            = (int)Session["UserID"];

            if (correctAnswers == null || correctAnswers.Count == 0 || quizId == 0) return;

            int correct = 0;
            foreach (var kvp in correctAnswers)
            {
                int    qid    = kvp.Key;
                string answer = kvp.Value;
                string qType  = questionTypes != null && questionTypes.ContainsKey(qid)
                                ? questionTypes[qid] : "MultipleChoice";

                string submitted = qType == "FillBlank"
                    ? (Request.Form["fb_" + qid] ?? "")
                    : (Request.Form["q_"  + qid] ?? "");

                if (qType == "FillBlank")
                {
                    if (string.Equals(submitted.Trim(), answer.Trim(), StringComparison.OrdinalIgnoreCase))
                        correct++;
                }
                else
                {
                    if (string.Equals(submitted, answer, StringComparison.OrdinalIgnoreCase))
                        correct++;
                }
            }

            int total      = correctAnswers.Count;
            int percentage = total > 0 ? correct * 100 / total : 0;
            bool passed    = percentage >= 70;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(PassingScore, 70) FROM dbo.Quizzes WHERE QuizID = @qid", conn))
            {
                cmd.Parameters.AddWithValue("@qid", quizId);
                conn.Open();
                object ps = cmd.ExecuteScalar();
                if (ps != null) passed = percentage >= Convert.ToInt32(ps);
            }

            int resultId = SaveResult(uid, quizId, correct, total, percentage, passed);
            Response.Redirect("~/QuizResult.aspx?attemptId=" + resultId);
        }

        private static int SaveResult(int uid, int quizId, int score, int total, int pct, bool passed)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.QuizResults (UserID, QuizID, Score, TotalQuestions, Percentage, Passed)
                OUTPUT INSERTED.ResultID
                VALUES (@uid, @qid, @score, @total, @pct, @passed)", conn))
            {
                cmd.Parameters.AddWithValue("@uid",    uid);
                cmd.Parameters.AddWithValue("@qid",    quizId);
                cmd.Parameters.AddWithValue("@score",  score);
                cmd.Parameters.AddWithValue("@total",  total);
                cmd.Parameters.AddWithValue("@pct",    pct);
                cmd.Parameters.AddWithValue("@passed", passed ? 1 : 0);
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }

        private static bool IsEnrolled(int uid, int courseId)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(1) FROM dbo.Enrollments WHERE UserID = @uid AND CourseID = @cid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@cid", courseId);
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }
    }
}
