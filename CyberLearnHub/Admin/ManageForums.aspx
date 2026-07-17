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
            <label class="form-label">Attachment <span class="muted">(optional)</span></label>
            <div id="adminAttachDropZone" onclick="document.getElementById('<%= fuCreateAttachment.ClientID %>').click()"
                 style="border:1.5px dashed var(--cyber-border);border-radius:8px;padding:24px 16px;text-align:center;cursor:pointer;display:flex;flex-direction:column;align-items:center;gap:8px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:12px;transition:border-color .2s;">
                <i class="ti ti-upload" style="font-size:28px;"></i>
                <div>Click to attach a file</div>
                <div style="font-size:12px;opacity:.7;">Images: jpg/png/gif/webp &le;5MB &nbsp;&bull;&nbsp; Documents: pdf/docx/doc/xlsx/pptx &le;20MB</div>
            </div>
            <asp:FileUpload ID="fuCreateAttachment" runat="server" Style="display:none"
                accept=".jpg,.jpeg,.png,.gif,.webp,.pdf,.docx,.doc,.xlsx,.pptx"
                onchange="adminPreviewAttach(this)" />
            <div id="adminAttachPreview" style="display:none;margin-top:8px;">
                <div style="display:inline-flex;align-items:center;gap:8px;background:rgba(0,212,255,0.07);border:1px solid rgba(0,212,255,0.25);border-radius:6px;padding:6px 12px;font-family:'Share Tech Mono',monospace;font-size:12px;color:var(--cyber-text);">
                    <i class="ti ti-paperclip"></i>
                    <span id="adminAttachName"></span>
                    <button type="button" onclick="adminClearAttach()" style="background:none;border:none;color:var(--cyber-muted);cursor:pointer;padding:0;font-size:14px;line-height:1;"><i class="ti ti-x"></i></button>
                </div>
            </div>
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
                    <td style="color:var(--cyber-muted);font-size:12px;"><%# Eval("CategoryName") != null ? Server.HtmlEncode(Eval("CategoryName") as string) : "&mdash;" %></td>
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
                            <%# RenderEditBtn(Eval("ForumID"), Eval("IsDeleted"), Eval("Title"), Eval("Body"), Eval("CategoryID")) %>

                            <%# !(bool)Eval("IsDeleted")
                                ? "<button type=\"button\" class=\"btn-admin-sm btn-delete\" onclick=\"openConfirm('soft','" + Eval("ForumID") + "')\"><i class=\"ti ti-trash\"></i> Delete</button>"
                                : "" %>

                            <%# !(bool)Eval("IsDeleted")
                                ? ""
                                : "<button type=\"button\" class=\"btn-admin-sm btn-restore\" onclick=\"submitCommand('Restore','" + Eval("ForumID") + "')\"><i class=\"ti ti-arrow-back-up\"></i> Restore</button>" %>
                            <%# (bool)Eval("IsDeleted")
                                ? "<button type=\"button\" class=\"btn-admin-sm btn-delete\" onclick=\"openConfirm('hard','" + Eval("ForumID") + "')\"><i class=\"ti ti-trash\"></i> Permanent Delete</button>"
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
                <div class="form-group">
                    <label class="form-label">Attachment <span class="muted">(optional — leave empty to keep existing)</span></label>
                    <div id="editAttachDropZone" onclick="document.getElementById('<%= fuEditAttachment.ClientID %>').click()"
                         style="border:1.5px dashed var(--cyber-border);border-radius:8px;padding:20px 16px;text-align:center;cursor:pointer;display:flex;flex-direction:column;align-items:center;gap:8px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:12px;transition:border-color .2s;">
                        <i class="ti ti-upload" style="font-size:24px;"></i>
                        <div>Click to attach a file</div>
                        <div style="font-size:11px;opacity:.7;">Images: jpg/png/gif/webp &le;5MB &nbsp;&bull;&nbsp; Documents: pdf/docx/doc/xlsx/pptx &le;20MB</div>
                    </div>
                    <asp:FileUpload ID="fuEditAttachment" runat="server" Style="display:none"
                        accept=".jpg,.jpeg,.png,.gif,.webp,.pdf,.docx,.doc,.xlsx,.pptx"
                        onchange="editPreviewAttach(this)" />
                    <div id="editAttachPreview" style="display:none;margin-top:8px;">
                        <div style="display:inline-flex;align-items:center;gap:8px;background:rgba(0,212,255,0.07);border:1px solid rgba(0,212,255,0.25);border-radius:6px;padding:6px 12px;font-family:'Share Tech Mono',monospace;font-size:12px;color:var(--cyber-text);">
                            <i class="ti ti-paperclip"></i>
                            <span id="editAttachName"></span>
                            <button type="button" onclick="editClearAttach()" style="background:none;border:none;color:var(--cyber-muted);cursor:pointer;padding:0;font-size:14px;line-height:1;"><i class="ti ti-x"></i></button>
                        </div>
                    </div>
                </div>
                <div class="forum-modal-footer" style="margin-top:16px;">
                    <button type="button" class="btn-ghost" onclick="closeEditModal()">Cancel</button>
                    <asp:Button ID="btnSaveEdit" runat="server" Text="Save Changes" CssClass="btn-admin-primary" OnClick="btnSaveEdit_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <%-- Custom Delete Confirmation Modal --%>
    <div id="confirmModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.75);z-index:2000;align-items:center;justify-content:center;">
        <div style="background:#0d1520;border:1px solid #1a3050;border-radius:12px;padding:28px 28px 24px;width:100%;max-width:400px;box-shadow:0 8px 40px rgba(0,0,0,0.6);">
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
                <div id="confirmIcon" style="width:42px;height:42px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;"></div>
                <h3 id="confirmTitle" style="font-family:'Rajdhani',sans-serif;font-size:18px;font-weight:700;color:#e8f4ff;margin:0;"></h3>
            </div>
            <p id="confirmBody" style="font-size:13px;color:#5a7a99;line-height:1.6;margin:0 0 24px;padding-left:54px;"></p>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <button type="button" onclick="closeConfirm()"
                    style="padding:9px 20px;border-radius:7px;border:1px solid #1a3050;background:transparent;color:#5a7a99;font-family:'Rajdhani',sans-serif;font-size:13px;font-weight:600;cursor:pointer;letter-spacing:.5px;">
                    CANCEL
                </button>
                <button type="button" id="confirmOkBtn"
                    style="padding:9px 20px;border-radius:7px;border:none;font-family:'Rajdhani',sans-serif;font-size:13px;font-weight:700;cursor:pointer;letter-spacing:.5px;">
                    CONFIRM
                </button>
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
        .btn-ghost           { padding:9px 20px; border:1px solid var(--cyber-border,#1a3050); background:transparent; color:var(--cyber-text,#c8dff0); font-family:'Rajdhani',sans-serif; font-size:13px; font-weight:600; letter-spacing:1px; border-radius:5px; cursor:pointer; text-transform:uppercase; transition:all 0.2s; }
        .btn-ghost:hover     { border-color:var(--cyber-accent,#00d4ff); color:var(--cyber-accent,#00d4ff); }
    </style>

    <script type="text/javascript">
        var _confirmCallback = null;
        function openConfirm(type, forumId) {
            var modal  = document.getElementById('confirmModal');
            var icon   = document.getElementById('confirmIcon');
            var title  = document.getElementById('confirmTitle');
            var body   = document.getElementById('confirmBody');
            var okBtn  = document.getElementById('confirmOkBtn');
            if (type === 'hard') {
                icon.innerHTML  = '<i class="ti ti-alert-triangle"></i>';
                icon.style.background = 'rgba(255,59,92,0.15)';
                icon.style.color      = '#ff3b5c';
                title.textContent = 'Permanently Delete?';
                body.textContent  = 'This post will be erased forever and cannot be recovered. Are you sure?';
                okBtn.style.background = '#ff3b5c';
                okBtn.style.color      = '#fff';
                _confirmCallback = function() { submitCommand('HardDelete', forumId); };
            } else {
                icon.innerHTML  = '<i class="ti ti-trash"></i>';
                icon.style.background = 'rgba(255,59,92,0.12)';
                icon.style.color      = '#ff3b5c';
                title.textContent = 'Delete Post?';
                body.textContent  = 'This post will be removed. You can restore it later from this panel.';
                okBtn.style.background = '#ff3b5c';
                okBtn.style.color      = '#fff';
                _confirmCallback = function() { submitCommand('SoftDelete', forumId); };
            }
            modal.style.display = 'flex';
        }
        function closeConfirm() {
            document.getElementById('confirmModal').style.display = 'none';
            _confirmCallback = null;
        }
        document.getElementById('confirmOkBtn').addEventListener('click', function() {
            var cb = _confirmCallback;
            closeConfirm();
            if (cb) cb();
        });
        document.getElementById('confirmModal').addEventListener('click', function(e) {
            if (e.target === this) closeConfirm();
        });

        function openEditModal(btn) {
            var id    = btn.dataset.id;
            var title = btn.dataset.title;
            var body  = btn.dataset.body;
            var cat   = btn.dataset.cat;
            document.getElementById('<%= hdnEditId.ClientID %>').value       = id;
            document.getElementById('<%= txtEditTitle.ClientID %>').value    = title || '';
            document.getElementById('<%= txtEditBody.ClientID %>').value     = body  || '';
            var ddl = document.getElementById('<%= ddlEditCategory.ClientID %>');
            if (ddl) ddl.value = cat || '';
            editClearAttach();
            document.getElementById('editModal').style.display = 'flex';
        }
        function closeEditModal() { document.getElementById('editModal').style.display = 'none'; }

        function editPreviewAttach(input) {
            if (!input.files || !input.files[0]) return;
            document.getElementById('editAttachName').textContent = input.files[0].name;
            document.getElementById('editAttachDropZone').style.display = 'none';
            document.getElementById('editAttachPreview').style.display = 'block';
        }
        function editClearAttach() {
            var fu = document.getElementById('<%= fuEditAttachment.ClientID %>');
            if (fu) fu.value = '';
            document.getElementById('editAttachDropZone').style.display = '';
            document.getElementById('editAttachPreview').style.display = 'none';
        }

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
        window.addEventListener('load', function() { document.getElementById('editModal').style.display = 'flex'; });
        <%} %>

        function adminPreviewAttach(input) {
            if (!input.files || !input.files[0]) return;
            document.getElementById('adminAttachName').textContent = input.files[0].name;
            document.getElementById('adminAttachDropZone').style.display = 'none';
            document.getElementById('adminAttachPreview').style.display = 'block';
        }
        function adminClearAttach() {
            var fu = document.getElementById('<%= fuCreateAttachment.ClientID %>');
            fu.value = '';
            document.getElementById('adminAttachDropZone').style.display = '';
            document.getElementById('adminAttachPreview').style.display = 'none';
        }
    </script>

</asp:Content>
