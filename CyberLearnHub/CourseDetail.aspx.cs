using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class CourseDetail : Page
    {
        private int _courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!int.TryParse(Request.QueryString["id"], out _courseId) || _courseId <= 0)
            {
                Response.Redirect("~/Error.aspx");
                return;
            }

            if (!IsPostBack)
                LoadCourse();
        }

        private void LoadCourse()
        {
            string sql = @"
                SELECT c.CourseID, c.Title, c.Description, c.Category,
                       c.Difficulty, c.ImageUrl,
                       (SELECT COUNT(*) FROM dbo.Enrollments WHERE CourseID = c.CourseID AND Status = 'Active') AS EnrollCount
                FROM   dbo.Courses c
                WHERE  c.CourseID = @id AND c.IsPublished = 1";

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", _courseId);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("~/Error.aspx"); return; }

                    string title     = r["Title"]      as string ?? "";
                    string desc      = r["Description"] as string ?? "";
                    string cat       = r["Category"]   as string ?? "";
                    string diff      = r["Difficulty"]  as string ?? "";
                    string thumb     = r["ImageUrl"]    as string ?? "";
                    int    enrolCount = Convert.ToInt32(r["EnrollCount"]);

                    litPageTitle.Text   = Server.HtmlEncode(title);
                    lblBreadcrumb.Text  = Server.HtmlEncode(title);
                    lblTitle.Text       = Server.HtmlEncode(title);
                    lblDescription.Text = Server.HtmlEncode(desc).Replace("\n", "<br />");
                    lblCategory.Text    = Server.HtmlEncode(cat);
                    lblDifficulty.Text  = Server.HtmlEncode(diff);
                    lblEnrolCount.Text  = enrolCount.ToString();

                    litThumb.Text = !string.IsNullOrEmpty(thumb)
                        ? "<img src=\"" + Server.HtmlEncode(ResolveUrl(thumb)) + "\" alt=\"course\" />"
                        : "<i class=\"ti ti-shield-lock\"></i>";

                    litBadges.Text = GetCategoryBadge(cat) + GetDifficultyBadge(diff);
                }
            }

            // Enrolment state
            bool enrolled = false;
            if (Session["UserID"] == null)
            {
                pnlGuest.Visible = true;
            }
            else
            {
                int uid = (int)Session["UserID"];
                enrolled = IsEnrolled(uid, _courseId);
                if (enrolled)
                    pnlEnrolled.Visible = true;
                else
                    pnlEnrolBtn.Visible = true;
            }

            // Load learning materials for enrolled users
            if (enrolled)
            {
                LoadMaterials();
                pnlMaterials.Visible = true;
            }
        }

        private void LoadMaterials()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT MaterialID, Title, MaterialType, FilePath, Content, SortOrder
                FROM   dbo.LearningMaterials
                WHERE  CourseID = @cid
                ORDER  BY SortOrder, MaterialID", conn))
            {
                cmd.Parameters.AddWithValue("@cid", _courseId);
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            lblMatCount.Text = dt.Rows.Count.ToString();

            if (dt.Rows.Count == 0)
            {
                pnlNoMaterials.Visible = true;
                return;
            }

            rptMaterials.DataSource = dt;
            rptMaterials.DataBind();
        }

        protected void btnEnrol_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("~/Login.aspx"); return; }

            int uid = (int)Session["UserID"];
            try
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO dbo.Enrollments (UserID, CourseID) VALUES (@uid, @cid)", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    cmd.Parameters.AddWithValue("@cid", _courseId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                Response.Redirect(Request.RawUrl);
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                Response.Redirect(Request.RawUrl);
            }
        }

        // ============================================================
        // Material rendering helpers (called from Repeater markup)
        // ============================================================

        protected string GetTypeIconClass(string mType)
        {
            switch (mType)
            {
                case "Video":   return "icon-video";
                case "PDF":     return "icon-pdf";
                case "Image":   return "icon-image";
                case "Link":    return "icon-link";
                default:        return "icon-article";
            }
        }

        protected string GetTypeIcon(string mType)
        {
            switch (mType)
            {
                case "Video":   return "ti ti-brand-youtube";
                case "PDF":     return "ti ti-file-type-pdf";
                case "Image":   return "ti ti-photo";
                case "Link":    return "ti ti-external-link";
                default:        return "ti ti-file-text";
            }
        }

        protected string RenderMaterialBody(string mType, string filePath, string content, string title)
        {
            var sb = new StringBuilder();

            switch (mType)
            {
                case "Video":
                    string embedUrl = GetVideoEmbedUrl(filePath ?? "");
                    if (!string.IsNullOrEmpty(embedUrl))
                    {
                        sb.Append("<div class=\"video-embed-wrap\">");
                        sb.AppendFormat("<iframe src=\"{0}\" allowfullscreen allow=\"autoplay; encrypted-media\"></iframe>",
                            Server.HtmlEncode(embedUrl));
                        sb.Append("</div>");
                    }
                    else if (!string.IsNullOrEmpty(filePath))
                    {
                        sb.AppendFormat(
                            "<div style=\"padding:16px 0;\">" +
                            "<a href=\"{0}\" target=\"_blank\" rel=\"noopener noreferrer\" " +
                            "style=\"display:inline-flex;align-items:center;gap:8px;padding:10px 20px;" +
                            "background:var(--cyber-accent);color:#080d14;font-family:'Rajdhani',sans-serif;" +
                            "font-weight:700;font-size:14px;letter-spacing:1px;border-radius:5px;" +
                            "text-decoration:none;text-transform:uppercase;\">" +
                            "<i class=\"ti ti-player-play\"></i> Watch Video" +
                            "</a></div>",
                            Server.HtmlEncode(filePath));
                    }
                    if (!string.IsNullOrEmpty(content))
                        sb.AppendFormat("<p style=\"margin-top:12px;font-size:13px;color:var(--cyber-text);line-height:1.7;\">{0}</p>",
                            Server.HtmlEncode(content));
                    break;

                case "PDF":
                    string pdfSrc = !string.IsNullOrEmpty(filePath)
                        ? (filePath.StartsWith("~/") ? ResolveUrl(filePath) : filePath)
                        : "";
                    if (!string.IsNullOrEmpty(pdfSrc))
                    {
                        sb.Append("<div class=\"pdf-viewer-wrap\">");
                        sb.AppendFormat("<iframe src=\"{0}\"></iframe>", Server.HtmlEncode(pdfSrc));
                        sb.Append("<div class=\"pdf-download-bar\">");
                        sb.Append("<span><i class=\"ti ti-file-type-pdf\"></i> PDF Document</span>");
                        sb.AppendFormat("<a href=\"{0}\" download class=\"btn-download\"><i class=\"ti ti-download\"></i> Download</a>",
                            Server.HtmlEncode(pdfSrc));
                        sb.Append("</div></div>");
                    }
                    if (!string.IsNullOrEmpty(content))
                        sb.AppendFormat("<p style=\"margin-top:12px;font-size:13px;color:var(--cyber-text);line-height:1.7;\">{0}</p>",
                            Server.HtmlEncode(content));
                    break;

                case "Image":
                    string imgSrc = !string.IsNullOrEmpty(filePath)
                        ? (filePath.StartsWith("~/") ? ResolveUrl(filePath) : filePath)
                        : "";
                    if (!string.IsNullOrEmpty(imgSrc))
                    {
                        sb.AppendFormat("<img src=\"{0}\" alt=\"{1}\" class=\"material-image\" />",
                            Server.HtmlEncode(imgSrc), Server.HtmlEncode(title ?? ""));
                    }
                    if (!string.IsNullOrEmpty(content))
                        sb.AppendFormat("<div class=\"material-caption\">{0}</div>",
                            Server.HtmlEncode(content));
                    break;

                case "Link":
                    if (!string.IsNullOrEmpty(content))
                        sb.AppendFormat("<p class=\"link-desc\">{0}</p>",
                            Server.HtmlEncode(content));
                    if (!string.IsNullOrEmpty(filePath))
                        sb.AppendFormat("<a href=\"{0}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"material-link-btn\"><i class=\"ti ti-external-link\"></i> Open Link</a>",
                            Server.HtmlEncode(filePath));
                    break;

                default: // Article
                    if (!string.IsNullOrEmpty(content))
                        sb.AppendFormat("<div class=\"article-content\">{0}</div>",
                            Server.HtmlEncode(content));
                    break;
            }

            return sb.ToString();
        }

        private static string GetVideoEmbedUrl(string url)
        {
            if (string.IsNullOrEmpty(url)) return null;

            // YouTube: watch?v=, youtu.be/, /embed/
            var ytMatch = System.Text.RegularExpressions.Regex.Match(url,
                @"(?:youtube\.com/(?:watch\?v=|embed/)|youtu\.be/)([A-Za-z0-9_\-]{11})");
            if (ytMatch.Success)
                return "https://www.youtube.com/embed/" + ytMatch.Groups[1].Value + "?rel=0";

            // Vimeo
            var vmMatch = System.Text.RegularExpressions.Regex.Match(url, @"vimeo\.com/(\d+)");
            if (vmMatch.Success)
                return "https://player.vimeo.com/video/" + vmMatch.Groups[1].Value;

            return null;
        }

        // ============================================================

        private static bool IsEnrolled(int userId, int courseId)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(1) FROM dbo.Enrollments WHERE UserID = @uid AND CourseID = @cid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@cid", courseId);
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private string GetCategoryBadge(string cat)
        {
            if (string.IsNullOrEmpty(cat)) return "";
            return string.Format("<span class=\"badge badge-cat\">{0}</span>", Server.HtmlEncode(cat));
        }

        private string GetDifficultyBadge(string level)
        {
            if (string.IsNullOrEmpty(level)) return "";
            string cls = level == "Beginner" ? "badge-beg"
                       : level == "Intermediate" ? "badge-int"
                       : "badge-adv";
            return string.Format("<span class=\"badge {0}\">{1}</span>", cls, Server.HtmlEncode(level));
        }
    }
}
