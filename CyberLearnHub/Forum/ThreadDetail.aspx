<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ThreadDetail.aspx.cs"
         Inherits="CyberLearnHub.Forum.ThreadDetail" MasterPageFile="~/Site.Master"
         EnableEventValidation="false" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Forum Post — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/forum-detail.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<asp:HiddenField ID="hdnForumId"       runat="server" />
<asp:HiddenField ID="hdnForumAuthorId" runat="server" />
<asp:HiddenField ID="hdnReportType"   runat="server" />
<asp:HiddenField ID="hdnReportId"     runat="server" />

<div class="thread-wrap">

    <asp:Panel ID="pnlAdminPinBanner" runat="server" Visible="false" CssClass="admin-pin-banner">
        <i class="ti ti-pin"></i>
        Pinned by Admin &mdash; <asp:Label ID="lblAdminPinExpiry" runat="server" />
    </asp:Panel>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <a href="<%= ResolveUrl("~/Forum/Index.aspx") %>" class="back-link">
        <i class="ti ti-arrow-left"></i> Back to Forums
    </a>

    <%-- OP card --%>
    <div class="op-card">
        <div class="op-header">
            <asp:Literal ID="litOpAvatar" runat="server" />
            <div class="op-meta">
                <span class="op-author"><asp:Label ID="lblOpAuthor" runat="server" /></span>
                <span class="op-time"><asp:Label ID="lblOpTime" runat="server" /></span>
                <asp:Label ID="lblOpCategory" runat="server" CssClass="category-tag" Visible="false" />
            </div>
        </div>

        <h1 class="op-title"><asp:Label ID="lblOpTitle" runat="server" /></h1>
        <div class="op-body"><asp:Label ID="lblOpBody" runat="server" /></div>

        <asp:Panel ID="pnlAttachment" runat="server" Visible="false" CssClass="op-attachment">
            <asp:Image    ID="imgAttachment" runat="server" CssClass="attach-image" Visible="false" />
            <asp:HyperLink ID="lnkAttachment" runat="server" CssClass="attach-doc-link" Visible="false">
                <i class="ti ti-file-description"></i> Download attachment
            </asp:HyperLink>
        </asp:Panel>

        <div class="op-actions">
            <asp:LinkButton ID="btnLikeForum" runat="server" CssClass="btn-action"
                OnClick="btnLikeForum_Click" CausesValidation="false" />

            <asp:Panel ID="pnlEditBtn" runat="server" Visible="false" CssClass="d-inline-flex gap-8">
                <button type="button" class="btn-action" onclick="toggleEl('editForumPanel')">
                    <i class="ti ti-pencil"></i> Edit
                </button>
                <button type="button" class="btn-action btn-danger-text" onclick="openDeleteConfirm()">
                    <i class="ti ti-trash"></i> Delete
                </button>
                <%-- Hidden: triggered by JS after user confirms in custom modal --%>
                <asp:Button ID="btnDeleteForum" runat="server" Style="display:none"
                    OnClick="btnDeleteForum_Click" CausesValidation="false" Text="x" />
            </asp:Panel>

            <asp:Panel ID="pnlAdminPinBtn" runat="server" Visible="false" CssClass="d-inline">
                <button type="button" class="btn-action" onclick="toggleEl('adminPinPanel')">
                    <i class="ti ti-pin"></i> Pin
                </button>
            </asp:Panel>

            <button type="button" class="btn-action btn-report"
                onclick="openReport('Forum','<%= ForumId %>')">
                <i class="ti ti-flag"></i> Report
            </button>
        </div>

        <%-- Inline edit panel --%>
        <div id="editForumPanel" style="display:none" class="inline-edit-panel">
            <div class="form-group">
                <label class="form-label">Title</label>
                <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" MaxLength="300" />
            </div>
            <div class="form-group">
                <label class="form-label">Body</label>
                <asp:TextBox ID="txtEditBody" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="6" />
            </div>
            <div class="inline-edit-footer">
                <button type="button" class="btn-ghost" onclick="toggleEl('editForumPanel')">Cancel</button>
                <asp:Button ID="btnSaveForumEdit" runat="server" Text="Save Changes"
                    CssClass="btn-primary" OnClick="btnSaveForumEdit_Click" CausesValidation="false" />
            </div>
        </div>

        <%-- Admin pin duration (Fix 4: 3/7/14/30 days only) --%>
        <asp:Panel ID="pnlAdminPinPanel" runat="server" Visible="false">
            <div id="adminPinPanel" style="display:none" class="pin-duration-panel">
                <p class="muted-text">Pin duration:</p>
                <div class="pin-duration-grid">
                    <asp:Button ID="btnPin3"  runat="server" Text="3 days"  CssClass="btn-pin-days" CommandArgument="3"  OnClick="btnPinAdmin_Click" CausesValidation="false" />
                    <asp:Button ID="btnPin7"  runat="server" Text="7 days"  CssClass="btn-pin-days" CommandArgument="7"  OnClick="btnPinAdmin_Click" CausesValidation="false" />
                    <asp:Button ID="btnPin14" runat="server" Text="14 days" CssClass="btn-pin-days" CommandArgument="14" OnClick="btnPinAdmin_Click" CausesValidation="false" />
                    <asp:Button ID="btnPin30" runat="server" Text="30 days" CssClass="btn-pin-days" CommandArgument="30" OnClick="btnPinAdmin_Click" CausesValidation="false" />
                </div>
                <asp:Button ID="btnUnpinAdmin" runat="server" Text="Unpin" CssClass="btn-ghost btn-sm"
                    OnClick="btnUnpinAdmin_Click" CausesValidation="false" />
            </div>
        </asp:Panel>
    </div>

    <%-- Creator-pinned comment highlight --%>
    <asp:Panel ID="pnlPinnedComment" runat="server" Visible="false" CssClass="pinned-comment-banner">
        <div class="pinned-label"><i class="ti ti-pin"></i> Pinned reply</div>
        <div class="pinned-comment-card">
            <div class="comment-header">
                <asp:Literal ID="litPinnedAvatar" runat="server" />
                <span class="comment-author"><asp:Label ID="lblPinnedAuthor" runat="server" /></span>
                <span class="comment-time"><asp:Label ID="lblPinnedTime" runat="server" /></span>
            </div>
            <div class="comment-body"><asp:Label ID="lblPinnedBody" runat="server" /></div>
        </div>
    </asp:Panel>

    <%-- Comments section --%>
    <div class="comments-section">
        <div class="comments-header">
            <h3><asp:Label ID="lblReplyCount" runat="server" /> Replies</h3>
        </div>

        <div class="reply-box">
            <span class="avatar avatar-xs"><%= ForumHelpers.Initials(Session["Username"] as string ?? "?") %></span>
            <div class="reply-input-wrap">
                <asp:TextBox ID="txtNewReply" runat="server" CssClass="form-control"
                    TextMode="MultiLine" Rows="3" placeholder="Write a reply..." />
                <asp:Button ID="btnPostReply" runat="server" Text="Post Reply"
                    CssClass="btn-primary btn-sm" OnClick="btnPostReply_Click" CausesValidation="false" />
            </div>
        </div>

        <asp:Repeater ID="rptComments" runat="server"
            OnItemCommand="rptComments_ItemCommand"
            OnItemDataBound="rptComments_ItemDataBound">
            <ItemTemplate>
                <div class="comment-card <%# ((CommentRow)Container.DataItem).IsPinActive && !((CommentRow)Container.DataItem).IsDeleted ? "creator-pinned" : "" %>">
                    <div class="comment-header">
                        <%# RenderAvatar(Eval("AuthorImage") as string, Eval("AuthorName") as string, "xs") %>
                        <span class="comment-author"><%# Server.HtmlEncode(ForumHelpers.FormatDisplayName(Eval("AuthorName") as string, (int)Eval("AuthorID"))) %></span>
                        <span class="comment-time"><%# ForumHelpers.TimeAgo((DateTime)Eval("CreatedAt")) %></span>
                        <%# ((CommentRow)Container.DataItem).IsPinActive && !((CommentRow)Container.DataItem).IsDeleted
                            ? "<span class=\"pin-label\"><i class=\"ti ti-pin\"></i></span>" : "" %>
                    </div>

                    <div class="comment-body">
                        <%# RenderCommentBody((bool)(Eval("IsDeleted") ?? false), Eval("Body") as string) %>
                    </div>

                    <asp:Panel ID="pnlCommentActions" runat="server" CssClass="comment-actions">
                        <asp:LinkButton ID="btnLikeComment" runat="server"
                            CommandName="LikeComment" CommandArgument='<%# Eval("CommentID") %>'
                            CssClass="btn-action">
                            <i class="ti ti-thumb-up"></i> <%# Eval("LikeCount") %>
                        </asp:LinkButton>
                        <button type="button" class="btn-action"
                            onclick="toggleReply('replyPanel_<%# Eval("CommentID") %>')">
                            <i class="ti ti-message"></i> Reply
                        </button>
                        <%-- Delete: opens custom modal (Visible set in ItemDataBound) --%>
                        <asp:Panel ID="pnlDeleteCommentBtn" runat="server" CssClass="d-inline" Visible="false">
                            <button type="button" class="btn-action btn-danger-text"
                                onclick="openCommentDeleteModal('<%# Eval("CommentID") %>')">
                                <i class="ti ti-trash"></i>
                            </button>
                        </asp:Panel>
                        <asp:Panel ID="pnlEditCommentBtn" runat="server" CssClass="d-inline" Visible="false">
                            <button type="button" class="btn-action"
                                onclick="toggleEdit('editPanel_<%# Eval("CommentID") %>')">
                                <i class="ti ti-pencil"></i>
                            </button>
                        </asp:Panel>
                        <%-- Pin: opens duration modal (Visible set in ItemDataBound) --%>
                        <asp:Panel ID="pnlPinCommentBtn" runat="server" CssClass="d-inline" Visible="false">
                            <button type="button" class="btn-action"
                                onclick="openCommentPinModal('<%# Eval("CommentID") %>')">
                                <i class="ti ti-pin"></i>
                            </button>
                        </asp:Panel>
                        <asp:Panel ID="pnlUnpinCommentBtn" runat="server" CssClass="d-inline" Visible="false">
                            <button type="button" class="btn-action btn-pin-active"
                                onclick="openCommentUnpinModal('<%# Eval("CommentID") %>')">
                                <i class="ti ti-pin"></i> Unpin
                            </button>
                        </asp:Panel>
                        <button type="button" class="btn-action btn-report"
                            onclick="openReport('Comment','<%# Eval("CommentID") %>')">
                            <i class="ti ti-flag"></i>
                        </button>
                    </asp:Panel>

                    <div id="editPanel_<%# Eval("CommentID") %>" class="inline-edit-panel" style="display:none">
                        <asp:TextBox ID="txtEditBody" runat="server" CssClass="form-control"
                            TextMode="MultiLine" Rows="3" Text='<%# Eval("Body") %>' />
                        <div class="inline-edit-footer">
                            <button type="button" class="btn-ghost btn-sm"
                                onclick="toggleEdit('editPanel_<%# Eval("CommentID") %>')">Cancel</button>
                            <asp:LinkButton ID="btnSaveEdit" runat="server" Text="Save"
                                CssClass="btn-primary btn-sm" CausesValidation="false"
                                CommandName="SaveEdit" CommandArgument='<%# Eval("CommentID") %>' />
                        </div>
                    </div>

                    <div id="replyPanel_<%# Eval("CommentID") %>" class="inline-edit-panel" style="display:none">
                        <asp:TextBox ID="txtNestedBody" runat="server" CssClass="form-control"
                            TextMode="MultiLine" Rows="2" placeholder="Write a reply..." />
                        <div class="inline-edit-footer">
                            <button type="button" class="btn-ghost btn-sm"
                                onclick="toggleReply('replyPanel_<%# Eval("CommentID") %>')">Cancel</button>
                            <asp:LinkButton ID="btnPostNested" runat="server" Text="Post Reply"
                                CssClass="btn-primary btn-sm" CausesValidation="false"
                                CommandName="PostNested" CommandArgument='<%# Eval("CommentID") %>' />
                        </div>
                    </div>

                    <asp:Panel ID="pnlReplies" runat="server" CssClass="nested-replies">
                        <asp:Repeater ID="rptReplies" runat="server"
                            OnItemCommand="rptReplies_ItemCommand"
                            OnItemDataBound="rptReplies_ItemDataBound">
                            <ItemTemplate>
                                <div class="comment-card nested">
                                    <div class="comment-header">
                                        <%# RenderAvatar(Eval("AuthorImage") as string, Eval("AuthorName") as string, "xs") %>
                                        <span class="comment-author"><%# Server.HtmlEncode(ForumHelpers.FormatDisplayName(Eval("AuthorName") as string, (int)Eval("AuthorID"))) %></span>
                                        <span class="comment-time"><%# ForumHelpers.TimeAgo((DateTime)Eval("CreatedAt")) %></span>
                                    </div>
                                    <div class="comment-body">
                                        <%# RenderCommentBody((bool)(Eval("IsDeleted") ?? false), Eval("Body") as string) %>
                                    </div>
                                    <asp:Panel ID="pnlReplyActions" runat="server" CssClass="comment-actions">
                                        <asp:LinkButton ID="btnLikeReply" runat="server"
                                            CommandName="LikeReply" CommandArgument='<%# Eval("CommentID") %>'
                                            CssClass="btn-action" CausesValidation="false">
                                            <i class="ti ti-thumb-up"></i> <%# Eval("LikeCount") %>
                                        </asp:LinkButton>
                                        <button type="button" class="btn-action btn-report"
                                            onclick="openReport('Comment','<%# Eval("CommentID") %>')">
                                            <i class="ti ti-flag"></i>
                                        </button>
                                    </asp:Panel>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </asp:Panel>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <%-- Hidden plumbing for comment modals (outside Repeater so ClientID is stable) --%>
    <asp:HiddenField ID="hdnCommentActionId"   runat="server" />
    <asp:HiddenField ID="hdnCommentPinDays"    runat="server" />
    <asp:Button ID="btnDeleteCommentConfirm"   runat="server" Style="display:none" Text="x"
        OnClick="btnDeleteCommentConfirm_Click" CausesValidation="false" />
    <asp:Button ID="btnPinCommentConfirm"      runat="server" Style="display:none" Text="x"
        OnClick="btnPinCommentConfirm_Click"   CausesValidation="false" />
    <asp:Button ID="btnUnpinCommentConfirm"    runat="server" Style="display:none" Text="x"
        OnClick="btnUnpinCommentConfirm_Click" CausesValidation="false" />

    <%-- Comment delete confirmation modal --%>
    <div id="commentDeleteModal" class="modal-overlay" style="display:none;">
        <div class="modal-box modal-sm confirm-modal">
            <div class="confirm-icon"><i class="ti ti-alert-triangle"></i></div>
            <h3 class="confirm-title">Delete Reply?</h3>
            <p class="confirm-body">This reply will be marked as removed. Admins can still see it.</p>
            <div class="confirm-actions">
                <button type="button" class="btn-ghost" onclick="closeCommentDeleteModal()">Cancel</button>
                <button type="button" class="btn-danger" onclick="confirmCommentDelete()">
                    <i class="ti ti-trash"></i> Yes, Delete
                </button>
            </div>
        </div>
    </div>

    <%-- Comment pin duration modal --%>
    <div id="commentPinModal" class="modal-overlay" style="display:none;">
        <div class="modal-box modal-sm">
            <div class="modal-header">
                <h3><i class="ti ti-pin"></i> Pin Reply</h3>
                <button type="button" class="modal-close" onclick="closeCommentPinModal()"><i class="ti ti-x"></i></button>
            </div>
            <div class="modal-body">
                <p class="muted-text">Pinned reply appears at the top of the thread for the selected duration.</p>
                <div class="pin-duration-grid">
                    <button type="button" class="btn-pin-days" onclick="submitCommentPin(3)">3 days</button>
                    <button type="button" class="btn-pin-days" onclick="submitCommentPin(7)">7 days</button>
                    <button type="button" class="btn-pin-days" onclick="submitCommentPin(14)">14 days</button>
                    <button type="button" class="btn-pin-days" onclick="submitCommentPin(30)">1 month</button>
                </div>
            </div>
        </div>
    </div>

    <%-- Comment unpin confirmation modal --%>
    <div id="commentUnpinModal" class="modal-overlay" style="display:none;">
        <div class="modal-box modal-sm confirm-modal">
            <div class="confirm-icon" style="background:rgba(0,212,255,0.1);border-color:rgba(0,212,255,0.3);">
                <i class="ti ti-pin-off" style="color:var(--cyber-accent);"></i>
            </div>
            <h3 class="confirm-title">Unpin Reply?</h3>
            <p class="confirm-body">This reply will no longer be highlighted at the top of the thread.</p>
            <div class="confirm-actions">
                <button type="button" class="btn-ghost" onclick="closeCommentUnpinModal()">Cancel</button>
                <button type="button" class="btn-primary" onclick="confirmCommentUnpin()">
                    <i class="ti ti-pin-off"></i> Unpin
                </button>
            </div>
        </div>
    </div>

    <%-- Delete confirmation modal --%>
    <div id="deleteConfirmModal" class="modal-overlay" style="display:none;">
        <div class="modal-box modal-sm confirm-modal">
            <div class="confirm-icon"><i class="ti ti-alert-triangle"></i></div>
            <h3 class="confirm-title">Delete Post?</h3>
            <p class="confirm-body">This post will be marked as removed and hidden from all users. This action can only be undone by an admin.</p>
            <div class="confirm-actions">
                <button type="button" class="btn-ghost" onclick="closeDeleteConfirm()">Cancel</button>
                <button type="button" class="btn-danger" onclick="confirmDelete()">
                    <i class="ti ti-trash"></i> Yes, Delete
                </button>
            </div>
        </div>
    </div>

    <%-- Report modal --%>
    <div id="reportModal" class="modal-overlay" style="display:none;">
        <div class="modal-box modal-sm">
            <div class="modal-header">
                <h3><i class="ti ti-flag"></i> Report Content</h3>
                <button type="button" class="modal-close" onclick="closeReport()"><i class="ti ti-x"></i></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Reason <span class="req">*</span></label>
                    <asp:TextBox ID="txtReportReason" runat="server" CssClass="form-control"
                        TextMode="MultiLine" Rows="3" MaxLength="500"
                        placeholder="Describe why you are reporting this content..." />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-ghost" onclick="closeReport()">Cancel</button>
                    <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Report"
                        CssClass="btn-danger" OnClick="btnSubmitReport_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

