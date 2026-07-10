using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Forum
{
    public partial class ThreadDetail : Page
    {
        public int  ForumId       { get; private set; }
        public int  ForumAuthorId { get; private set; }
        public bool IsAdmin       { get; private set; }

        private int CurrentUserId => Session["UserID"] != null ? (int)Session["UserID"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
                Response.Redirect("~/Login.aspx?returnUrl=" + HttpUtility.UrlEncode(Request.RawUrl));

            IsAdmin = Session["Role"] as string == "Admin";

            if (!int.TryParse(Request.QueryString["id"], out int fid))
                Response.Redirect("~/Forum/Index.aspx");

            ForumId          = fid;
            hdnForumId.Value = fid.ToString();

            if (!IsPostBack)
            {
                LoadPost(fid);
            }
            else
            {
                // Rebind Repeater on every postback so ItemCommand events can fire.
                // TextBox values are left alone (they come from LoadPostbackData).
                if (int.TryParse(hdnForumAuthorId.Value, out int aid))
                    ForumAuthorId = aid;
                var comments = ForumDAL.GetComments(fid);
                rptComments.DataSource = comments;
                rptComments.DataBind();
            }
        }

        private void LoadPost(int forumId)
        {
            var forum = ForumDAL.GetForumById(forumId);
            if (forum == null) { Response.Redirect("~/Forum/Index.aspx"); return; }

            // Soft-deleted: non-admins see a placeholder
            if (forum.IsDeleted && !IsAdmin)
            {
                lblOpTitle.Text          = "[removed]";
                lblOpBody.Text           = "<em>This post has been removed.</em>";
                pnlEditBtn.Visible       = false;
                pnlAdminPinBtn.Visible   = false;
                pnlAdminPinPanel.Visible = false;
                rptComments.Visible      = false;
                pnlAttachment.Visible    = false;
                return;
            }

            ForumAuthorId             = forum.AuthorID;
            hdnForumAuthorId.Value    = forum.AuthorID.ToString();

            // Admin pin banner
            if (forum.IsAdminPinned)
            {
                pnlAdminPinBanner.Visible = true;
                lblAdminPinExpiry.Text = forum.PinDaysLeft > 0
                    ? "expires in " + forum.PinDaysLeft + "d"
                    : "expiring today";
            }

            // OP card
            litOpAvatar.Text  = RenderAvatar(forum.AuthorImage, forum.AuthorName, "md");
            lblOpAuthor.Text   = Server.HtmlEncode(ForumHelpers.FormatDisplayName(forum.AuthorName, forum.AuthorID));
            lblOpTime.Text     = ForumHelpers.TimeAgo(forum.CreatedAt);
            lblOpTitle.Text    = Server.HtmlEncode(forum.Title);
            lblOpBody.Text     = Server.HtmlEncode(forum.Body).Replace("\n", "<br />");

            if (!string.IsNullOrEmpty(forum.CategoryName))
            {
                lblOpCategory.Text    = Server.HtmlEncode(forum.CategoryName);
                lblOpCategory.Visible = true;
            }

            // Attachment (Fix 7: image inline, document as download)
            if (!string.IsNullOrEmpty(forum.AttachmentPath))
            {
                pnlAttachment.Visible = true;
                string url = ResolveUrl("~/Uploads/ForumAttachments/" + forum.AttachmentPath);
                if (forum.AttachmentType == "image")
                {
                    imgAttachment.ImageUrl     = url;
                    imgAttachment.AlternateText = "Attachment";
                    imgAttachment.Visible      = true;
                }
                else
                {
                    lnkAttachment.NavigateUrl = url;
                    lnkAttachment.Visible     = true;
                }
            }

            // Like button
            bool liked = ForumDAL.HasUserLikedForum(forumId, CurrentUserId);
            btnLikeForum.Text     = "<i class=\"ti ti-thumb-up\"></i> " + forum.LikeCount;
            btnLikeForum.CssClass = "btn-action" + (liked ? " liked" : "");

            bool canEdit = IsAdmin || forum.AuthorID == CurrentUserId;
            pnlEditBtn.Visible = canEdit;
            if (canEdit)
            {
                txtEditTitle.Text = forum.Title;
                txtEditBody.Text  = forum.Body;
            }

            pnlAdminPinBtn.Visible   = IsAdmin;
            pnlAdminPinPanel.Visible = IsAdmin;

            LoadComments(forumId, forum.AuthorID);
        }

        private void LoadComments(int forumId, int forumAuthorId)
        {
            ForumAuthorId = forumAuthorId;
            var comments = ForumDAL.GetComments(forumId);

            pnlPinnedComment.Visible = false;
            foreach (var c in comments)
            {
                if (c.IsPinActive && !c.IsDeleted)
                {
                    pnlPinnedComment.Visible = true;
                    litPinnedAvatar.Text     = RenderAvatar(c.AuthorImage, c.AuthorName, "xs");
                    lblPinnedAuthor.Text     = Server.HtmlEncode(ForumHelpers.FormatDisplayName(c.AuthorName, c.AuthorID));
                    lblPinnedTime.Text       = ForumHelpers.TimeAgo(c.CreatedAt);
                    lblPinnedBody.Text       = Server.HtmlEncode(c.Body).Replace("\n", "<br />");
                    break;
                }
            }

            int total = 0;
            foreach (var c in comments) { total++; total += c.Replies.Count; }
            lblReplyCount.Text = total.ToString();

            rptComments.DataSource = comments;
            rptComments.DataBind();
        }

        protected void rptComments_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            var comment = (CommentRow)e.Item.DataItem;

            var pnlActions = (Panel)e.Item.FindControl("pnlCommentActions");
            if (pnlActions != null) pnlActions.Visible = !comment.IsDeleted;

            bool canEdit    = IsAdmin || comment.AuthorID == CurrentUserId;
            var pnlDelBtn   = (Panel)e.Item.FindControl("pnlDeleteCommentBtn");
            var pnlEdit     = (Panel)e.Item.FindControl("pnlEditCommentBtn");
            if (pnlDelBtn != null) pnlDelBtn.Visible = canEdit && !comment.IsDeleted;
            if (pnlEdit   != null) pnlEdit.Visible   = canEdit && !comment.IsDeleted;

            // Only the forum's own author can pin comments (Q-D: not IsAdmin)
            bool isForumAuthor = ForumAuthorId == CurrentUserId;
            bool pinActive     = comment.IsPinActive;
            var pnlPin   = (Panel)e.Item.FindControl("pnlPinCommentBtn");
            var pnlUnpin = (Panel)e.Item.FindControl("pnlUnpinCommentBtn");
            if (pnlPin   != null) pnlPin.Visible   = isForumAuthor && !pinActive && !comment.IsDeleted;
            if (pnlUnpin != null) pnlUnpin.Visible = isForumAuthor && pinActive;

            // Bind nested replies repeater
            var pnlReplies = (Panel)e.Item.FindControl("pnlReplies");
            var rptReplies = (Repeater)e.Item.FindControl("rptReplies");
            if (rptReplies != null)
            {
                rptReplies.DataSource = comment.Replies;
                rptReplies.DataBind();
            }
            if (pnlReplies != null) pnlReplies.Visible = comment.Replies.Count > 0;
        }

        protected void rptReplies_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;
            var reply     = (CommentRow)e.Item.DataItem;
            var pnlActions = (Panel)e.Item.FindControl("pnlReplyActions");
            if (pnlActions != null) pnlActions.Visible = !reply.IsDeleted;
        }

        protected void rptReplies_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int fid = int.Parse(hdnForumId.Value);
            if (e.CommandName == "LikeReply" &&
                int.TryParse(e.CommandArgument.ToString(), out int replyId))
            {
                ForumDAL.ToggleCommentLike(replyId, CurrentUserId);
            }
            LoadPost(fid);
        }

        protected string RenderAvatar(string imgPath, string name, string size = "xs")
        {
            if (!string.IsNullOrEmpty(imgPath))
                return "<img src=\"" + ResolveUrl(imgPath) + "\" class=\"avatar avatar-" + size + " avatar-photo\" alt=\"\" />";
            return "<span class=\"avatar avatar-" + size + "\">" + Server.HtmlEncode(ForumHelpers.Initials(name)) + "</span>";
        }

        protected string RenderCommentBody(bool isDeleted, string body)
        {
            if (!isDeleted)
                return Server.HtmlEncode(body ?? "").Replace("\n", "<br />");
            if (IsAdmin)
                return "<em class=\"deleted-indicator\">[deleted]</em> "
                     + Server.HtmlEncode(body ?? "").Replace("\n", "<br />");
            return "<em class=\"deleted-indicator\">[deleted — content removed]</em>";
        }

