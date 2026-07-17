using System;
using System.Collections.Generic;
using System.Data.SqlClient;

// ─── DTOs ────────────────────────────────────────────────────────────────────
public class ForumRow
{
    public int       ForumID          { get; set; }
    public int       AuthorID         { get; set; }
    public int       LikeCount        { get; set; }
    public int       CommentCount     { get; set; }
    public int?      CategoryID       { get; set; }
    public string    Title            { get; set; }
    public string    Body             { get; set; }
    public string    AuthorName       { get; set; }
    public string    AuthorImage      { get; set; }
    public string    CategoryName     { get; set; }
    public string    AttachmentPath   { get; set; }
    public string    AttachmentType   { get; set; }
    public DateTime  CreatedAt        { get; set; }
    public DateTime? UpdatedAt        { get; set; }
    public DateTime? AdminPinnedUntil { get; set; }
    public bool      IsDeleted        { get; set; }

    public bool IsAdminPinned =>
        AdminPinnedUntil.HasValue && AdminPinnedUntil.Value > DateTime.UtcNow;

    public int PinDaysLeft =>
        AdminPinnedUntil.HasValue
            ? Math.Max(0, (int)(AdminPinnedUntil.Value - DateTime.UtcNow).TotalDays)
            : 0;
}

public class CommentRow
{
    public int       CommentID       { get; set; }
    public int       ForumID         { get; set; }
    public int       AuthorID        { get; set; }
    public int       LikeCount       { get; set; }
    public int?      ParentCommentID { get; set; }
    public string    Body            { get; set; }
    public string    AuthorName      { get; set; }
    public string    AuthorImage     { get; set; }
    public DateTime  CreatedAt       { get; set; }
    public DateTime? UpdatedAt       { get; set; }
    public bool      IsDeleted       { get; set; }
    public bool      PinnedByCreator { get; set; }
    public DateTime? PinnedUntil     { get; set; }
    public List<CommentRow> Replies  { get; set; } = new List<CommentRow>();

    // True only while the pin expiry is still in the future (or no expiry set = permanent)
    public bool IsPinActive =>
        PinnedByCreator && (!PinnedUntil.HasValue || PinnedUntil.Value > DateTime.UtcNow);
}

public class CategoryRow
{
    public int    CategoryID { get; set; }
    public string Name       { get; set; }
}

// ─── DAL ─────────────────────────────────────────────────────────────────────
public static class ForumDAL
{
    public static SqlConnection OpenConnection() => Open();

    private static SqlConnection Open()
    {
        DbHelper.EnsureSchema();
        var conn = new SqlConnection(DbHelper.ConnectionString);
        conn.Open();
        return conn;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // FORUMS
    // ══════════════════════════════════════════════════════════════════════════

    public static List<ForumRow> GetAllForums(string sort = "recent", int? userId = null)
    {
        string orderBy;
        switch ((sort ?? "recent").ToLower())
        {
            case "liked":   orderBy = "LikeCount DESC, f.CreatedAt DESC";    break;
            case "replied": orderBy = "CommentCount DESC, f.CreatedAt DESC"; break;
            default:        orderBy = "f.CreatedAt DESC";                    break;
        }

        string whereExtra = (sort == "mine" && userId.HasValue) ? " AND f.AuthorID = @uid" : "";

        string sql = $@"
            SELECT f.ForumID, f.Title, f.Body, f.AuthorID, f.CategoryID,
                   f.AttachmentPath, f.AttachmentType, f.AdminPinnedUntil,
                   f.CreatedAt, f.UpdatedAt, f.IsDeleted,
                   u.FullName AS AuthorName, u.ProfileImage AS AuthorImage,
                   c.Name AS CategoryName,
                   (SELECT COUNT(*) FROM dbo.ForumLikes    l  WHERE l.ForumID  = f.ForumID) AS LikeCount,
                   (SELECT COUNT(*) FROM dbo.ForumComments fc WHERE fc.ForumID = f.ForumID AND fc.IsDeleted = 0) AS CommentCount
            FROM   dbo.Forums f
            JOIN   dbo.Users u ON u.UserID = f.AuthorID
            LEFT JOIN dbo.ForumCategories c ON c.CategoryID = f.CategoryID
            WHERE  f.IsDeleted = 0{whereExtra}
            ORDER BY
                CASE WHEN f.AdminPinnedUntil IS NOT NULL AND f.AdminPinnedUntil > GETDATE() THEN 0 ELSE 1 END ASC,
                {orderBy}";

        var list = new List<ForumRow>();
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            if (whereExtra.Length > 0)
                cmd.Parameters.AddWithValue("@uid", userId ?? 0);
            using (var rdr = cmd.ExecuteReader())
                while (rdr.Read())
                    list.Add(ReadForumRow(rdr));
        }
        return list;
    }

