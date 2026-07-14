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

                // MIGRATION: drop old 3-level forum tables if old schema is detected
                Execute(conn, @"
                    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Forums') AND name='Name')
                    BEGIN
                        IF OBJECT_ID('dbo.DiscussionReports','U')  IS NOT NULL DROP TABLE dbo.DiscussionReports
                        IF OBJECT_ID('dbo.CommentLikes','U')       IS NOT NULL DROP TABLE dbo.CommentLikes
                        IF OBJECT_ID('dbo.DiscussionLikes','U')    IS NOT NULL DROP TABLE dbo.DiscussionLikes
                        IF OBJECT_ID('dbo.DiscussionComments','U') IS NOT NULL DROP TABLE dbo.DiscussionComments
                        IF OBJECT_ID('dbo.Discussions','U')        IS NOT NULL DROP TABLE dbo.Discussions
                        IF OBJECT_ID('dbo.Forums','U')             IS NOT NULL DROP TABLE dbo.Forums
                    END");

                // 8. dbo.ForumCategories (lookup, seeded once)
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='ForumCategories')
                    BEGIN
                        CREATE TABLE dbo.ForumCategories (
                            CategoryID INT IDENTITY(1,1) PRIMARY KEY,
                            Name       NVARCHAR(100) NOT NULL,
                            SortOrder  INT NOT NULL DEFAULT 0
                        )
                        INSERT INTO dbo.ForumCategories (Name, SortOrder) VALUES
                            ('Networking',1),('Web Security',2),('Bug',3),('Other',4)
                    END");

                // 9. dbo.Forums — the post itself (2-level model)
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='Forums')
                    CREATE TABLE dbo.Forums (
                        ForumID          INT IDENTITY(1,1) PRIMARY KEY,
                        Title            NVARCHAR(300) NOT NULL,
                        Body             NVARCHAR(MAX) NOT NULL,
                        AuthorID         INT NOT NULL,
                        CategoryID       INT NULL,
                        AttachmentPath   NVARCHAR(500) NULL,
                        AttachmentType   VARCHAR(10) NULL,
                        AdminPinnedUntil DATETIME NULL,
                        CreatedAt        DATETIME NOT NULL DEFAULT GETDATE(),
                        UpdatedAt        DATETIME NULL,
                        IsDeleted        BIT NOT NULL DEFAULT 0
                    )");

                // 10. dbo.ForumComments
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='ForumComments')
                    CREATE TABLE dbo.ForumComments (
                        CommentID       INT IDENTITY(1,1) PRIMARY KEY,
                        ForumID         INT NOT NULL,
                        ParentCommentID INT NULL,
                        AuthorID        INT NOT NULL,
                        Body            NVARCHAR(MAX) NOT NULL,
                        CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
                        UpdatedAt       DATETIME NULL,
                        IsDeleted       BIT NOT NULL DEFAULT 0,
                        PinnedByCreator BIT NOT NULL DEFAULT 0
                    )");
                // Add PinnedUntil to existing tables (idempotent)
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.columns
                                   WHERE object_id=OBJECT_ID('dbo.ForumComments') AND name='PinnedUntil')
                        ALTER TABLE dbo.ForumComments ADD PinnedUntil DATETIME NULL");

                // 11. dbo.ForumLikes
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='ForumLikes')
                    CREATE TABLE dbo.ForumLikes (
                        LikeID    INT IDENTITY(1,1) PRIMARY KEY,
                        ForumID   INT NOT NULL,
                        UserID    INT NOT NULL,
                        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
                        CONSTRAINT UQ_ForumLike UNIQUE (ForumID, UserID)
                    )");

                // 12. dbo.ForumCommentLikes
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='ForumCommentLikes')
                    CREATE TABLE dbo.ForumCommentLikes (
                        LikeID    INT IDENTITY(1,1) PRIMARY KEY,
                        CommentID INT NOT NULL,
                        UserID    INT NOT NULL,
                        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
                        CONSTRAINT UQ_ForumCommentLike UNIQUE (CommentID, UserID)
                    )");

                // 13. dbo.ForumReports
                Execute(conn, @"
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='ForumReports')
                    CREATE TABLE dbo.ForumReports (
                        ReportID   INT IDENTITY(1,1) PRIMARY KEY,
                        TargetType VARCHAR(20) NOT NULL,
                        TargetID   INT NOT NULL,
                        ReporterID INT NOT NULL,
                        Reason     NVARCHAR(500) NOT NULL,
                        CreatedAt  DATETIME NOT NULL DEFAULT GETDATE(),
                        IsResolved BIT NOT NULL DEFAULT 0
                    )");

                // Widen LearningMaterials.FilePath to handle long URLs (e.g. Bing redirect links)
                Execute(conn, @"
                    IF EXISTS (SELECT 1 FROM sys.columns
                        WHERE object_id=OBJECT_ID('dbo.LearningMaterials') AND name='FilePath'
                          AND max_length < 2048)
                    BEGIN
                        UPDATE dbo.LearningMaterials SET FilePath='' WHERE FilePath IS NULL;
                        ALTER TABLE dbo.LearningMaterials ALTER COLUMN FilePath VARCHAR(2048) NOT NULL
                    END");
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
