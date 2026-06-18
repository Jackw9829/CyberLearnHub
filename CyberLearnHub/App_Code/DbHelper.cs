using System.Configuration;
using System.Data.SqlClient;

public static class DbHelper
{
    public static string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString; }
    }

    private static volatile bool _schemaReady = false;
    private static readonly object _lock = new object();

    // Runs once per app lifetime — adds any missing columns safely
    public static void EnsureSchema()
    {
        if (_schemaReady) return;
        lock (_lock)
        {
            if (_schemaReady) return;
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                conn.Open();

                // 1. QuizQuestions.QuestionType (already exists — keep guard)
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.columns
                        WHERE object_id=OBJECT_ID('dbo.QuizQuestions') AND name='QuestionType')
                    ALTER TABLE dbo.QuizQuestions
                    ADD QuestionType VARCHAR(20) NOT NULL DEFAULT 'MultipleChoice'");

                // 2. QuizQuestions — Difficulty, Topic, Explanation
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.columns
                        WHERE object_id=OBJECT_ID('dbo.QuizQuestions') AND name='Difficulty')
                    ALTER TABLE dbo.QuizQuestions
                    ADD Difficulty VARCHAR(10) NOT NULL DEFAULT 'Medium'");

                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.columns
                        WHERE object_id=OBJECT_ID('dbo.QuizQuestions') AND name='Topic')
                    ALTER TABLE dbo.QuizQuestions
                    ADD Topic VARCHAR(100) NULL");

                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.columns
                        WHERE object_id=OBJECT_ID('dbo.QuizQuestions') AND name='Explanation')
                    ALTER TABLE dbo.QuizQuestions
                    ADD Explanation NVARCHAR(1000) NULL");

                // 3. Quizzes — TimeLimitMinutes, MaxAttempts, RandomizeQuestions
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.columns
                        WHERE object_id=OBJECT_ID('dbo.Quizzes') AND name='TimeLimitMinutes')
                    ALTER TABLE dbo.Quizzes
                    ADD TimeLimitMinutes INT NULL");

                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.columns
                        WHERE object_id=OBJECT_ID('dbo.Quizzes') AND name='MaxAttempts')
                    ALTER TABLE dbo.Quizzes
                    ADD MaxAttempts INT NULL");

                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.columns
                        WHERE object_id=OBJECT_ID('dbo.Quizzes') AND name='RandomizeQuestions')
                    ALTER TABLE dbo.Quizzes
                    ADD RandomizeQuestions BIT NOT NULL DEFAULT 0");

                // 4. dbo.QuizAnswers
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='QuizAnswers')
                    CREATE TABLE dbo.QuizAnswers (
                        AnswerID        INT IDENTITY(1,1) PRIMARY KEY,
                        ResultID        INT NOT NULL,
                        QuestionID      INT NOT NULL,
                        SubmittedAnswer VARCHAR(500) NOT NULL DEFAULT '',
                        IsCorrect       BIT NOT NULL
                    )");

                // 5. dbo.UserXP
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='UserXP')
                    CREATE TABLE dbo.UserXP (
                        UserID    INT PRIMARY KEY,
                        TotalXP   INT NOT NULL DEFAULT 0,
                        Level     INT NOT NULL DEFAULT 1,
                        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
                    )");

                // 6. dbo.UserStreaks
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='UserStreaks')
                    CREATE TABLE dbo.UserStreaks (
                        UserID        INT PRIMARY KEY,
                        CurrentStreak INT NOT NULL DEFAULT 0,
                        LongestStreak INT NOT NULL DEFAULT 0,
                        LastPassDate  DATE NULL
                    )");

                // 7. dbo.Certificates
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='Certificates')
                    CREATE TABLE dbo.Certificates (
                        CertificateID INT IDENTITY(1,1) PRIMARY KEY,
                        UserID        INT NOT NULL,
                        CourseID      INT NOT NULL,
                        QuizID        INT NOT NULL,
                        ResultID      INT NOT NULL,
                        IssuedDate    DATETIME NOT NULL DEFAULT GETDATE(),
                        FilePath      VARCHAR(500) NOT NULL,
                        CONSTRAINT UQ_Cert_UserCourse UNIQUE (UserID, CourseID)
                    )");
            }
            _schemaReady = true;
        }
    }

    private static void Execute(SqlConnection conn, string sql)
    {
        using (SqlCommand cmd = new SqlCommand(sql, conn))
            cmd.ExecuteNonQuery();
    }
}
