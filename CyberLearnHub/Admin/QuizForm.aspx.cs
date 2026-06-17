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
                "SELECT Title, Description, PassingScore FROM dbo.Quizzes WHERE QuizID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("ManageQuizzes.aspx?courseId=" + _courseId); return; }
                    txtTitle.Text        = r["Title"] as string ?? "";
                    txtDescription.Text  = r["Description"] as string ?? "";
                    txtPassingScore.Text = r["PassingScore"]?.ToString() ?? "70";
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

            if (_id > 0)
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE dbo.Quizzes SET Title=@t, Description=@d, PassingScore=@s WHERE QuizID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@t",  title);
                    cmd.Parameters.AddWithValue("@d",  desc);
                    cmd.Parameters.AddWithValue("@s",  score);
                    cmd.Parameters.AddWithValue("@id", _id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO dbo.Quizzes (CourseID, Title, Description, PassingScore) VALUES (@cid, @t, @d, @s)", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", _courseId);
                    cmd.Parameters.AddWithValue("@t",   title);
                    cmd.Parameters.AddWithValue("@d",   desc);
                    cmd.Parameters.AddWithValue("@s",   score);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            Response.Redirect("ManageQuizzes.aspx?courseId=" + _courseId + "&saved=1");
        }
    }
}