    public static List<ForumRow> GetAllForumsAdmin()
    {
        const string sql = @"
            SELECT f.ForumID, f.Title, f.Body, f.AuthorID, f.CategoryID,
                   f.AttachmentPath, f.AttachmentType, f.AdminPinnedUntil,
                   f.CreatedAt, f.UpdatedAt, f.IsDeleted,
                   u.FullName AS AuthorName, u.ProfileImage AS AuthorImage,
                   c.Name AS CategoryName,
                   (SELECT COUNT(*) FROM dbo.ForumLikes    l  WHERE l.ForumID  = f.ForumID) AS LikeCount,
                   (SELECT COUNT(*) FROM dbo.ForumComments fc WHERE fc.ForumID = f.ForumID AND fc.IsDeleted = 0) AS CommentCount
            FROM   dbo.Forums f
            JOIN   dbo.Users u ON u.UserID = f.AuthorID
            LEFT JOIN dbo.ForumCategories c ON c.CategoryID = f.CategoryID
            ORDER BY f.IsDeleted ASC, f.CreatedAt DESC";

        var list = new List<ForumRow>();
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        using (var rdr  = cmd.ExecuteReader())
            while (rdr.Read())
                list.Add(ReadForumRow(rdr));
        return list;
    }

    public static ForumRow GetForumById(int forumId)
    {
        const string sql = @"
            SELECT f.ForumID, f.Title, f.Body, f.AuthorID, f.CategoryID,
                   f.AttachmentPath, f.AttachmentType, f.AdminPinnedUntil,
                   f.CreatedAt, f.UpdatedAt, f.IsDeleted,
                   u.FullName AS AuthorName, u.ProfileImage AS AuthorImage,
                   c.Name AS CategoryName,
                   (SELECT COUNT(*) FROM dbo.ForumLikes    l  WHERE l.ForumID  = f.ForumID) AS LikeCount,
                   (SELECT COUNT(*) FROM dbo.ForumComments fc WHERE fc.ForumID = f.ForumID AND fc.IsDeleted = 0) AS CommentCount
            FROM   dbo.Forums f
            JOIN   dbo.Users u ON u.UserID = f.AuthorID
            LEFT JOIN dbo.ForumCategories c ON c.CategoryID = f.CategoryID
            WHERE  f.ForumID = @id";
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@id", forumId);
            using (var rdr = cmd.ExecuteReader())
                return rdr.Read() ? ReadForumRow(rdr) : null;
        }
    }

    public static int CreateForum(string title, string body, int authorId,
                                   int? categoryId, string attachPath, string attachType)
    {
        const string sql = @"
            INSERT INTO dbo.Forums (Title, Body, AuthorID, CategoryID, AttachmentPath, AttachmentType)
            OUTPUT INSERTED.ForumID
            VALUES (@title, @body, @authorId, @catId, @attach, @attachType)";
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@title",      title);
            cmd.Parameters.AddWithValue("@body",       body);
            cmd.Parameters.AddWithValue("@authorId",   authorId);
            cmd.Parameters.AddWithValue("@catId",      (object)categoryId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@attach",     (object)attachPath ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@attachType", (object)attachType ?? DBNull.Value);
            return (int)cmd.ExecuteScalar();
        }
    }

    public static void UpdateForum(int forumId, string title, string body,
                                    int? categoryId, int requestingUserId, bool isAdmin,
                                    string attachPath = null, string attachType = null)
    {
        var f = GetForumById(forumId);
        if (f == null) throw new Exception("Forum not found.");
        if (!isAdmin && f.AuthorID != requestingUserId) throw new UnauthorizedAccessException();

        string sql = attachPath != null
            ? @"UPDATE dbo.Forums SET Title=@title, Body=@body, CategoryID=@catId,
                    AttachmentPath=@attach, AttachmentType=@attachType, UpdatedAt=GETDATE()
                WHERE ForumID=@id"
            : @"UPDATE dbo.Forums SET Title=@title, Body=@body, CategoryID=@catId, UpdatedAt=GETDATE()
                WHERE ForumID=@id";

        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@title", title);
            cmd.Parameters.AddWithValue("@body",  body);
            cmd.Parameters.AddWithValue("@catId", (object)categoryId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@id",    forumId);
            if (attachPath != null)
            {
                cmd.Parameters.AddWithValue("@attach",     attachPath);
                cmd.Parameters.AddWithValue("@attachType", (object)attachType ?? DBNull.Value);
            }
            cmd.ExecuteNonQuery();
        }
    }

    public static void SoftDeleteForum(int forumId, int requestingUserId, bool isAdmin)
    {
        var f = GetForumById(forumId);
        if (f == null) return;
        if (!isAdmin && f.AuthorID != requestingUserId) throw new UnauthorizedAccessException();
        using (var conn = Open())
        using (var cmd  = new SqlCommand("UPDATE dbo.Forums SET IsDeleted=1 WHERE ForumID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", forumId);
            cmd.ExecuteNonQuery();
        }
    }

    public static void RestoreForum(int forumId)
    {
        using (var conn = Open())
        using (var cmd  = new SqlCommand("UPDATE dbo.Forums SET IsDeleted=0 WHERE ForumID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", forumId);
            cmd.ExecuteNonQuery();
        }
    }

    public static void HardDeleteForum(int forumId)
    {
        using (var conn = Open())
        {
            ExecId(conn, "DELETE FROM dbo.ForumReports      WHERE TargetID=@id AND TargetType='Forum'", forumId);
            ExecId(conn, @"DELETE FROM dbo.ForumCommentLikes
                           WHERE CommentID IN (SELECT CommentID FROM dbo.ForumComments WHERE ForumID=@id)", forumId);
            ExecId(conn, @"DELETE FROM dbo.ForumReports
                           WHERE TargetType='Comment' AND TargetID IN
                               (SELECT CommentID FROM dbo.ForumComments WHERE ForumID=@id)", forumId);
            ExecId(conn, "DELETE FROM dbo.ForumComments WHERE ForumID=@id", forumId);
            ExecId(conn, "DELETE FROM dbo.ForumLikes    WHERE ForumID=@id", forumId);
            ExecId(conn, "DELETE FROM dbo.Forums        WHERE ForumID=@id", forumId);
        }
    }

    public static void PinForumAdmin(int forumId, DateTime until)
    {
        using (var conn = Open())
        using (var cmd  = new SqlCommand("UPDATE dbo.Forums SET AdminPinnedUntil=@until WHERE ForumID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@until", until);
            cmd.Parameters.AddWithValue("@id",    forumId);
            cmd.ExecuteNonQuery();
        }
    }

    public static void UnpinForumAdmin(int forumId)
    {
        using (var conn = Open())
        using (var cmd  = new SqlCommand("UPDATE dbo.Forums SET AdminPinnedUntil=NULL WHERE ForumID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", forumId);
            cmd.ExecuteNonQuery();
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // CATEGORIES
    // ══════════════════════════════════════════════════════════════════════════

    public static List<CategoryRow> GetCategories()
    {
        var list = new List<CategoryRow>();
        using (var conn = Open())
        using (var cmd  = new SqlCommand(
            "SELECT CategoryID, Name FROM dbo.ForumCategories ORDER BY SortOrder, Name", conn))
        using (var rdr = cmd.ExecuteReader())
            while (rdr.Read())
                list.Add(new CategoryRow
                {
                    CategoryID = (int)rdr["CategoryID"],
                    Name       = rdr["Name"].ToString()
                });
        return list;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // COMMENTS
    // ══════════════════════════════════════════════════════════════════════════

    public static List<CommentRow> GetComments(int forumId)
    {
        const string sql = @"
            SELECT c.CommentID, c.ForumID, c.ParentCommentID, c.AuthorID,
                   c.Body, c.CreatedAt, c.UpdatedAt, c.IsDeleted,
                   c.PinnedByCreator, c.PinnedUntil,
                   u.FullName AS AuthorName, u.ProfileImage AS AuthorImage,
                   (SELECT COUNT(*) FROM dbo.ForumCommentLikes l WHERE l.CommentID = c.CommentID) AS LikeCount
            FROM   dbo.ForumComments c
            JOIN   dbo.Users u ON u.UserID = c.AuthorID
            WHERE  c.ForumID = @fid
            ORDER  BY
                CASE WHEN c.PinnedByCreator=1 AND (c.PinnedUntil IS NULL OR c.PinnedUntil > GETDATE()) THEN 0 ELSE 1 END,
                c.CreatedAt ASC";

        var all = new List<CommentRow>();
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@fid", forumId);
            using (var rdr = cmd.ExecuteReader())
                while (rdr.Read())
                    all.Add(ReadCommentRow(rdr));
        }

        var byId     = new Dictionary<int, CommentRow>();
        var topLevel = new List<CommentRow>();
        foreach (var c in all) byId[c.CommentID] = c;
        foreach (var c in all)
        {
            if (c.ParentCommentID.HasValue && byId.ContainsKey(c.ParentCommentID.Value))
                byId[c.ParentCommentID.Value].Replies.Add(c);
            else
                topLevel.Add(c);
        }
        return topLevel;
    }

    public static CommentRow GetCommentById(int commentId)
    {
        const string sql = @"
            SELECT c.CommentID, c.ForumID, c.ParentCommentID, c.AuthorID,
                   c.Body, c.CreatedAt, c.UpdatedAt, c.IsDeleted,
                   c.PinnedByCreator, c.PinnedUntil,
                   u.FullName AS AuthorName, u.ProfileImage AS AuthorImage,
                   (SELECT COUNT(*) FROM dbo.ForumCommentLikes l WHERE l.CommentID = c.CommentID) AS LikeCount
            FROM   dbo.ForumComments c
            JOIN   dbo.Users u ON u.UserID = c.AuthorID
            WHERE  c.CommentID = @id";
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@id", commentId);
            using (var rdr = cmd.ExecuteReader())
                return rdr.Read() ? ReadCommentRow(rdr) : null;
        }
    }

    public static int AddComment(int forumId, int? parentId, int authorId, string body)
    {
        const string sql = @"
            INSERT INTO dbo.ForumComments (ForumID, ParentCommentID, AuthorID, Body)
            OUTPUT INSERTED.CommentID
            VALUES (@fid, @parent, @authorId, @body)";
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@fid",      forumId);
            cmd.Parameters.AddWithValue("@parent",   (object)parentId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@authorId", authorId);
            cmd.Parameters.AddWithValue("@body",     body);
            return (int)cmd.ExecuteScalar();
        }
    }

    public static void UpdateComment(int commentId, string body, int requestingUserId, bool isAdmin)
    {
        var c = GetCommentById(commentId);
        if (c == null) throw new Exception("Comment not found.");
        if (!isAdmin && c.AuthorID != requestingUserId) throw new UnauthorizedAccessException();
        const string sql = "UPDATE dbo.ForumComments SET Body=@body, UpdatedAt=GETDATE() WHERE CommentID=@id";
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@body", body);
            cmd.Parameters.AddWithValue("@id",   commentId);
            cmd.ExecuteNonQuery();
        }
    }

    public static void SoftDeleteComment(int commentId, int requestingUserId, bool isAdmin)
    {
        var c = GetCommentById(commentId);
        if (c == null) return;
        if (!isAdmin && c.AuthorID != requestingUserId) throw new UnauthorizedAccessException();
        using (var conn = Open())
        using (var cmd  = new SqlCommand("UPDATE dbo.ForumComments SET IsDeleted=1 WHERE CommentID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", commentId);
            cmd.ExecuteNonQuery();
        }
    }

    public static void PinCommentByCreator(int commentId, int forumId, int requestingUserId, DateTime? pinUntil = null)
    {
        var forum = GetForumById(forumId);
        // Only the forum's own author may pin a comment; admins cannot pin in someone else's forum
        if (forum == null || forum.AuthorID != requestingUserId) throw new UnauthorizedAccessException();
        using (var conn = Open())
        {
            // Clear any existing pin on this forum's comments
            ExecId(conn, "UPDATE dbo.ForumComments SET PinnedByCreator=0, PinnedUntil=NULL WHERE ForumID=@id", forumId);
            using (var cmd = new SqlCommand(
                "UPDATE dbo.ForumComments SET PinnedByCreator=1, PinnedUntil=@until WHERE CommentID=@cid", conn))
            {
                cmd.Parameters.AddWithValue("@cid",   commentId);
                cmd.Parameters.AddWithValue("@until", (object)pinUntil ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
    }

    public static void UnpinCommentByCreator(int commentId, int forumId, int requestingUserId)
    {
        var forum = GetForumById(forumId);
        if (forum == null || forum.AuthorID != requestingUserId) throw new UnauthorizedAccessException();
        using (var conn = Open())
        using (var cmd  = new SqlCommand(
            "UPDATE dbo.ForumComments SET PinnedByCreator=0 WHERE CommentID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", commentId);
            cmd.ExecuteNonQuery();
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // LIKES
    // ══════════════════════════════════════════════════════════════════════════

    public static bool ToggleForumLike(int forumId, int userId)
    {
        if (HasUserLikedForum(forumId, userId))
        {
            using (var conn = Open())
            using (var cmd  = new SqlCommand(
                "DELETE FROM dbo.ForumLikes WHERE ForumID=@f AND UserID=@u", conn))
            {
                cmd.Parameters.AddWithValue("@f", forumId);
                cmd.Parameters.AddWithValue("@u", userId);
                cmd.ExecuteNonQuery();
            }
            return false;
        }
        using (var conn = Open())
        using (var cmd  = new SqlCommand(
            "INSERT INTO dbo.ForumLikes (ForumID, UserID) VALUES (@f, @u)", conn))
        {
            cmd.Parameters.AddWithValue("@f", forumId);
            cmd.Parameters.AddWithValue("@u", userId);
            cmd.ExecuteNonQuery();
        }
        return true;
    }

    public static bool HasUserLikedForum(int forumId, int userId)
    {
        using (var conn = Open())
        using (var cmd  = new SqlCommand(
            "SELECT COUNT(*) FROM dbo.ForumLikes WHERE ForumID=@f AND UserID=@u", conn))
        {
            cmd.Parameters.AddWithValue("@f", forumId);
            cmd.Parameters.AddWithValue("@u", userId);
            return (int)cmd.ExecuteScalar() > 0;
        }
    }

    public static bool ToggleCommentLike(int commentId, int userId)
    {
        bool liked;
        using (var conn = Open())
        using (var cmd  = new SqlCommand(
            "SELECT COUNT(*) FROM dbo.ForumCommentLikes WHERE CommentID=@c AND UserID=@u", conn))
        {
            cmd.Parameters.AddWithValue("@c", commentId);
            cmd.Parameters.AddWithValue("@u", userId);
            liked = (int)cmd.ExecuteScalar() > 0;
        }
        if (liked)
        {
            using (var conn = Open())
            using (var cmd  = new SqlCommand(
                "DELETE FROM dbo.ForumCommentLikes WHERE CommentID=@c AND UserID=@u", conn))
            {
                cmd.Parameters.AddWithValue("@c", commentId);
                cmd.Parameters.AddWithValue("@u", userId);
                cmd.ExecuteNonQuery();
            }
            return false;
        }
        using (var conn = Open())
        using (var cmd  = new SqlCommand(
            "INSERT INTO dbo.ForumCommentLikes (CommentID, UserID) VALUES (@c, @u)", conn))
        {
            cmd.Parameters.AddWithValue("@c", commentId);
            cmd.Parameters.AddWithValue("@u", userId);
            cmd.ExecuteNonQuery();
        }
        return true;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // REPORTS
    // ══════════════════════════════════════════════════════════════════════════

    public static void ReportContent(string targetType, int targetId, int reporterId, string reason)
    {
        const string sql = @"
            INSERT INTO dbo.ForumReports (TargetType, TargetID, ReporterID, Reason)
            VALUES (@type, @tid, @rid, @reason)";
        using (var conn = Open())
        using (var cmd  = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@type",   targetType);
            cmd.Parameters.AddWithValue("@tid",    targetId);
            cmd.Parameters.AddWithValue("@rid",    reporterId);
            cmd.Parameters.AddWithValue("@reason", reason);
            cmd.ExecuteNonQuery();
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // PRIVATE HELPERS
    // ══════════════════════════════════════════════════════════════════════════

    private static ForumRow ReadForumRow(SqlDataReader r) => new ForumRow
    {
        ForumID          = (int)r["ForumID"],
        Title            = r["Title"].ToString(),
        Body             = r["Body"].ToString(),
        AuthorID         = (int)r["AuthorID"],
        AuthorName       = r["AuthorName"].ToString(),
        AuthorImage      = r["AuthorImage"]      as string,
        CategoryID       = r["CategoryID"]       as int?,
        CategoryName     = r["CategoryName"]     as string,
        AttachmentPath   = r["AttachmentPath"]   as string,
        AttachmentType   = r["AttachmentType"]   as string,
        AdminPinnedUntil = r["AdminPinnedUntil"] as DateTime?,
        CreatedAt        = (DateTime)r["CreatedAt"],
        UpdatedAt        = r["UpdatedAt"]        as DateTime?,
        IsDeleted        = (bool)r["IsDeleted"],
        LikeCount        = (int)r["LikeCount"],
        CommentCount     = (int)r["CommentCount"]
    };

    private static CommentRow ReadCommentRow(SqlDataReader r) => new CommentRow
    {
        CommentID       = (int)r["CommentID"],
        ForumID         = (int)r["ForumID"],
        ParentCommentID = r["ParentCommentID"] as int?,
        AuthorID        = (int)r["AuthorID"],
        AuthorName      = r["AuthorName"].ToString(),
        AuthorImage     = r["AuthorImage"] as string,
        Body            = r["Body"].ToString(),
        CreatedAt       = (DateTime)r["CreatedAt"],
        UpdatedAt       = r["UpdatedAt"] as DateTime?,
        IsDeleted       = (bool)r["IsDeleted"],
        PinnedByCreator = (bool)r["PinnedByCreator"],
        PinnedUntil     = r["PinnedUntil"] as DateTime?,
        LikeCount       = (int)r["LikeCount"]
    };

    private static void ExecId(SqlConnection conn, string sql, int id)
    {
        using (var cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@id", id);
            cmd.ExecuteNonQuery();
        }
    }
}
