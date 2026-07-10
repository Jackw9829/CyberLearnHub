using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Admin
{
    public partial class ManageForumReports : AdminBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadReports();
        }

        private void LoadReports()
        {
            string filter = ddlFilter.SelectedValue;
            string type   = ddlType.SelectedValue;

            var reports = GetReports(filter, type);

            lblCount.Text = $"&gt; {reports.Count} report{(reports.Count == 1 ? "" : "s")}";

            if (reports.Count == 0)
            {
                pnlEmpty.Visible = true;
                pnlTable.Visible = false;
            }
            else
            {
                pnlEmpty.Visible = false;
                pnlTable.Visible = true;
                rptReports.DataSource = reports;
                rptReports.DataBind();
            }
        }

        protected void ddlFilter_Changed(object sender, EventArgs e) => LoadReports();
        protected void ddlType_Changed(object sender, EventArgs e)   => LoadReports();

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int reportId = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Resolve")
                SetResolved(reportId, true);
            else if (e.CommandName == "Unresolve")
                SetResolved(reportId, false);
            else if (e.CommandName == "Delete")
                DeleteReport(reportId);

            LoadReports();
        }

        protected string GetViewLink(string targetType, int targetId, int forumId)
        {
            if (targetType == "Forum")
                return ResolveUrl($"~/Forum/ThreadDetail.aspx?id={targetId}");
            return ResolveUrl($"~/Forum/ThreadDetail.aspx?id={forumId}#comment-{targetId}");
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "forum-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }

        // ── DAL ──────────────────────────────────────────────────────────────

        private List<ReportRow> GetReports(string filter, string type)
        {
            var list = new List<ReportRow>();

            string whereFilter = filter == "open"     ? "AND r.IsResolved = 0"
                               : filter == "resolved" ? "AND r.IsResolved = 1"
                               : "";
            string whereType   = type == "Forum"   ? "AND r.TargetType = 'Forum'"
                               : type == "Comment" ? "AND r.TargetType = 'Comment'"
                               : "";

            string sql = $@"
                SELECT
                    r.ReportID, r.TargetType, r.TargetID, r.Reason, r.CreatedAt, r.IsResolved,
                    ru.FullName  AS ReporterName,
                    -- content preview and author
                    CASE r.TargetType
                        WHEN 'Forum'   THEN LEFT(f.Title, 80)
                        WHEN 'Comment' THEN LEFT(fc.Body,  80)
                        ELSE ''
                    END AS ContentPreview,
                    CASE r.TargetType
                        WHEN 'Forum'   THEN fu.FullName
                        WHEN 'Comment' THEN cu.FullName
                        ELSE ''
                    END AS ContentAuthor,
                    CASE r.TargetType
                        WHEN 'Forum'   THEN r.TargetID
                        WHEN 'Comment' THEN fc.ForumID
                        ELSE 0
                    END AS ForumID
                FROM dbo.ForumReports r
                LEFT JOIN dbo.Users   ru ON ru.UserID = r.ReporterID
                LEFT JOIN dbo.Forums  f  ON r.TargetType='Forum'   AND f.ForumID   = r.TargetID
                LEFT JOIN dbo.Users   fu ON fu.UserID = f.AuthorID
                LEFT JOIN dbo.ForumComments fc ON r.TargetType='Comment' AND fc.CommentID = r.TargetID
                LEFT JOIN dbo.Users   cu ON cu.UserID = fc.AuthorID
                WHERE 1=1 {whereFilter} {whereType}
                ORDER BY r.IsResolved ASC, r.CreatedAt DESC";

            using (var conn = ForumDAL.OpenConnection())
            using (var cmd  = new SqlCommand(sql, conn))
            using (var rdr  = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    list.Add(new ReportRow
                    {
                        ReportID      = (int)rdr["ReportID"],
                        TargetType    = rdr["TargetType"].ToString(),
                        TargetID      = (int)rdr["TargetID"],
                        ForumID       = (int)rdr["ForumID"],
                        Reason        = rdr["Reason"].ToString(),
                        CreatedAt     = (DateTime)rdr["CreatedAt"],
                        IsResolved    = (bool)rdr["IsResolved"],
                        ReporterName  = rdr["ReporterName"] as string ?? "Unknown",
                        ContentPreview = rdr["ContentPreview"]?.ToString() ?? "(deleted)",
                        ContentAuthor  = rdr["ContentAuthor"]?.ToString()  ?? "Unknown",
                    });
                }
            }
            return list;
        }

        private void SetResolved(int reportId, bool resolved)
        {
            using (var conn = ForumDAL.OpenConnection())
            using (var cmd  = new SqlCommand("UPDATE dbo.ForumReports SET IsResolved=@v WHERE ReportID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@v",  resolved ? 1 : 0);
                cmd.Parameters.AddWithValue("@id", reportId);
                cmd.ExecuteNonQuery();
            }
        }

        private void DeleteReport(int reportId)
        {
            using (var conn = ForumDAL.OpenConnection())
            using (var cmd  = new SqlCommand("DELETE FROM dbo.ForumReports WHERE ReportID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@id", reportId);
                cmd.ExecuteNonQuery();
            }
        }
    }

    public class ReportRow
    {
        public int      ReportID       { get; set; }
        public string   TargetType     { get; set; }
        public int      TargetID       { get; set; }
        public int      ForumID        { get; set; }
        public string   Reason         { get; set; }
        public DateTime CreatedAt      { get; set; }
        public bool     IsResolved     { get; set; }
        public string   ReporterName   { get; set; }
        public string   ContentPreview { get; set; }
        public string   ContentAuthor  { get; set; }
    }
}
