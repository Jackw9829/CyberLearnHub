using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Forum
{
    public partial class Index : Page
    {
        // exposed to ASPX for sort pills and admin menu rendering
        public string ActiveSort { get; private set; } = "recent";
        public bool   IsAdmin    { get; private set; }

        private int CurrentUserId => Session["UserID"] != null ? (int)Session["UserID"] : 0;

        // Blocked file extensions (security — Fix 7)
        private static readonly HashSet<string> BlockedExts = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".exe", ".bat", ".cmd", ".sh", ".ps1", ".vbs", ".php", ".asp", ".aspx",
            ".py", ".rb", ".pl", ".com", ".dll", ".msi", ".jar", ".scr", ".hta",
            ".wsf", ".pif", ".reg", ".cpl", ".inf", ".lnk"
        };

        // Extension → accepted MIME types (Fix 7)
        private static readonly Dictionary<string, string[]> AllowedExtMimes =
            new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            { ".jpg",  new[] { "image/jpeg" } },
            { ".jpeg", new[] { "image/jpeg" } },
            { ".png",  new[] { "image/png"  } },
            { ".gif",  new[] { "image/gif"  } },
            { ".webp", new[] { "image/webp" } },
            { ".pdf",  new[] { "application/pdf" } },
            { ".docx", new[] { "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                               "application/octet-stream", "application/zip" } },
            { ".doc",  new[] { "application/msword", "application/octet-stream" } },
            { ".xlsx", new[] { "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                               "application/octet-stream", "application/zip" } },
            { ".pptx", new[] { "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                               "application/octet-stream", "application/zip" } },
        };

        private static readonly HashSet<string> ImageExts = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            { ".jpg", ".jpeg", ".png", ".gif", ".webp" };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
                Response.Redirect("~/Login.aspx?returnUrl=" + HttpUtility.UrlEncode(Request.RawUrl));

            IsAdmin    = Session["Role"] as string == "Admin";
            ActiveSort = (Request.QueryString["sort"] ?? "recent").ToLower();

            if (!IsPostBack)
            {
                LoadForums();
                LoadCategoryDropdown();

                if (Request.QueryString["created"] == "1")
                    ShowAlert("&gt; Post created.", true);
            }
        }

        private void LoadForums()
        {
            var sort   = ActiveSort;
            int? uid   = sort == "mine" ? (int?)CurrentUserId : null;
            var forums = ForumDAL.GetAllForums(sort, uid);
            if (forums.Count == 0) { pnlEmpty.Visible = true; return; }
            pnlEmpty.Visible     = false;
            rptForums.DataSource = forums;
            rptForums.DataBind();
        }

        private void LoadCategoryDropdown()
        {
            ddlCategory.Items.Clear();
            ddlCategory.Items.Add(new ListItem("— No category —", ""));
            foreach (var cat in ForumDAL.GetCategories())
                ddlCategory.Items.Add(new ListItem(cat.Name, cat.CategoryID.ToString()));
        }

        // Render avatar: profile photo if available, else initials
        protected string RenderAvatar(string imgPath, string name, string size = "xs")
        {
            if (!string.IsNullOrEmpty(imgPath))
                return "<img src=\"" + ResolveUrl(imgPath) + "\" class=\"avatar avatar-" + size + " avatar-photo\" alt=\"\" />";
            return "<span class=\"avatar avatar-" + size + "\">" + Server.HtmlEncode(ForumHelpers.Initials(name)) + "</span>";
        }

        // helper called from ASPX for excerpt truncation
        protected string TruncateBody(string body, int maxLen)
        {
            if (string.IsNullOrEmpty(body)) return "";
            return body.Length <= maxLen ? body : body.Substring(0, maxLen) + "…";
        }

        // ── CREATE (Fix 2: any authenticated user) ────────────────────────────

        protected void btnCreateForum_Click(object sender, EventArgs e)
        {
            ViewState["ModalOpen"] = true;

            string title = txtTitle.Text.Trim();
            string body  = txtBody.Text.Trim();

            if (string.IsNullOrEmpty(title))
            {
                ShowModalAlert("&gt; Title is required.", false);
                LoadCategoryDropdown(); LoadForums(); return;
            }
            if (string.IsNullOrEmpty(body))
            {
                ShowModalAlert("&gt; Body is required.", false);
                LoadCategoryDropdown(); LoadForums(); return;
            }

            int? catId = null;
            if (!string.IsNullOrEmpty(ddlCategory.SelectedValue) &&
                int.TryParse(ddlCategory.SelectedValue, out int cid))
                catId = cid;

            string attachPath, attachType, attachError;
            if (!TryValidateAttachment(out attachPath, out attachType, out attachError))
            {
                ShowModalAlert("&gt; " + attachError, false);
                LoadCategoryDropdown(); LoadForums(); return;
            }

            ForumDAL.CreateForum(title, body, CurrentUserId, catId, attachPath, attachType);
            ViewState["ModalOpen"] = false;
            Response.Redirect("~/Forum/Index.aspx?created=1");
        }

        // ── ADMIN PIN (Fix 3, Fix 4) ──────────────────────────────────────────

        protected void btnPinForum_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) { Response.Redirect("~/AccessDenied.aspx"); return; }
            if (!int.TryParse(hdnPinForumId.Value, out int forumId) ||
                !int.TryParse(hdnPinDays.Value, out int days) ||
                days < 1 || days > 30)
                return;

            // Fix 4: only 3/7/14/30 are valid
            if (days != 3 && days != 7 && days != 14 && days != 30) days = 7;

            ForumDAL.PinForumAdmin(forumId, DateTime.UtcNow.AddDays(days));
            ShowAlert($"&gt; Post pinned for {days} days.", true);
            LoadForums(); LoadCategoryDropdown();
        }

        protected void btnUnpinForum_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) { Response.Redirect("~/AccessDenied.aspx"); return; }
            if (!int.TryParse(hdnPinForumId.Value, out int forumId)) return;

            ForumDAL.UnpinForumAdmin(forumId);
            ShowAlert("&gt; Post unpinned.", true);
            LoadForums(); LoadCategoryDropdown();
        }

        // ── ATTACHMENT VALIDATION (Fix 7) ─────────────────────────────────────

        private bool TryValidateAttachment(out string savedPath, out string attachType, out string error)
        {
            savedPath = null; attachType = null; error = null;
            if (!fuAttachment.HasFile) return true;

            string ext = Path.GetExtension(fuAttachment.FileName);

            // Block dangerous extensions regardless of stated MIME
            if (BlockedExts.Contains(ext))
            {
                error = "That file type is not allowed.";
                return false;
            }

            // Extension must be in whitelist
            if (!AllowedExtMimes.ContainsKey(ext))
            {
                error = "Unsupported file type. Use jpg/png/gif/webp, pdf/docx/doc/xlsx/pptx.";
                return false;
            }

            // MIME must not be executable
            string mime = (fuAttachment.PostedFile.ContentType ?? "").ToLower();
            string[] execMimes = { "application/x-executable","application/x-msdownload",
                "application/x-sh","text/javascript","application/javascript",
                "application/x-php","application/bat","application/x-dosexec" };
            foreach (var em in execMimes)
                if (mime.StartsWith(em)) { error = "File type rejected (security check)."; return false; }

            // For images: MIME must be image/*
            bool isImage = ImageExts.Contains(ext);
            if (isImage && !mime.StartsWith("image/") && !string.IsNullOrEmpty(mime))
            {
                error = "MIME type does not match image extension.";
                return false;
            }

            // Size caps: images ≤5 MB, documents ≤20 MB
            long maxBytes = isImage ? 5L * 1024 * 1024 : 20L * 1024 * 1024;
            if (fuAttachment.PostedFile.ContentLength > maxBytes)
            {
                error = isImage ? "Images must be under 5 MB." : "Documents must be under 20 MB.";
                return false;
            }

            // Save to disk (directory has no execute permission in IIS — uploads folder)
            string dir = Server.MapPath("~/Uploads/ForumAttachments/");
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
            string fn = "attach_" + DateTime.UtcNow.Ticks + ext;
            fuAttachment.SaveAs(Path.Combine(dir, fn));
            savedPath  = fn;
            attachType = isImage ? "image" : "document";
            return true;
        }

        // ── ALERTS ────────────────────────────────────────────────────────────

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "forum-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }

        private void ShowModalAlert(string msg, bool success)
        {
            lblModalAlert.Text     = msg;
            pnlModalAlert.CssClass = "forum-alert " + (success ? "success" : "error");
            pnlModalAlert.Visible  = true;
        }
    }
}
