<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageForums.aspx.cs"
         Inherits="CyberLearnHub.Admin.ManageForums" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Manage Forums</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <%-- CREATE FORUM --%>
    <div class="admin-card" style="margin-bottom:24px;">
        <div class="admin-card-title"><i class="ti ti-plus"></i> Create Forum Post</div>

        <div class="form-group">
            <label class="form-label">Title <span style="color:var(--cyber-danger)">*</span></label>
            <asp:TextBox ID="txtCreateTitle" runat="server" CssClass="form-control" MaxLength="300" placeholder="Forum post title" />
        </div>
        <div class="form-group">
            <label class="form-label">Body <span style="color:var(--cyber-danger)">*</span></label>
            <asp:TextBox ID="txtCreateBody" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" MaxLength="8000" placeholder="Post content..." />
        </div>
        <div class="form-group">
            <label class="form-label">Category</label>
            <asp:DropDownList ID="ddlCreateCategory" runat="server" CssClass="form-control" />
        </div>
        <div class="form-group">
            <label class="form-label">Attachment (jpg/png/gif/webp &le;5MB · pdf/docx/doc/xlsx/pptx &le;20MB)</label>
            <asp:FileUpload ID="fuCreateAttachment" runat="server" CssClass="form-control"
                accept=".jpg,.jpeg,.png,.gif,.webp,.pdf,.docx,.doc,.xlsx,.pptx" />
        </div>
        <asp:Button ID="btnCreate" runat="server" Text="Create Post" CssClass="btn-admin-primary" OnClick="btnCreate_Click" CausesValidation="false" />
    </div>

    <%-- ALL FORUMS TABLE (including soft-deleted — Fix 9) --%>
    <div class="admin-card">
        <div class="admin-card-title"><i class="ti ti-messages"></i> All Posts</div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div style="text-align:center;padding:40px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:12px;">
                <i class="ti ti-messages-off" style="font-size:36px;display:block;margin-bottom:12px;color:var(--cyber-border);"></i>
                &gt; No forum posts yet.
            </div>
        </asp:Panel>

        <asp:Repeater ID="rptForums" runat="server" OnItemCommand="rptForums_ItemCommand">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>Title</th>
                    <th>Author</th>
                    <th>Category</th>
                    <th>Replies</th>
                    <th>Status</th>
                    <th>Created</th>
                    <th>Actions</th>
                </tr></thead>
                <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr style='<%# (bool)Eval("IsDeleted") ? "opacity:.55;" : "" %>'>
                    <td style="color:var(--cyber-heading);font-weight:500;max-width:220px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                        <%# Server.HtmlEncode(Eval("Title") as string) %>
                    </td>
                    <td style="color:var(--cyber-muted);font-size:12px;"><%# Server.HtmlEncode(Eval("AuthorName") as string) %></td>
                    <td style="color:var(--cyber-muted);font-size:12px;"><%# Server.HtmlEncode(Eval("CategoryName") as string ?? "—") %></td>
                    <td style="color:var(--cyber-muted);font-size:12px;"><%# Eval("CommentCount") %></td>
                    <td style="font-size:11px;">
                        <%# (bool)Eval("IsDeleted")
                            ? "<span style=\"color:var(--cyber-danger);font-family:'Share Tech Mono',monospace;\">removed</span>"
                            : "<span style=\"color:var(--cyber-accent2);font-family:'Share Tech Mono',monospace;\">active</span>" %>
                    </td>
                    <td style="font-size:11px;color:var(--cyber-muted);"><%# ((DateTime)Eval("CreatedAt")).ToString("yyyy-MM-dd") %></td>
                    <td>
                        <div style="display:flex;gap:6px;flex-wrap:wrap;">
                            <%# !(bool)Eval("IsDeleted")
                                ? "<a href=\"../Forum/ThreadDetail.aspx?id=" + Eval("ForumID") + "\" class=\"btn-admin-sm btn-view\" target=\"_blank\"><i class=\"ti ti-eye\"></i> View</a>"
                                : "" %>
                            <%# !(bool)Eval("IsDeleted")
                                ? "<button type=\"button\" class=\"btn-admin-sm btn-edit\" onclick=\"openEditModal(" + Eval("ForumID") + ",'" + (Eval("Title") as string ?? "").Replace("'","&#39;") + "')\"><i class=\"ti ti-pencil\"></i> Edit</button>"
                                : "" %>

                            <%# !(bool)Eval("IsDeleted")
                                ? "<asp:LinkButton_Placeholder_Delete ForumID=\"" + Eval("ForumID") + "\"></asp:LinkButton_Placeholder_Delete>"
                                : "" %>

                            <%# !(bool)Eval("IsDeleted")
                                ? ""
                                : "<button type=\"button\" class=\"btn-admin-sm btn-restore\" onclick=\"submitCommand('Restore','" + Eval("ForumID") + "')\"><i class=\"ti ti-arrow-back-up\"></i> Restore</button>" %>
                            <%# (bool)Eval("IsDeleted")
                                ? "<button type=\"button\" class=\"btn-admin-sm btn-delete\" onclick=\"if(confirm('Permanently delete? CANNOT be undone.')) submitCommand('HardDelete','" + Eval("ForumID") + "')\"><i class=\"ti ti-trash\"></i> Delete</button>"
                                : "" %>
                        </div>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>

        <%-- Hidden buttons driven by JS to trigger postbacks for ItemCommand-based actions --%>
        <asp:Button ID="btnSoftDelete" runat="server" Style="display:none" OnClick="btnSoftDelete_Click" CausesValidation="false" />
        <asp:Button ID="btnRestore"    runat="server" Style="display:none" OnClick="btnRestore_Click"    CausesValidation="false" />
        <asp:Button ID="btnHardDelete" runat="server" Style="display:none" OnClick="btnHardDelete_Click" CausesValidation="false" />
        <asp:HiddenField ID="hdnActionForumId" runat="server" />
    </div>

    <%-- EDIT MODAL --%>
    <div id="editModal" class="forum-modal-overlay" style="display:none;">
        <div class="forum-modal">
            <div class="forum-modal-header">
                <h2><i class="ti ti-pencil"></i> Edit Post</h2>
                <button type="button" class="forum-modal-close" onclick="closeEditModal()"><i class="ti ti-x"></i></button>
            </div>
            <div class="forum-modal-body">
                <asp:HiddenField ID="hdnEditId" runat="server" />
                <div class="form-group">
                    <label class="form-label">Title <span style="color:var(--cyber-danger)">*</span></label>
                    <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" MaxLength="300" />
                </div>
                <div class="form-group">
                    <label class="form-label">Body</label>
                    <asp:TextBox ID="txtEditBody" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5" MaxLength="8000" />
                </div>
                <div class="form-group">
                    <label class="form-label">Category</label>
                    <asp:DropDownList ID="ddlEditCategory" runat="server" CssClass="form-control" />
                </div>
                <div class="forum-modal-footer" style="margin-top:16px;">
                    <button type="button" class="btn-ghost" onclick="closeEditModal()">Cancel</button>
                    <asp:Button ID="btnSaveEdit" runat="server" Text="Save Changes" CssClass="btn-admin-primary" OnClick="btnSaveEdit_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <style>
        .forum-modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,0.75); display:flex; align-items:center; justify-content:center; z-index:1000; }
        .forum-modal         { background:var(--cyber-card,#0d1520); border:1px solid var(--cyber-border,#1a3050); border-radius:10px; padding:24px; width:100%; max-width:560px; max-height:90vh; overflow-y:auto; }
        .forum-modal-header  { display:flex; align-items:center; justify-content:space-between; margin-bottom:16px; }
        .forum-modal-close   { background:none; border:none; color:var(--cyber-muted); font-size:20px; cursor:pointer; }
        .forum-modal-footer  { display:flex; gap:8px; justify-content:flex-end; }
        .forum-modal-body    { }
        .btn-restore         { background:rgba(0,255,157,0.1); border:1px solid rgba(0,255,157,0.3); color:var(--cyber-accent2); border-radius:5px; padding:4px 10px; font-size:12px; cursor:pointer; }
        .btn-restore:hover   { background:rgba(0,255,157,0.2); }
        .form-group          { margin-bottom:14px; }
        .form-label          { display:block; font-family:'Rajdhani',sans-serif; font-size:12px; font-weight:600; color:var(--cyber-muted); margin-bottom:5px; }
        .form-control        { width:100%; background:#0d1520; border:1px solid #1a3050; border-radius:6px; padding:10px 12px; color:var(--cyber-text,#c8dff0); font-size:14px; box-sizing:border-box; }
        .form-control:focus  { outline:none; border-color:var(--cyber-accent); }
    </style>

    <script type="text/javascript">
        function openEditModal(id, title) {
            document.getElementById('<%= hdnEditId.ClientID %>').value = id;
            document.getElementById('editModal').style.display = 'flex';
        }
        function closeEditModal() { document.getElementById('editModal').style.display = 'none'; }

        function submitCommand(cmd, id) {
            document.getElementById('<%= hdnActionForumId.ClientID %>').value = id;
            if (cmd === 'SoftDelete')
                document.getElementById('<%= btnSoftDelete.ClientID %>').click();
            else if (cmd === 'Restore')
                document.getElementById('<%= btnRestore.ClientID %>').click();
            else if (cmd === 'HardDelete')
                document.getElementById('<%= btnHardDelete.ClientID %>').click();
        }

        <%if (ViewState["ShowEditModal"] != null && (bool)ViewState["ShowEditModal"]) { %>
        window.addEventListener('load', function() { openEditModal('', ''); });
        <%} %>
    </script>

</asp:Content>