</div>

<script type="text/javascript">
    function toggleEl(id) { var el=document.getElementById(id); if(el) el.style.display=el.style.display==='none'?'block':'none'; }
    function toggleEdit(id) {
        document.querySelectorAll('[id^="editPanel_"]').forEach(function(p){p.style.display='none';});
        toggleEl(id);
    }
    function toggleReply(id) {
        document.querySelectorAll('[id^="replyPanel_"]').forEach(function(p){p.style.display='none';});
        toggleEl(id);
    }
    // ── Comment delete modal ──
    function openCommentDeleteModal(id) {
        document.getElementById('<%= hdnCommentActionId.ClientID %>').value = id;
        document.getElementById('commentDeleteModal').style.display = 'flex';
    }
    function closeCommentDeleteModal() { document.getElementById('commentDeleteModal').style.display = 'none'; }
    function confirmCommentDelete() {
        closeCommentDeleteModal();
        document.getElementById('<%= btnDeleteCommentConfirm.ClientID %>').click();
    }

    // ── Comment pin modal ──
    function openCommentPinModal(id) {
        document.getElementById('<%= hdnCommentActionId.ClientID %>').value = id;
        document.getElementById('commentPinModal').style.display = 'flex';
    }
    function closeCommentPinModal() { document.getElementById('commentPinModal').style.display = 'none'; }
    function submitCommentPin(days) {
        document.getElementById('<%= hdnCommentPinDays.ClientID %>').value = days;
        closeCommentPinModal();
        document.getElementById('<%= btnPinCommentConfirm.ClientID %>').click();
    }

    // ── Comment unpin modal ──
    function openCommentUnpinModal(id) {
        document.getElementById('<%= hdnCommentActionId.ClientID %>').value = id;
        document.getElementById('commentUnpinModal').style.display = 'flex';
    }
    function closeCommentUnpinModal() { document.getElementById('commentUnpinModal').style.display = 'none'; }
    function confirmCommentUnpin() {
        closeCommentUnpinModal();
        document.getElementById('<%= btnUnpinCommentConfirm.ClientID %>').click();
    }

    // ── Forum post delete modal ──
    function openDeleteConfirm()  { document.getElementById('deleteConfirmModal').style.display = 'flex'; }
    function closeDeleteConfirm() { document.getElementById('deleteConfirmModal').style.display = 'none'; }
    function confirmDelete() {
        closeDeleteConfirm();
        document.getElementById('<%= btnDeleteForum.ClientID %>').click();
    }

    function openReport(type, id) {
        document.getElementById('<%= hdnReportType.ClientID %>').value = type;
        document.getElementById('<%= hdnReportId.ClientID %>').value   = id;
        document.getElementById('reportModal').style.display = 'flex';
    }
    function closeReport() { document.getElementById('reportModal').style.display = 'none'; }

    <%if ((bool)(ViewState["OpenReport"] ?? false)) { %>
    window.addEventListener('load', function() { document.getElementById('reportModal').style.display='flex'; });
    <%} %>
    <%if ((bool)(ViewState["EditPanelOpen"] ?? false)) { %>
    window.addEventListener('load', function() { toggleEl('editForumPanel'); });
    <%} %>
</script>

</asp:Content>
