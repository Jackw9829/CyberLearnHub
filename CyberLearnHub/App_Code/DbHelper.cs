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
                Execute(conn, @"
                    IF NOT EXISTS (
                        SELECT 1 FROM sys.columns
                        WHERE object_id = OBJECT_ID('dbo.QuizQuestions')
                          AND name = 'QuestionType')
                    ALTER TABLE dbo.QuizQuestions
                    ADD QuestionType VARCHAR(20) NOT NULL DEFAULT 'MultipleChoice'");
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
