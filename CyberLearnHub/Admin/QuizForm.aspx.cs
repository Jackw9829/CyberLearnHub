using System;
using System.Data.SqlClient;

namespace CyberLearnHub.Admin
{
    public partial class QuizForm : AdminBasePage
    {
        private int _id, _courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"],       out _id);
            int.TryParse(Request.QueryString["courseId"], out _courseId);

            if (_courseId <= 0) { Response.Redirect("ManageCourses.aspx"); return; }
            hlBack.NavigateUrl = "ManageQuizzes.aspx?courseId=" + _courseId;

            if (!IsPostBack && _id > 0)
            {
                litPageTitle.Text = "Edit Quiz";
                LoadQuiz(_id);
            }
        }

        private void LoadQuiz(int id)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Title, Description, PassingScore, TimeLimitMinutes, MaxAttempts, RandomizeQuestions FROM dbo.Quizzes WHERE QuizID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("ManageQuizzes.aspx?courseId=" + _courseId); return; }
                    txtTitle.Text        = r["Title"] as string ?? "";
                    txtDescription.Text  = r["Description"] as string ?? "";
                    txtPassingScore.Text = r["PassingScore"]?.ToString() ?? "70";
                    txtTimeLimit.Text    = r["TimeLimitMinutes"] == DBNull.Value ? "" : r["TimeLimitMinutes"].ToString();
                    txtMaxAttempts.Text  = r["MaxAttempts"]      == DBNull.Value ? "" : r["MaxAttempts"].ToString();
                    chkRandomize.Checked = r["RandomizeQuestions"] != DBNull.Value && (bool)r["RandomizeQuestions"];
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            int.TryParse(Request.QueryString["id"],       out _id);
            int.TryParse(Request.QueryString["courseId"], out _courseId);
            int.TryParse(txtPassingScore.Text.Trim(),     out int score);

            string title = txtTitle.Text.Trim();
            string desc  = txtDescription.Text.Trim();
            int?   timeLimit   = string.IsNullOrWhiteSpace(txtTimeLimit.Text)   ? (int?)null : int.Parse(txtTimeLimit.Text.Trim());
            int?   maxAttempts = string.IsNullOrWhiteSpace(txtMaxAttempts.Text) ? (int?)null : int.Parse(txtMaxAttempts.Text.Trim());
            bool   randomize   = chkRandomize.Checked;

            if (_id > 0)
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.Quizzes
                    SET Title=@t, Description=@d, PassingScore=@s,
                        TimeLimitMinutes=@tl, MaxAttempts=@ma, RandomizeQuestions=@rnd
                    WHERE QuizID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@t",   title);
                    cmd.Parameters.AddWithValue("@d",   desc);
                    cmd.Parameters.AddWithValue("@s",   score);
                    cmd.Parameters.AddWithValue("@tl",  (object)timeLimit   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ma",  (object)maxAttempts ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@rnd", randomize);
                    cmd.Parameters.AddWithValue("@id",  _id);
                    conn.Open(); cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO dbo.Quizzes (CourseID,Title,Description,PassingScore,TimeLimitMinutes,MaxAttempts,RandomizeQuestions)
                    VALUES (@cid,@t,@d,@s,@tl,@ma,@rnd)", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", _courseId);
                    cmd.Parameters.AddWithValue("@t",   title);
                    cmd.Parameters.AddWithValue("@d",   desc);
                    cmd.Parameters.AddWithValue("@s",   score);
                    cmd.Parameters.AddWithValue("@tl",  (object)timeLimit   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ma",  (object)maxAttempts ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@rnd", randomize);
                    conn.Open(); cmd.ExecuteNonQuery();
                }
            }

            Response.Redirect("ManageQuizzes.aspx?courseId=" + _courseId + "&saved=1");
        }
    }
}
