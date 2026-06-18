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

                int timeLimitMinutes = 0;
                int maxAttempts      = 0;
                bool randomize       = false;

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 1 QuizID, ISNULL(TimeLimitMinutes,0), ISNULL(MaxAttempts,0), ISNULL(RandomizeQuestions,0)
                    FROM dbo.Quizzes WHERE CourseID = @cid", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", _courseId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            pnlQuiz.Visible  = false;
                            pnlAlert.Visible = true;
                            lblAlert.Text    = "&gt; No quiz available for this course yet.";
                            return;
                        }
                        _quizId          = r.GetInt32(0);
                        timeLimitMinutes = r.GetInt32(1);
                        maxAttempts      = r.GetInt32(2);
                        randomize        = r.GetBoolean(3);
                        ViewState["QuizID"] = _quizId;
                    }
                }

                // Max attempts check
                if (maxAttempts > 0)
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.QuizResults WHERE UserID=@uid AND QuizID=@qid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", uid);
                        cmd.Parameters.AddWithValue("@qid", _quizId);
                        int attempts = (int)cmd.ExecuteScalar();
                        if (attempts >= maxAttempts)
                        {
                            object bestObj;
                            using (SqlCommand bc = new SqlCommand(
                                "SELECT MAX(Percentage) FROM dbo.QuizResults WHERE UserID=@uid AND QuizID=@qid", conn))
                            {
                                bc.Parameters.AddWithValue("@uid", uid);
                                bc.Parameters.AddWithValue("@qid", _quizId);
                                bestObj = bc.ExecuteScalar();
                            }
                            string best = bestObj != DBNull.Value && bestObj != null
                                ? Convert.ToInt32(bestObj) + "%" : "N/A";
                            pnlQuiz.Visible  = false;
                            pnlAlert.Visible = true;
                            lblAlert.Text    = string.Format(
                                "&gt; Maximum attempts reached ({0}/{0}). Your best score: {1}",
                                maxAttempts, best);
                            return;
                        }
                    }
                }
            }

            string orderBy = randomize ? "NEWID()" : "QuestionID";
            DataTable dt = new DataTable();
            using (SqlConnection conn2 = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(string.Format(@"
                SELECT QuestionID, QuestionText, QuestionType,
                       OptionA, OptionB, OptionC, OptionD, CorrectOption, Difficulty
                FROM   dbo.QuizQuestions
                WHERE  QuizID = @qid
                ORDER  BY {0}", orderBy), conn2))
            {
                cmd.Parameters.AddWithValue("@qid", _quizId);
                conn2.Open();
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
            var difficulties   = new Dictionary<int, string>(); // qid → Difficulty

            foreach (DataRow row in dt.Rows)
            {
                int    qid    = (int)row["QuestionID"];
                string qType  = row["QuestionType"] as string ?? "MultipleChoice";
                string correct = row["CorrectOption"] as string ?? "A";

                questionTypes[qid] = qType;
                difficulties[qid]  = row["Difficulty"] as string ?? "Medium";

                // For FillBlank, store the actual answer text (OptionA)
                correctAnswers[qid] = qType == "FillBlank"
                    ? (row["OptionA"] as string ?? "")
                    : correct;
            }

            ViewState["CorrectAnswers"] = correctAnswers;
            ViewState["QuestionTypes"]  = questionTypes;
            ViewState["Difficulties"]   = difficulties;
            ViewState["CourseID"]       = _courseId;

            // Timer
            if (timeLimitMinutes > 0)
            {
                Session["QuizStartTime_" + _quizId]  = DateTime.Now;
                Session["QuizTimeLimit_"  + _quizId] = timeLimitMinutes;
                ViewState["TimeLimitMinutes"] = timeLimitMinutes;
            }

            // Remove grading columns before binding (don't expose answers)
            dt.Columns.Remove("CorrectOption");
            dt.Columns.Remove("Difficulty");

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

            // Timer validation
            int timeLimitMinutes = ViewState["TimeLimitMinutes"] != null ? (int)ViewState["TimeLimitMinutes"] : 0;
            if (timeLimitMinutes > 0)
            {
                var startKey = "QuizStartTime_" + quizId;
                if (Session[startKey] is DateTime startTime)
                {
                    double elapsed = (DateTime.Now - startTime).TotalSeconds;
                    double allowed = timeLimitMinutes * 60 + 30; // 30s grace
                    if (elapsed > allowed)
                    {
                        int resultId = SaveResult(uid, quizId, 0, correctAnswers != null ? correctAnswers.Count : 0, 0, false);
                        Session.Remove(startKey);
                        Response.Redirect("~/QuizResult.aspx?attemptId=" + resultId + "&expired=1");
                        return;
                    }
                }
                Session.Remove("QuizStartTime_" + quizId);
            }

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
            SaveAnswers(resultId, correctAnswers, questionTypes);
            AwardXP(uid, quizId, correctAnswers, questionTypes, passed);
            if (passed) UpdateStreak(uid);
            Session.Remove("QuizStartTime_" + quizId);
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

        private void SaveAnswers(int resultId, Dictionary<int, string> correctAnswers, Dictionary<int, string> questionTypes)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();
                foreach (var kvp in correctAnswers)
                {
                    int    qid    = kvp.Key;
                    string answer = kvp.Value;
                    string qType  = questionTypes != null && questionTypes.ContainsKey(qid)
                                    ? questionTypes[qid] : "MultipleChoice";
                    string submitted = qType == "FillBlank"
                        ? (Request.Form["fb_" + qid] ?? "")
                        : (Request.Form["q_"  + qid] ?? "");
                    bool isCorrect = qType == "FillBlank"
                        ? string.Equals(submitted.Trim(), answer.Trim(), StringComparison.OrdinalIgnoreCase)
                        : string.Equals(submitted, answer, StringComparison.OrdinalIgnoreCase);

                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO dbo.QuizAnswers (ResultID, QuestionID, SubmittedAnswer, IsCorrect)
                        VALUES (@rid, @qid, @ans, @ok)", conn))
                    {
                        cmd.Parameters.AddWithValue("@rid", resultId);
                        cmd.Parameters.AddWithValue("@qid", qid);
                        cmd.Parameters.AddWithValue("@ans", submitted);
                        cmd.Parameters.AddWithValue("@ok",  isCorrect);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
        }

        private void AwardXP(int uid, int quizId, Dictionary<int, string> correctAnswers,
                             Dictionary<int, string> questionTypes, bool passed)
        {
            var diffMap = ViewState["Difficulties"] as Dictionary<int, string>
                       ?? new Dictionary<int, string>();

            int xpEarned = 0;
            foreach (var kvp in correctAnswers)
            {
                int    qid   = kvp.Key;
                string qType = questionTypes != null && questionTypes.ContainsKey(qid)
                               ? questionTypes[qid] : "MultipleChoice";
                string submitted = qType == "FillBlank"
                    ? (Request.Form["fb_" + qid] ?? "")
                    : (Request.Form["q_"  + qid] ?? "");
                bool isCorrect = qType == "FillBlank"
                    ? string.Equals(submitted.Trim(), kvp.Value.Trim(), StringComparison.OrdinalIgnoreCase)
                    : string.Equals(submitted, kvp.Value, StringComparison.OrdinalIgnoreCase);

                if (isCorrect)
                {
                    string diff = diffMap.ContainsKey(qid) ? diffMap[qid] : "Medium";
                    xpEarned += diff == "Easy" ? 10 : diff == "Hard" ? 30 : 20;
                }
            }
            if (passed) xpEarned += 50;
            if (xpEarned == 0) return;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                MERGE dbo.UserXP AS target
                USING (SELECT @uid AS UserID) AS source ON target.UserID = source.UserID
                WHEN MATCHED THEN
                    UPDATE SET TotalXP = target.TotalXP + @xp,
                               Level   = (target.TotalXP + @xp) / 500 + 1,
                               UpdatedAt = GETDATE()
                WHEN NOT MATCHED THEN
                    INSERT (UserID, TotalXP, Level, UpdatedAt)
                    VALUES (@uid, @xp, @xp / 500 + 1, GETDATE());", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@xp",  xpEarned);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private static void UpdateStreak(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                MERGE dbo.UserStreaks AS target
                USING (SELECT @uid AS UserID) AS source ON target.UserID = source.UserID
                WHEN MATCHED THEN UPDATE SET
                    CurrentStreak = CASE
                        WHEN target.LastPassDate = CAST(GETDATE() AS DATE) THEN target.CurrentStreak
                        WHEN target.LastPassDate = CAST(DATEADD(day,-1,GETDATE()) AS DATE) THEN target.CurrentStreak + 1
                        ELSE 1 END,
                    LongestStreak = CASE
                        WHEN target.LastPassDate = CAST(GETDATE() AS DATE) THEN target.LongestStreak
                        WHEN target.LastPassDate = CAST(DATEADD(day,-1,GETDATE()) AS DATE)
                            THEN CASE WHEN target.CurrentStreak + 1 > target.LongestStreak
                                      THEN target.CurrentStreak + 1 ELSE target.LongestStreak END
                        ELSE CASE WHEN 1 > target.LongestStreak THEN 1 ELSE target.LongestStreak END END,
                    LastPassDate = CAST(GETDATE() AS DATE)
                WHEN NOT MATCHED THEN
                    INSERT (UserID, CurrentStreak, LongestStreak, LastPassDate)
                    VALUES (@uid, 1, 1, CAST(GETDATE() AS DATE));", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                cmd.ExecuteNonQuery();
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
