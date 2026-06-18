using System;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.SessionState;

namespace CyberLearnHub
{
    public class ExportResults : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext ctx)
        {
            if (ctx.Session["Role"] as string != "Admin")
            {
                ctx.Response.Redirect("~/AccessDenied.aspx");
                return;
            }

            ctx.Response.ContentType = "text/csv";
            ctx.Response.AddHeader("Content-Disposition",
                "attachment; filename=\"results-" + DateTime.Now.ToString("yyyy-MM-dd") + ".csv\"");

            var sb = new StringBuilder();
            sb.AppendLine("Username,Email,Course,Quiz,Score,TotalQuestions,Percentage,Passed,AttemptDate");

            using (var conn = new SqlConnection(DbHelper.ConnectionString))
            using (var cmd  = new SqlCommand(@"
                SELECT u.FullName, u.Email, c.Title, qz.Title,
                       qr.Score, qr.TotalQuestions, qr.Percentage, qr.Passed, qr.AttemptDate
                FROM dbo.QuizResults qr
                JOIN dbo.Users   u  ON u.UserID  = qr.UserID
                JOIN dbo.Quizzes qz ON qz.QuizID = qr.QuizID
                JOIN dbo.Courses c  ON c.CourseID = qz.CourseID
                ORDER BY qr.AttemptDate DESC", conn))
            {
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8}",
                            Csv(r.GetString(0)), Csv(r.GetString(1)),
                            Csv(r.GetString(2)), Csv(r.GetString(3)),
                            r.GetInt32(4), r.GetInt32(5), Convert.ToInt32(r[6]),
                            r.GetBoolean(7) ? "Yes" : "No",
                            Convert.ToDateTime(r[8]).ToString("yyyy-MM-dd HH:mm")));
                    }
                }
            }
            ctx.Response.Write(sb.ToString());
        }

        private static string Csv(string v) =>
            v != null && (v.Contains(",") || v.Contains("\"") || v.Contains("\n"))
                ? "\"" + v.Replace("\"", "\"\"") + "\""
                : v ?? "";

        public bool IsReusable => false;
    }
}
