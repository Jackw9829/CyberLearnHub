<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs"
         Inherits="CyberLearnHub.Forum.Index" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Forums — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/forum-index.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<asp:HiddenField ID="hdnPinForumId" runat="server" />
<asp:HiddenField ID="hdnPinDays"    runat="server" />
<asp:Button ID="btnPinForum"   runat="server" Style="display:none" OnClick="btnPinForum_Click"   CausesValidation="false" />
<asp:Button ID="btnUnpinForum" runat="server" Style="display:none" OnClick="btnUnpinForum_Click" CausesValidation="false" />

<div class="forum-index-wrap">

    <div class="forum-page-header">
        <div>
            <div class="forum-tag">// community</div>
            <h1 class="forum-title">Forums</h1>
        </div>
        <button type="button" class="btn-create-forum" onclick="openCreateModal()">
            <i class="ti ti-plus"></i> New Post
        </button>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <%-- Sort pills --%>
    <div class="forum-sort-bar">
        <a href="?sort=recent"  class='sort-pill <%=ActiveSort=="recent"  ? "active" : "" %>'>Recent</a>
        <a href="?sort=liked"   class='sort-pill <%=ActiveSort=="liked"   ? "active" : "" %>'>Most Liked</a>
        <a href="?sort=replied" class='sort-pill <%=ActiveSort=="replied" ? "active" : "" %>'>Most Replied</a>
        <a href="?sort=mine"    class='sort-pill <%=ActiveSort=="mine"    ? "active" : "" %>'>My Posts</a>
    </div>

    <%-- Client-side search --%>
    <div class="forum-search-wrap">
        <i class="ti ti-search"></i>
        <input type="text" id="forumSearch" class="forum-search" placeholder="Search posts..." oninput="filterCards(this.value)" />
    </div>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="forum-empty">
        <i class="ti ti-messages-off"></i>
        <div>No posts yet. Be the first!</div>
        <button type="button" class="btn-create-forum" onclick="openCreateModal()">
            <i class="ti ti-plus"></i> Create Post
        </button>
    </asp:Panel>

    <div class="forum-grid" id="forumGrid">
        <asp:Repeater ID="rptForums" runat="server">
            <ItemTemplate>
                <div class="forum-card <%# ((ForumRow)Container.DataItem).IsAdminPinned ? "is-pinned" : "" %>"
                     data-title="<%# (Eval("Title") as string ?? "").ToLower() %>">

                    <%# ((ForumRow)Container.DataItem).IsAdminPinned
                        ? "<div class=\"pin-badge\"><i class=\"ti ti-pin\"></i> Pinned by Admin &middot; expires in "
                          + ((ForumRow)Container.DataItem).PinDaysLeft + "d</div>"
                        : "" %>

                    <div class="forum-card-body">
                        <h3 class="forum-card-title"><%# Server.HtmlEncode(Eval("Title") as string) %></h3>
                        <p class="forum-card-excerpt"><%# Server.HtmlEncode(TruncateBody(Eval("Body") as string, 180)) %></p>

                        <%# !string.IsNullOrEmpty(Eval("CategoryName") as string)
                            ? "<span class=\"category-tag\">" + Server.HtmlEncode(Eval("CategoryName") as string) + "</span>"
                            : "" %>
                    </div>

                    <div class="forum-card-footer">
                        <div class="forum-card-author">
                            <%# RenderAvatar(Eval("AuthorImage") as string, Eval("AuthorName") as string) %>
                            <span class="author-name"><%# Server.HtmlEncode(ForumHelpers.FormatDisplayName(Eval("AuthorName") as string, (int)Eval("AuthorID"))) %></span>
                            <span class="post-time"><%# ForumHelpers.TimeAgo((DateTime)Eval("CreatedAt")) %></span>
                        </div>
                        <div class="forum-card-stats">
                            <span><i class="ti ti-thumb-up"></i> <%# Eval("LikeCount") %></span>
                            <span><i class="ti ti-message"></i> <%# Eval("CommentCount") %></span>
                        </div>
                    </div>

                    <div class="forum-card-actions">
                        <a href='<%# "ThreadDetail.aspx?id=" + Eval("ForumID") %>' class="btn-view-post">
                            View Post <i class="ti ti-arrow-right"></i>
                        </a>
                        <%# IsAdmin
                            ? "<div class=\"admin-menu-wrap\">"
                              + "<button type=\"button\" class=\"btn-dots\" onclick=\"toggleMenu(event,'amenu_" + Eval("ForumID") + "')\"><i class=\"ti ti-dots\"></i></button>"
                              + "<div class=\"admin-dropdown\" id=\"amenu_" + Eval("ForumID") + "\" style=\"display:none\">"
                              + "<button type=\"button\" onclick=\"openPinModal(" + Eval("ForumID") + ")\"><i class=\"ti ti-pin\"></i> Pin</button>"
                              + "<button type=\"button\" onclick=\"doUnpin(" + Eval("ForumID") + ")\"><i class=\"ti ti-pin-off\"></i> Unpin</button>"
                              + "</div></div>"
                            : "" %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <%-- CREATE FORUM MODAL --%>
    <div id="createModal" class="modal-overlay" style="display:none;">
        <div class="modal-box">
            <div class="modal-header">
                <div>
                    <div class="forum-tag">// new post</div>
                    <h2>Create Forum Post</h2>
                </div>
                <button type="button" class="modal-close" onclick="closeCreateModal()"><i class="ti ti-x"></i></button>
            </div>
            <div class="modal-body">
                <asp:Panel ID="pnlModalAlert" runat="server" Visible="false">
                    <asp:Label ID="lblModalAlert" runat="server" />
                </asp:Panel>
                <div class="form-group">
                    <label class="form-label">Title <span class="req">*</span></label>
                    <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="300" placeholder="What's this about?" />
                </div>
                <div class="form-group">
                    <label class="form-label">Body <span class="req">*</span></label>
                    <asp:TextBox ID="txtBody" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="6"
                        placeholder="Share your thoughts, question, or findings..." />
                </div>
                <div class="form-group">
                    <label class="form-label">Category <span class="muted">(optional)</span></label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control" />
                </div>
                <div class="form-group">
                    <label class="form-label">Attachment <span class="muted">(optional)</span></label>
                    <div class="attach-shortcuts">
                        <button type="button" class="btn-attach-type active" onclick="setAttachFilter('image/*,.jpg,.jpeg,.png,.gif,.webp', this)">
                            <i class="ti ti-photo"></i> Image
                        </button>
                        <button type="button" class="btn-attach-type" onclick="setAttachFilter('.pdf,.docx,.doc,.xlsx,.pptx', this)">
                            <i class="ti ti-file-description"></i> Document
                        </button>
                    </div>
                    <div class="upload-drop-zone" id="attachDropZone" onclick="triggerFileInput()">
                        <i class="ti ti-upload" id="attachIcon"></i>
                        <span id="attachLabel">Click or drag to attach a file</span>
                        <span class="attach-hint" id="attachHint">Images: jpg/png/gif/webp &le;5MB &nbsp;&bull;&nbsp; Documents: pdf/docx/doc/xlsx/pptx &le;20MB</span>
                    </div>
                    <asp:FileUpload ID="fuAttachment" runat="server" Style="display:none"
                        accept="image/*,.jpg,.jpeg,.png,.gif,.webp"
                        onchange="previewAttachment(this)" />
                    <div id="attachPreview" class="attach-preview" style="display:none">
                        <img id="attachThumb" src="" alt="" style="display:none" />
                        <div class="attach-chip">
                            <i class="ti ti-paperclip"></i>
                            <span id="attachName"></span>
                            <button type="button" onclick="clearAttachment()"><i class="ti ti-x"></i></button>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-ghost" onclick="closeCreateModal()">Cancel</button>
                    <asp:Button ID="btnCreateForum" runat="server" Text="Post"
                        CssClass="btn-primary" OnClick="btnCreateForum_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <%-- ADMIN PIN MODAL (3/7/14/30 days only) --%>
    <div id="pinModal" class="modal-overlay" style="display:none;">
        <div class="modal-box modal-sm">
            <div class="modal-header">
                <h3><i class="ti ti-pin"></i> Pin Duration</h3>
                <button type="button" class="modal-close" onclick="closePinModal()"><i class="ti ti-x"></i></button>
            </div>
            <div class="modal-body">
                <p class="muted-text">Select how long this post stays pinned at the top.</p>
                <div class="pin-duration-grid">
                    <button type="button" class="btn-pin-days" onclick="submitPin(3)">3 days</button>
                    <button type="button" class="btn-pin-days" onclick="submitPin(7)">7 days</button>
                    <button type="button" class="btn-pin-days" onclick="submitPin(14)">14 days</button>
                    <button type="button" class="btn-pin-days" onclick="submitPin(30)">30 days</button>
                </div>
            </div>
        </div>
    </div>

