using System;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Leaderboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadLeaderboard();
        }

        private void LoadLeaderboard()
        {
            int currentUid = Session["UserID"] != null ? (int)Session["UserID"] : -1;
            var sb = new StringBuilder();

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            {
                conn.Open();

                bool currentShown = false;

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 20
                        ROW_NUMBER() OVER (ORDER BY x.TotalXP DESC) AS Rank,
                        u.UserID, u.FullName, x.TotalXP, x.Level,
                        CASE WHEN s.LastPassDate >= CAST(DATEADD(day,-1,GETDATE()) AS DATE)
                             THEN ISNULL(s.CurrentStreak,0) ELSE 0 END AS DisplayStreak
                    FROM dbo.UserXP x
                    JOIN dbo.Users u ON u.UserID = x.UserID
                    LEFT JOIN dbo.UserStreaks s ON s.UserID = x.UserID
                    WHERE u.IsActive = 1
                    ORDER BY x.TotalXP DESC", conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            int    uid    = r.GetInt32(1);
                            int    rank   = (int)r.GetInt64(0);
                            string name   = Server.HtmlEncode(r.GetString(2));
                            int    xp     = r.GetInt32(3);
                            int    level  = r.GetInt32(4);
                            int    streak = r.GetInt32(5);
                            bool   isMe   = uid == currentUid;
                            if (isMe) currentShown = true;

                            string rankClass = rank == 1 ? "rank-1" : rank == 2 ? "rank-2" : rank == 3 ? "rank-3" : "";
                            string meClass   = isMe ? " me" : "";
                            string streakStr = streak > 0 ? "&#128293; " + streak + " days" : "&#8212;";

                            sb.AppendFormat(
                                "<tr class=\"{0}{1}\"><td>{2}</td><td>{3}{4}</td>" +
                                "<td><span class=\"level-badge\">LVL {5}</span></td>" +
                                "<td><span class=\"xp-val\">{6}</span></td>" +
                                "<td class=\"streak-val\">{7}</td></tr>",
                                rankClass, meClass,
                                rank, name,
                                isMe ? " <span style=\"font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--cyber-accent);\">YOU</span>" : "",
                                level, xp, streakStr);
                        }
                    }
                }

                // If current user not in top 20, append their row with rank
                if (currentUid > 0 && !currentShown)
                {
                    using (SqlCommand cmd2 = new SqlCommand(@"
                        SELECT x.TotalXP, x.Level,
                               CASE WHEN s.LastPassDate >= CAST(DATEADD(day,-1,GETDATE()) AS DATE)
                                    THEN ISNULL(s.CurrentStreak,0) ELSE 0 END AS DisplayStreak,
                               (SELECT COUNT(*)+1 FROM dbo.UserXP WHERE TotalXP > x.TotalXP) AS Rank
                        FROM dbo.UserXP x
                        LEFT JOIN dbo.UserStreaks s ON s.UserID = x.UserID
                        WHERE x.UserID = @uid", conn))
                    {
                        cmd2.Parameters.AddWithValue("@uid", currentUid);
                        using (SqlDataReader r2 = cmd2.ExecuteReader())
                        {
                            if (r2.Read())
                            {
                                string name = Server.HtmlEncode(Session["Username"] as string ?? "You");
                                sb.Append("<tr><td colspan=\"5\" style=\"padding:2px;\"><hr class=\"lb-divider\"></td></tr>");
                                sb.AppendFormat(
                                    "<tr class=\"me\"><td>{0}</td><td>{1} <span style=\"font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--cyber-accent);\">YOU</span></td>" +
                                    "<td><span class=\"level-badge\">LVL {2}</span></td>" +
                                    "<td><span class=\"xp-val\">{3}</span></td><td class=\"streak-val\">{4}</td></tr>",
                                    r2.GetInt32(3), name, r2.GetInt32(1), r2.GetInt32(0),
                                    r2.GetInt32(2) > 0 ? "&#128293; " + r2.GetInt32(2) + " days" : "&#8212;");
                            }
                        }
                    }
                }
            }

            litRows.Text = sb.ToString();
        }
    }
}
