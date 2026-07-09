using System;

public static class ForumHelpers
{
    public static string FormatDisplayName(string displayName, int userId)
    {
        if (string.IsNullOrWhiteSpace(displayName))
            displayName = "Unknown User";
        return displayName + " #" + userId.ToString().PadLeft(4, '0');
    }

    public static string TimeAgo(DateTime dt)
    {
        TimeSpan diff = DateTime.UtcNow - dt.ToUniversalTime();
        if (diff.TotalSeconds < 60) return "just now";
        if (diff.TotalMinutes < 60) return (int)diff.TotalMinutes + "m ago";
        if (diff.TotalHours < 24)   return (int)diff.TotalHours   + "h ago";
        if (diff.TotalDays < 7)     return (int)diff.TotalDays    + "d ago";
        if (diff.TotalDays < 30)    return (int)(diff.TotalDays / 7) + "w ago";
        if (diff.TotalDays < 365)   return (int)(diff.TotalDays / 30) + "mo ago";
        return (int)(diff.TotalDays / 365) + "y ago";
    }

    public static string Initials(string fullName)
    {
        if (string.IsNullOrWhiteSpace(fullName)) return "?";
        var parts = fullName.Trim().Split(new char[]{' '}, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
        return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
    }
}