// ── POSTBACK HANDLERS ─────────────────────────────────────────────────

        protected void btnLikeForum_Click(object sender, EventArgs e)
        {
            int fid = int.Parse(hdnForumId.Value);
            ForumDAL.ToggleForumLike(fid, CurrentUserId);
            LoadPost(fid);
        }

        protected void btnPostReply_Click(object sender, EventArgs e)
        {
            int fid  = int.Parse(hdnForumId.Value);
            string b = txtNewReply.Text.Trim();
            if (string.IsNullOrEmpty(b)) { ShowAlert("&gt; Reply cannot be empty.", false); LoadPost(fid); return; }
            ForumDAL.AddComment(fid, null, CurrentUserId, b);
            txtNewReply.Text = "";
            LoadPost(fid);
        }

        protected void btnSaveForumEdit_Click(object sender, EventArgs e)
        {
            int fid   = int.Parse(hdnForumId.Value);
            string t  = txtEditTitle.Text.Trim();
            string b  = txtEditBody.Text.Trim();
            if (string.IsNullOrEmpty(t) || string.IsNullOrEmpty(b))
            {
                ViewState["EditPanelOpen"] = true;
                ShowAlert("&gt; Title and body are required.", false); LoadPost(fid); return;
            }
            try { ForumDAL.UpdateForum(fid, t, b, null, CurrentUserId, IsAdmin); }
            catch (UnauthorizedAccessException) { Response.Redirect("~/AccessDenied.aspx"); return; }
            ViewState["EditPanelOpen"] = false;
            ShowAlert("&gt; Post updated.", true);
            LoadPost(fid);
        }

        protected void btnDeleteForum_Click(object sender, EventArgs e)
        {
            int fid = int.Parse(hdnForumId.Value);
            try { ForumDAL.SoftDeleteForum(fid, CurrentUserId, IsAdmin); }
            catch (UnauthorizedAccessException) { Response.Redirect("~/AccessDenied.aspx"); return; }
            Response.Redirect("~/Forum/Index.aspx");
        }

        protected void btnPinAdmin_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) return;
            int fid  = int.Parse(hdnForumId.Value);
            int days = 7;
            if (sender is Button btn) int.TryParse(btn.CommandArgument, out days);
            if (days != 3 && days != 7 && days != 14 && days != 30) days = 7;
            ForumDAL.PinForumAdmin(fid, DateTime.UtcNow.AddDays(days));
            ShowAlert($"&gt; Post pinned for {days} days.", true);
            LoadPost(fid);
        }

        protected void btnUnpinAdmin_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) return;
            int fid = int.Parse(hdnForumId.Value);
            ForumDAL.UnpinForumAdmin(fid);
            ShowAlert("&gt; Post unpinned.", true);
            LoadPost(fid);
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            string reason = txtReportReason.Text.Trim();
            int fid = int.Parse(hdnForumId.Value);
            if (string.IsNullOrEmpty(reason))
            {
                ViewState["OpenReport"] = true;
                ShowAlert("&gt; Please provide a reason.", false); LoadPost(fid); return;
            }
            if (!int.TryParse(hdnReportId.Value, out int targetId)) { LoadPost(fid); return; }
            ForumDAL.ReportContent(hdnReportType.Value, targetId, CurrentUserId, reason);
            txtReportReason.Text    = "";
            ViewState["OpenReport"] = false;
            ShowAlert("&gt; Report submitted. Thank you.", true);
            LoadPost(fid);
        }

        protected void rptComments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int fid = int.Parse(hdnForumId.Value);
            if (!int.TryParse(e.CommandArgument.ToString(), out int commentId)) return;

            if (e.CommandName == "LikeComment")
            {
                ForumDAL.ToggleCommentLike(commentId, CurrentUserId);
            }
            else if (e.CommandName == "SaveEdit")
            {
                var tb   = e.Item.FindControl("txtEditBody") as TextBox;
                string b = (tb != null ? Request.Form[tb.UniqueID] : null)?.Trim() ?? "";
                if (string.IsNullOrEmpty(b)) { ShowAlert("&gt; Body cannot be empty.", false); LoadPost(fid); return; }
                try { ForumDAL.UpdateComment(commentId, b, CurrentUserId, IsAdmin); }
                catch (UnauthorizedAccessException) { Response.Redirect("~/AccessDenied.aspx"); return; }
                ShowAlert("&gt; Comment updated.", true);
            }
            else if (e.CommandName == "PostNested")
            {
                var tb   = e.Item.FindControl("txtNestedBody") as TextBox;
                string b = (tb != null ? Request.Form[tb.UniqueID] : null)?.Trim() ?? "";
                if (string.IsNullOrEmpty(b)) { ShowAlert("&gt; Reply cannot be empty.", false); LoadPost(fid); return; }
                ForumDAL.AddComment(fid, commentId, CurrentUserId, b);
                ShowAlert("&gt; Reply posted.", true);
            }
            LoadPost(fid);
        }

        // ── Comment modal action handlers ──────────────────────────────────────

        protected void btnDeleteCommentConfirm_Click(object sender, EventArgs e)
        {
            int fid = int.Parse(hdnForumId.Value);
            if (!int.TryParse(hdnCommentActionId.Value, out int cid)) { LoadPost(fid); return; }
            try { ForumDAL.SoftDeleteComment(cid, CurrentUserId, IsAdmin); }
            catch (UnauthorizedAccessException) { Response.Redirect("~/AccessDenied.aspx"); return; }
            ShowAlert("&gt; Reply deleted.", true);
            LoadPost(fid);
        }

        protected void btnPinCommentConfirm_Click(object sender, EventArgs e)
        {
            int fid = int.Parse(hdnForumId.Value);
            if (!int.TryParse(hdnCommentActionId.Value, out int cid)) { LoadPost(fid); return; }
            if (!int.TryParse(hdnCommentPinDays.Value, out int days) || days < 1) days = 7;
            DateTime pinUntil = DateTime.UtcNow.AddDays(days);
            try { ForumDAL.PinCommentByCreator(cid, fid, CurrentUserId, pinUntil); }
            catch (UnauthorizedAccessException) { Response.Redirect("~/AccessDenied.aspx"); return; }
            ShowAlert($"&gt; Reply pinned for {days} days.", true);
            LoadPost(fid);
        }

        protected void btnUnpinCommentConfirm_Click(object sender, EventArgs e)
        {
            int fid = int.Parse(hdnForumId.Value);
            if (!int.TryParse(hdnCommentActionId.Value, out int cid)) { LoadPost(fid); return; }
            try { ForumDAL.UnpinCommentByCreator(cid, fid, CurrentUserId); }
            catch (UnauthorizedAccessException) { Response.Redirect("~/AccessDenied.aspx"); return; }
            ShowAlert("&gt; Reply unpinned.", true);
            LoadPost(fid);
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "forum-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }
    }
}