</div>

<script type="text/javascript">
    var _pinForumId = 0;

    function openCreateModal()  { document.getElementById('createModal').style.display = 'flex'; }
    function closeCreateModal() { document.getElementById('createModal').style.display = 'none'; }

    function openPinModal(id)  { _pinForumId = id; closeAllMenus(); document.getElementById('pinModal').style.display = 'flex'; }
    function closePinModal()   { document.getElementById('pinModal').style.display = 'none'; }

    function submitPin(days) {
        document.getElementById('<%= hdnPinForumId.ClientID %>').value = _pinForumId;
        document.getElementById('<%= hdnPinDays.ClientID %>').value    = days;
        closePinModal();
        document.getElementById('<%= btnPinForum.ClientID %>').click();
    }

    function doUnpin(id) {
        closeAllMenus();
        document.getElementById('<%= hdnPinForumId.ClientID %>').value = id;
        document.getElementById('<%= btnUnpinForum.ClientID %>').click();
    }

    function toggleMenu(e, id) {
        e.stopPropagation();
        var menu = document.getElementById(id);
        var visible = menu.style.display !== 'none';
        closeAllMenus();
        if (!visible) menu.style.display = 'block';
    }

    function closeAllMenus() {
        document.querySelectorAll('.admin-dropdown').forEach(function(m) { m.style.display = 'none'; });
    }

    document.addEventListener('click', closeAllMenus);

    function filterCards(q) {
        var term = q.toLowerCase();
        document.querySelectorAll('.forum-card').forEach(function(c) {
            c.style.display = c.dataset.title.indexOf(term) >= 0 ? '' : 'none';
        });
    }

    function setAttachFilter(accept, btn) {
        document.getElementById('<%= fuAttachment.ClientID %>').accept = accept;
        document.querySelectorAll('.btn-attach-type').forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
    }

    function triggerFileInput() { document.getElementById('<%= fuAttachment.ClientID %>').click(); }

    function previewAttachment(input) {
        if (!input.files || !input.files[0]) return;
        var file = input.files[0];
        document.getElementById('attachName').textContent = file.name;
        document.getElementById('attachDropZone').style.display = 'none';
        document.getElementById('attachPreview').style.display  = 'flex';
        if (file.type.startsWith('image/')) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var thumb = document.getElementById('attachThumb');
                thumb.src = e.target.result;
                thumb.style.display = 'block';
            };
            reader.readAsDataURL(file);
        }
    }

    function clearAttachment() {
        var fu = document.getElementById('<%= fuAttachment.ClientID %>');
        fu.value = '';
        document.getElementById('attachDropZone').style.display = '';
        document.getElementById('attachPreview').style.display  = 'none';
        document.getElementById('attachThumb').style.display    = 'none';
    }

    <%if ((bool)(ViewState["ModalOpen"] ?? false)) { %>
    window.addEventListener('load', function() { openCreateModal(); });
    <%} %>
</script>

</asp:Content>
