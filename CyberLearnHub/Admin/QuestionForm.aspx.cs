using System;
using System.Data.SqlClient;

namespace CyberLearnHub.Admin
{
    public partial class QuestionForm : AdminBasePage
    {
        private int _id, _courseId, _quizId;

        protected void Page_Load(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"],       out _id);
            int.TryParse(Request.QueryString["courseId"], out _courseId);

            if (_courseId <= 0) { Response.Redirect("ManageCourses.aspx"); return; }
            hlBack.NavigateUrl = "ManageQuestions.aspx?courseId=" + _courseId;

            _quizId = GetOrCreateQuizId(_courseId);

            if (!IsPostBack && _id > 0)
            {
                litPageTitle.Text = "Edit Question";
                LoadQuestion(_id);
            }
        }

        private int GetOrCreateQuizId(int courseId)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 QuizID FROM dbo.Quizzes WHERE CourseID = @cid", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", courseId);
                    object result = cmd.ExecuteScalar();
                    if (result != null) return (int)result;
                }
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO dbo.Quizzes (CourseID, Title, PassingScore)
                    OUTPUT INSERTED.QuizID
                    VALUES (@cid, 'Course Quiz', 70)", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", courseId);
                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        private void LoadQuestion(int id)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT QuestionText, QuestionType, OptionA, OptionB, OptionC, OptionD, CorrectOption
                FROM   dbo.QuizQuestions WHERE QuestionID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    string qType = r["QuestionType"] as string ?? "MultipleChoice";
                    hdnQuestionType.Value = qType;
                    txtQuestion.Text      = r["QuestionText"] as string ?? "";

                    if (qType == "TrueFalse")
                    {
                        ddlTFCorrect.SelectedValue = r["CorrectOption"].ToString();
                    }
                    else if (qType == "FillBlank")
                    {
                        txtFillAnswer.Text = r["OptionA"] as string ?? "";
                    }
                    else // MultipleChoice
                    {
                        txtA.Text = r["OptionA"] as string ?? "";
                        txtB.Text = r["OptionB"] as string ?? "";
                        txtC.Text = r["OptionC"] as string ?? "";
                        txtD.Text = r["OptionD"] as string ?? "";
                        try { ddlCorrect.SelectedValue = r["CorrectOption"].ToString(); } catch { }
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"],       out _id);
            int.TryParse(Request.QueryString["courseId"], out _courseId);

            string qType   = hdnQuestionType.Value;
            string qText   = txtQuestion.Text.Trim();
            string optA, optB, optC, optD, correct;

            if (string.IsNullOrWhiteSpace(qText))
            {
                ShowAlert("&gt; Question text is required.", false); return;
            }

            switch (qType)
            {
                case "TrueFalse":
                    optA    = "True"; optB = "False"; optC = ""; optD = "";
                    correct = ddlTFCorrect.SelectedValue;
                    break;

                case "FillBlank":
                    optA = txtFillAnswer.Text.Trim();
                    if (string.IsNullOrWhiteSpace(optA))
                    {
                        ShowAlert("&gt; Correct answer text is required.", false); return;
                    }
                    optB = ""; optC = ""; optD = ""; correct = "A";
                    break;

                default: // MultipleChoice
                    optA = txtA.Text.Trim(); optB = txtB.Text.Trim();
                    optC = txtC.Text.Trim(); optD = txtD.Text.Trim();
                    if (string.IsNullOrWhiteSpace(optA) || string.IsNullOrWhiteSpace(optB) ||
                        string.IsNullOrWhiteSpace(optC) || string.IsNullOrWhiteSpace(optD))
                    {
                        ShowAlert("&gt; All four options are required.", false); return;
                    }
                    correct = ddlCorrect.SelectedValue;
                    break;
            }

            if (_id > 0)
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.QuizQuestions
                    SET QuestionText=@q, QuestionType=@qt,
                        OptionA=@a, OptionB=@b, OptionC=@c, OptionD=@d, CorrectOption=@ans
                    WHERE QuestionID=@id", conn))
                {
                    AddParams(cmd, qText, qType, optA, optB, optC, optD, correct);
                    cmd.Parameters.AddWithValue("@id", _id);
                    conn.Open(); cmd.ExecuteNonQuery();
                }
            }
            else
            {
                int qid = GetOrCreateQuizId(_courseId);
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO dbo.QuizQuestions
                           (QuizID, QuestionText, QuestionType, OptionA, OptionB, OptionC, OptionD, CorrectOption)
                    VALUES (@qid, @q, @qt, @a, @b, @c, @d, @ans)", conn))
                {
                    cmd.Parameters.AddWithValue("@qid", qid);
                    AddParams(cmd, qText, qType, optA, optB, optC, optD, correct);
                    conn.Open(); cmd.ExecuteNonQuery();
                }
            }

            Response.Redirect("ManageQuestions.aspx?courseId=" + _courseId + "&saved=1");
        }

        private static void AddParams(SqlCommand cmd, string q, string qt,
            string a, string b, string c, string d, string ans)
        {
            cmd.Parameters.AddWithValue("@q",   q);
            cmd.Parameters.AddWithValue("@qt",  qt);
            cmd.Parameters.AddWithValue("@a",   a);
            cmd.Parameters.AddWithValue("@b",   b);
            cmd.Parameters.AddWithValue("@c",   c);
            cmd.Parameters.AddWithValue("@d",   d);
            cmd.Parameters.AddWithValue("@ans", ans);
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }
    }
}
