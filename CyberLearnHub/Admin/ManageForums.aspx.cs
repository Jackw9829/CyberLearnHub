using System;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace CyberLearnHub.Admin
{
    public partial class ManageForums : AdminBasePage
    {
        // Blocked extensions (Fix 7)
        private static readonly HashSet<string> BlockedExts = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".exe", ".bat", ".cmd", ".sh", ".ps1", ".vbs", ".php", ".asp", ".aspx",
            ".py", ".rb", ".pl", ".com", ".dll", ".msi", ".jar", ".scr", ".hta",
            ".wsf", ".pif", ".reg", ".cpl", ".inf", ".lnk"
        };

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

        private int CurrentUserId => Session["UserID"] != null ? (int)Session["UserID"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadForums();
                LoadCategoryDropdowns();
                if (Request.QueryString["saved"] == "1")
                    ShowAlert("&gt; Saved successfully.", true);
            }
        }

        private void LoadForums()
        {
            var forums = ForumDAL.GetAllForumsAdmin(); // Fix 9: includes soft-deleted
            if (forums.Count == 0) { pnlEmpty.Visible = true; return; }
            pnlEmpty.Visible     = false;
            rptForums.DataSource = forums;
            rptForums.DataBind();
        }

        private void LoadCategoryDropdowns()
        {
            var cats = ForumDAL.GetCategories();
            ddlCreateCategory.Items.Clear();
            ddlCreateCategory.Items.Add(new ListItem("— No category —", ""));
            ddlEditCategory.Items.Clear();
            ddlEditCategory.Items.Add(new ListItem("— No category —", ""));
            foreach (var cat in cats)
            {
                ddlCreateCategory.Items.Add(new ListItem(cat.Name, cat.CategoryID.ToString()));
                ddlEditCategory.Items.Add(new ListItem(cat.Name, cat.CategoryID.ToString()));
            }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            string title = txtCreateTitle.Text.Trim();
            string body  = txtCreateBody.Text.Trim();
            if (string.IsNullOrEmpty(title)) { ShowAlert("&gt; Title is required.", false); LoadForums(); LoadCategoryDropdowns(); return; }
            if (string.IsNullOrEmpty(body))  { ShowAlert("&gt; Body is required.", false);  LoadForums(); LoadCategoryDropdowns(); return; }

            int? catId = null;
            if (!string.IsNullOrEmpty(ddlCreateCategory.SelectedValue) && int.TryParse(ddlCreateCategory.SelectedValue, out int cid))
                catId = cid;

            string attachPath, attachType, attachError;
            if (!TryValidateAttachment(fuCreateAttachment, out attachPath, out attachType, out attachError))
            {
                ShowAlert("&gt; " + attachError, false); LoadForums(); LoadCategoryDropdowns(); return;
            }

            ForumDAL.CreateForum(title, body, CurrentUserId, catId, attachPath, attachType);
            txtCreateTitle.Text = "";
            txtCreateBody.Text  = "";
            LoadForums(); LoadCategoryDropdowns();
            ShowAlert("&gt; Post created.", true);
        }

        // Repeater is read-only for display; actions use hidden buttons + hdnActionForumId
        protected void rptForums_ItemCommand(object source, RepeaterCommandEventArgs e) { }

        // Soft delete (Fix 9)
        protected void btnSoftDelete_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hdnActionForumId.Value, out int fid)) return;
            try { ForumDAL.SoftDeleteForum(fid, CurrentUserId, isAdmin: true); }
            catch { }
            LoadForums(); LoadCategoryDropdowns();
            ShowAlert("&gt; Post removed (soft delete).", true);
        }

        protected void btnRestore_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hdnActionForumId.Value, out int fid)) return;
            ForumDAL.RestoreForum(fid);
            LoadForums(); LoadCategoryDropdowns();
            ShowAlert("&gt; Post restored.", true);
        }

        protected void btnHardDelete_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hdnActionForumId.Value, out int fid)) return;
            ForumDAL.HardDeleteForum(fid);
            LoadForums(); LoadCategoryDropdowns();
            ShowAlert("&gt; Post permanently deleted.", true);
        }

        protected void btnSaveEdit_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hdnEditId.Value, out int fid))
            {
                ViewState["ShowEditModal"] = true;
                ShowAlert("&gt; Invalid ID.", false); LoadForums(); LoadCategoryDropdowns(); return;
            }
            string title = txtEditTitle.Text.Trim();
            string body  = txtEditBody.Text.Trim();
            if (string.IsNullOrEmpty(title))
            {
                ViewState["ShowEditModal"] = true;
                ShowAlert("&gt; Title is required.", false); LoadForums(); LoadCategoryDropdowns(); return;
            }

            int? catId = null;
            if (!string.IsNullOrEmpty(ddlEditCategory.SelectedValue) && int.TryParse(ddlEditCategory.SelectedValue, out int cid))
                catId = cid;

            string attachPath, attachType, attachError;
            if (!TryValidateAttachment(fuEditAttachment, out attachPath, out attachType, out attachError))
            {
                ViewState["ShowEditModal"] = true;
                ShowAlert("&gt; " + attachError, false); LoadForums(); LoadCategoryDropdowns(); return;
            }

            try { ForumDAL.UpdateForum(fid, title, body, catId, CurrentUserId, isAdmin: true, attachPath: attachPath, attachType: attachType); }
            catch (UnauthorizedAccessException) { }

            ViewState["ShowEditModal"] = false;
            LoadForums(); LoadCategoryDropdowns();
            ShowAlert("&gt; Post updated.", true);
        }

        private bool TryValidateAttachment(FileUpload fu, out string savedPath, out string attachType, out string error)
        {
            savedPath = null; attachType = null; error = null;
            if (!fu.HasFile) return true;

            string ext = Path.GetExtension(fu.FileName);
            if (BlockedExts.Contains(ext)) { error = "That file type is not allowed."; return false; }
            if (!AllowedExtMimes.ContainsKey(ext)) { error = "Unsupported file type."; return false; }

            string mime = (fu.PostedFile.ContentType ?? "").ToLower();
            string[] execMimes = { "application/x-executable","application/x-msdownload",
                "application/x-sh","text/javascript","application/javascript",
                "application/x-php","application/bat","application/x-dosexec" };
            foreach (var em in execMimes)
                if (mime.StartsWith(em)) { error = "File type rejected (security check)."; return false; }

            bool isImage = ImageExts.Contains(ext);
            if (isImage && !mime.StartsWith("image/") && !string.IsNullOrEmpty(mime))
            { error = "MIME type does not match image extension."; return false; }

            long maxBytes = isImage ? 5L * 1024 * 1024 : 20L * 1024 * 1024;
            if (fu.PostedFile.ContentLength > maxBytes)
            { error = isImage ? "Images must be under 5 MB." : "Documents must be under 20 MB."; return false; }

            string dir = Server.MapPath("~/Uploads/ForumAttachments/");
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
            string fn = "attach_" + DateTime.UtcNow.Ticks + ext;
            fu.SaveAs(Path.Combine(dir, fn));
            savedPath  = fn;
            attachType = isImage ? "image" : "document";
            return true;
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }

        // Renders the Edit button using data-* attributes so the modal pre-populates correctly.
        // data-* values are HTML-attribute-encoded (quotes → &quot;, newlines → &#10;) so they
        // survive the HTML parser; dataset in JS gives the correctly decoded strings.
        protected string RenderEditBtn(object forumId, object isDeleted, object title, object body, object categoryId)
        {
            if (isDeleted is bool b && b) return "";
            return string.Format(
                "<button type=\"button\" class=\"btn-admin-sm btn-edit\" " +
                "data-id=\"{0}\" data-title=\"{1}\" data-body=\"{2}\" data-cat=\"{3}\" " +
                "onclick=\"openEditModal(this)\">" +
                "<i class=\"ti ti-pencil\"></i> Edit</button>",
                forumId,
                HtmlAttr(title?.ToString()),
                HtmlAttr(body?.ToString()),
                (categoryId == null || categoryId == DBNull.Value) ? "" : categoryId.ToString());
        }

        private static string HtmlAttr(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return System.Web.HttpUtility.HtmlAttributeEncode(s)
                .Replace("\r", "")
                .Replace("\n", "&#10;");
        }
    }
}
