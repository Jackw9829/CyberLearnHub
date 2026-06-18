using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Admin
{
    public partial class ManageQuestions : AdminBasePage
    {
        private int _courseId;
        private int _quizId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!int.TryParse(Request.QueryString["courseId"], out _courseId) || _courseId <= 0)
            {
                Response.Redirect("ManageCourses.aspx");
                return;
            }

            _quizId = GetOrCreateQuizId(_courseId);

            if (!IsPostBack)
            {
                LoadCourseName();
                LoadQuestions();
                if (Request.QueryString["saved"] == "1")
                    ShowAlert("&gt; Question saved.", true);
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

        private void LoadCourseName()
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Title FROM dbo.Courses WHERE CourseID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", _courseId);
                conn.Open();
                object r = cmd.ExecuteScalar();
                litCourseName.Text = Server.HtmlEncode(r?.ToString() ?? "");
            }
        }

        private void LoadQuestions()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT QuestionID, QuizID, QuestionText, QuestionType, OptionA, CorrectOption, Difficulty, Topic
                FROM   dbo.QuizQuestions
                WHERE  QuizID = @qid
                ORDER  BY QuestionID", conn))
            {
                cmd.Parameters.AddWithValue("@qid", _quizId);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            dt.Columns.Add("CourseID", typeof(int));
            foreach (DataRow row in dt.Rows)
                row["CourseID"] = _courseId;

            if (dt.Rows.Count == 0) { pnlEmpty.Visible = true; return; }

            rptQuestions.DataSource = dt;
            rptQuestions.DataBind();
        }

        protected string GetTypeBadge(string qType)
        {
            switch (qType)
            {
                case "TrueFalse":
                    return "<span class=\"badge\" style=\"background:rgba(0,255,157,0.1);color:var(--cyber-accent2);border:1px solid rgba(0,255,157,0.25);\">T / F</span>";
                case "FillBlank":
                    return "<span class=\"badge\" style=\"background:rgba(250,199,117,0.1);color:var(--cyber-amber);border:1px solid rgba(250,199,117,0.25);\">FILL</span>";
                default:
                    return "<span class=\"badge badge-member\">MCQ</span>";
            }
        }

        protected string GetDiffBadge(string diff)
        {
            switch (diff)
            {
                case "Easy": return "<span class=\"badge\" style=\"background:rgba(0,255,157,0.1);color:var(--cyber-accent2);border:1px solid rgba(0,255,157,0.25);\">EASY</span>";
                case "Hard": return "<span class=\"badge\" style=\"background:rgba(255,59,92,0.1);color:var(--cyber-danger);border:1px solid rgba(255,59,92,0.25);\">HARD</span>";
                default:     return "<span class=\"badge\" style=\"background:rgba(250,199,117,0.1);color:var(--cyber-amber);border:1px solid rgba(250,199,117,0.25);\">MED</span>";
            }
        }

        protected string GetAnswerDisplay(string qType, string correctOption, string optionA)
        {
            if (qType == "FillBlank") return optionA ?? "";
            if (qType == "TrueFalse") return correctOption == "A" ? "True" : "False";
            return correctOption ?? "";
        }

        protected void lbDelete_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(((LinkButton)sender).CommandArgument, out int id)) return;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.QuizQuestions WHERE QuestionID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            pnlEmpty.Visible = false;
            LoadQuestions();
            ShowAlert("&gt; Question deleted.", true);
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }
    }
}
