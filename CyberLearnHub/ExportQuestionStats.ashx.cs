using System;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.SessionState;

namespace CyberLearnHub
{
    public class ExportQuestionStats : IHttpHandler, IRequiresSessionState
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
                "attachment; filename=\"question-stats-" + DateTime.Now.ToString("yyyy-MM-dd") + ".csv\"");

            var sb = new StringBuilder();
            sb.AppendLine("QuestionID,QuestionText,Quiz,Course,Difficulty,Topic,TotalAttempts,CorrectCount,IncorrectCount,FailRate%");

            using (var conn = new SqlConnection(DbHelper.ConnectionString))
            using (var cmd  = new SqlCommand(@"
                SELECT qq.QuestionID, qq.QuestionText, qz.Title, c.Title,
                       qq.Difficulty, ISNULL(qq.Topic,''),
                       COUNT(*) AS Total,
                       SUM(CASE WHEN qa.IsCorrect=1 THEN 1 ELSE 0 END) AS Correct,
                       SUM(CASE WHEN qa.IsCorrect=0 THEN 1 ELSE 0 END) AS Incorrect
                FROM dbo.QuizAnswers qa
                JOIN dbo.QuizQuestions qq ON qq.QuestionID = qa.QuestionID
                JOIN dbo.Quizzes qz       ON qz.QuizID    = qq.QuizID
                JOIN dbo.Courses c        ON c.CourseID   = qz.CourseID
                GROUP BY qq.QuestionID, qq.QuestionText, qz.Title, c.Title,
                         qq.Difficulty, qq.Topic
                ORDER BY qq.QuestionID", conn))
            {
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        int total   = r.GetInt32(6);
                        int wrong   = r.GetInt32(8);
                        int failPct = total > 0 ? wrong * 100 / total : 0;
                        sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                            r.GetInt32(0), Csv(r.GetString(1)),
                            Csv(r.GetString(2)), Csv(r.GetString(3)),
                            r.GetString(4), Csv(r.GetString(5)),
                            total, r.GetInt32(7), wrong, failPct));
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
