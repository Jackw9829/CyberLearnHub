using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Admin
{
    public partial class ManageQuizzes : AdminBasePage
    {
        private int _courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!int.TryParse(Request.QueryString["courseId"], out _courseId) || _courseId <= 0)
            {
                Response.Redirect("ManageCourses.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCourseName();
                LoadQuizzes();
                if (Request.QueryString["saved"] == "1")
                    ShowAlert("&gt; Quiz saved.", true);
            }
        }

        private void LoadCourseName()
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT Title FROM dbo.Courses WHERE CourseID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", _courseId);
                conn.Open();
                litCourseName.Text = Server.HtmlEncode(cmd.ExecuteScalar()?.ToString() ?? "");
            }
        }

        private void LoadQuizzes()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT q.QuizID, q.CourseID, q.Title, q.Description, q.PassingScore,
                       (SELECT COUNT(*) FROM dbo.QuizQuestions WHERE QuizID = q.QuizID) AS QuestionCount
                FROM   dbo.Quizzes q
                WHERE  q.CourseID = @cid
                ORDER  BY q.CreatedDate DESC", conn))
            {
                cmd.Parameters.AddWithValue("@cid", _courseId);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0) { pnlEmpty.Visible = true; return; }
            rptQuizzes.DataSource = dt;
            rptQuizzes.DataBind();
        }

        protected void lbDelete_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(((LinkButton)sender).CommandArgument, out int id)) return;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.QuizResults   WHERE QuizID = @id", conn))
                { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
                using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.QuizQuestions WHERE QuizID = @id", conn))
                { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
                using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.Quizzes       WHERE QuizID = @id", conn))
                { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
            }

            pnlEmpty.Visible = false;
            LoadQuizzes();
            ShowAlert("&gt; Quiz deleted.", true);
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }
    }
}
