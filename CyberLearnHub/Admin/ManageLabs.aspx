<%@ Page Title="Manage Labs" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="ManageLabs.aspx.cs" Inherits="CyberLearnHub.ManageLabs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .manage-labs-container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 32px 16px;
        }

        .manage-labs-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .manage-labs-header h1 {
            font-family: 'Rajdhani', sans-serif;
            font-size: 28px;
            color: var(--cyber-accent);
            margin: 0;
        }

        .btn-new-lab {
            background: var(--cyber-accent);
            color: #0b0f12;
            border: none;
            padding: 10px 18px;
            border-radius: 6px;
            font-family: 'Rajdhani', sans-serif;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
        }

        .form-panel {
            background: var(--cyber-card);
            border: 1px solid #2a3540;
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 24px;
        }

        .form-panel h2 {
            font-family: 'Rajdhani', sans-serif;
            font-size: 18px;
            color: #e6edf3;
            margin: 0 0 16px 0;
        }

        .form-row {
            margin-bottom: 14px;
        }

        .form-row label {
            display: block;
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            color: #9aa4ad;
            margin-bottom: 6px;
        }

        .form-row input[type=text],
        .form-row textarea,
        .form-row select {
            width: 100%;
            background: #10151a;
            border: 1px solid #2a3540;
            color: #e6edf3;
            padding: 9px 10px;
            border-radius: 6px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
            box-sizing: border-box;
        }

        .form-row textarea {
            min-height: 70px;
            resize: vertical;
        }

        .form-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 6px;
        }

        .btn-save {
            background: var(--cyber-accent);
            color: #0b0f12;
            border: none;
            padding: 9px 18px;
            border-radius: 6px;
            font-family: 'Rajdhani', sans-serif;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-cancel {
            background: transparent;
            border: 1px solid #2a3540;
            color: #9aa4ad;
            padding: 9px 18px;
            border-radius: 6px;
            font-family: 'Rajdhani', sans-serif;
            cursor: pointer;
            text-decoration: none;
        }

        .labs-grid {
            width: 100%;
            border-collapse: collapse;
            background: var(--cyber-card);
            border: 1px solid #2a3540;
            border-radius: 8px;
            overflow: hidden;
        }

        .labs-grid th {
            background: #161d24;
            color: var(--cyber-accent);
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            text-transform: uppercase;
            text-align: left;
            padding: 12px 14px;
        }

        .labs-grid td {
            padding: 12px 14px;
            border-top: 1px solid #2a3540;
            color: #e6edf3;
            font-size: 14px;
            vertical-align: top;
        }

        .grid-btn {
            background: transparent;
            border: 1px solid #2a3540;
            color: #e6edf3;
            padding: 5px 12px;
            border-radius: 5px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            cursor: pointer;
            margin-right: 6px;
            text-decoration: none;
        }

        .grid-btn.edit:hover   { border-color: var(--cyber-accent); color: var(--cyber-accent); }
        .grid-btn.delete:hover { border-color: #e74c3c; color: #e74c3c; }

        .badge-active   { color: #2ecc71; font-family: 'Share Tech Mono', monospace; font-size: 12px; }
        .badge-inactive { color: #9aa4ad; font-family: 'Share Tech Mono', monospace; font-size: 12px; }

        .status-msg {
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
            margin-bottom: 16px;
            padding: 10px 14px;
            border-radius: 6px;
            display: block;
        }

        .status-msg.success { background: rgba(46,204,113,0.1); color: #2ecc71; }
        .status-msg.error   { background: rgba(231,76,60,0.1);  color: #e74c3c; }

        /* Materials section */
        .materials-section {
            border-top: 1px solid #2a3540;
            margin-top: 20px;
            padding-top: 18px;
        }

        .materials-section h3 {
            font-family: 'Rajdhani', sans-serif;
            font-size: 15px;
            color: var(--cyber-accent);
            margin: 0 0 12px 0;
            letter-spacing: 0.5px;
        }

        .materials-list {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 14px;
            font-size: 13px;
        }

        .materials-list th {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: #9aa4ad;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 6px 10px;
            text-align: left;
            border-bottom: 1px solid #2a3540;
        }

        .materials-list td {
            padding: 8px 10px;
            border-bottom: 1px solid rgba(42,53,64,0.5);
            color: #e6edf3;
            vertical-align: middle;
        }

        .no-materials-msg {
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            color: #9aa4ad;
            padding: 8px 0;
            margin-bottom: 14px;
        }

        .upload-row {
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }

        /* Hide the native file input; overlay it on a styled display */
        .file-input-wrapper {
            position: relative;
            flex: 1;
            min-width: 200px;
        }

        .file-input-wrapper input[type=file] {
            position: absolute;
            inset: 0;
            opacity: 0;
            width: 100%;
            height: 100%;
            cursor: pointer;
            z-index: 2;
        }

        .file-input-display {
            display: flex;
            align-items: center;
            background: #10151a;
            border: 1px solid #2a3540;
            border-radius: 6px;
            overflow: hidden;
            transition: border-color 0.2s;
            height: 38px;
        }

        .file-input-wrapper:hover .file-input-display,
        .file-input-wrapper:focus-within .file-input-display {
            border-color: var(--cyber-accent);
        }

        .file-input-browse {
            background: rgba(0,212,255,0.08);
            border-right: 1px solid #2a3540;
            color: var(--cyber-accent);
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            padding: 0 14px;
            white-space: nowrap;
            height: 100%;
            display: flex;
            align-items: center;
            gap: 6px;
            flex-shrink: 0;
        }

        .file-input-name {
            flex: 1;
            color: #9aa4ad;
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            padding: 0 12px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .btn-upload {
            background: var(--cyber-accent);
            border: none;
            color: #0b0f12;
            padding: 0 18px;
            height: 38px;
            border-radius: 6px;
            font-family: 'Rajdhani', sans-serif;
            font-weight: 700;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
            white-space: nowrap;
            display: flex;
            align-items: center;
            gap: 6px;
            letter-spacing: 0.5px;
        }

        .btn-upload:hover { background: #33ddff; }

        .materials-add-hint {
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            color: #9aa4ad;
            background: rgba(0,212,255,0.05);
            border: 1px dashed rgba(0,212,255,0.2);
            border-radius: 6px;
            padding: 10px 14px;
            margin-bottom: 10px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="manage-labs-container">

        <div class="manage-labs-header">
            <h1><i class="ti ti-target"></i> Manage Labs</h1>
            <asp:LinkButton ID="btnShowAddForm" runat="server" CssClass="btn-new-lab" OnClick="btnShowAddForm_Click">+ New Lab</asp:LinkButton>
        </div>

        <asp:Label ID="lblStatusMsg" runat="server" CssClass="status-msg" Visible="false" />

        <asp:Panel ID="pnlForm" runat="server" CssClass="form-panel" Visible="false">
            <h2><asp:Literal ID="litFormTitle" runat="server" Text="Add New Lab" /></h2>

            <asp:HiddenField ID="hdnLabId" runat="server" Value="0" />

            <div class="form-row">
                <label>Title</label>
                <asp:TextBox ID="txtTitle" runat="server" />
            </div>

            <div class="form-row">
                <label>Description</label>
                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" />
            </div>

            <div class="form-row">
                <label>Target Info (e.g. "Target: 10.0.x.x - DVWA Login Page")</label>
                <asp:TextBox ID="txtTargetInfo" runat="server" />
            </div>

            <div class="form-row">
                <label>Flag (plain text - will be hashed automatically, never stored as plain text)</label>
                <asp:TextBox ID="txtFlag" runat="server" placeholder="flag{...}" />
                <asp:Label ID="lblFlagHint" runat="server"
                    Text="Leave blank when editing to keep the existing flag unchanged."
                    Style="font-size:11px;color:#9aa4ad;font-family:'Share Tech Mono',monospace;" />
            </div>

            <div class="form-grid-2">
                <div class="form-row">
                    <label>Points</label>
                    <asp:TextBox ID="txtPoints" runat="server" Text="10" />
                </div>
                <div class="form-row">
                    <label>Difficulty</label>
                    <asp:DropDownList ID="ddlDifficulty" runat="server">
                        <asp:ListItem Text="Easy"   Value="Easy" />
                        <asp:ListItem Text="Medium" Value="Medium" />
                        <asp:ListItem Text="Hard"   Value="Hard" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="form-row">
                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" Text=" Active (visible to students)" />
            </div>

            <div class="form-actions">
                <asp:LinkButton ID="btnSave"       runat="server" CssClass="btn-save"   OnClick="btnSave_Click">Save Lab</asp:LinkButton>
                <asp:LinkButton ID="btnCancelForm" runat="server" CssClass="btn-cancel" OnClick="btnCancelForm_Click">Cancel</asp:LinkButton>
            </div>

            <%-- Materials section — always visible in the form --%>
            <asp:Panel ID="pnlMaterials" runat="server" CssClass="materials-section" Visible="true">
                <h3><i class="ti ti-paperclip"></i> Lab Materials</h3>

                <asp:Panel ID="pnlMaterialsList" runat="server" Visible="false">
                    <table class="materials-list">
                        <thead>
                            <tr>
                                <th>Filename</th>
                                <th>Size</th>
                                <th>Uploaded</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptMaterials" runat="server" OnItemCommand="rptMaterials_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Server.HtmlEncode(Eval("FileName") as string) %></td>
                                        <td style="font-family:'Share Tech Mono',monospace;font-size:12px;color:#9aa4ad;"><%# Eval("FileSizeDisplay") %></td>
                                        <td style="font-family:'Share Tech Mono',monospace;font-size:12px;color:#9aa4ad;"><%# Eval("UploadedDate", "{0:yyyy-MM-dd}") %></td>
                                        <td>
                                            <asp:LinkButton runat="server" CssClass="grid-btn delete"
                                                CommandName="DeleteMaterial"
                                                CommandArgument='<%# Eval("MaterialId") %>'
                                                OnClientClick="return confirm('Delete this file?');">Delete</asp:LinkButton>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <asp:Label ID="lblNoMaterials" runat="server" CssClass="no-materials-msg"
                        Text="No materials attached yet." Visible="false" />
                </asp:Panel>

                <asp:Panel ID="pnlUploadRow" runat="server" Visible="false">
                    <div class="upload-row">
                        <div class="file-input-wrapper">
                            <asp:FileUpload ID="fuMaterial" runat="server"
                                onchange="updateFileName(this)" />
                            <div class="file-input-display">
                                <span class="file-input-browse">
                                    <i class="ti ti-folder-open"></i> Browse
                                </span>
                                <span class="file-input-name" id="fileNameDisplay">No file chosen</span>
                            </div>
                        </div>
                        <asp:LinkButton ID="btnUploadMaterial" runat="server" CssClass="btn-upload"
                            OnClick="btnUploadMaterial_Click">
                            <i class="ti ti-upload"></i> Upload
                        </asp:LinkButton>
                    </div>
                </asp:Panel>

                <script>
                    function updateFileName(input) {
                        var lbl = document.getElementById('fileNameDisplay');
                        if (!lbl) return;
                        if (input.files && input.files.length > 0) {
                            lbl.textContent = input.files[0].name;
                            lbl.style.color = '#e6edf3';
                        } else {
                            lbl.textContent = 'No file chosen';
                            lbl.style.color = '';
                        }
                    }
                </script>
            </asp:Panel>

        </asp:Panel>

        <asp:GridView ID="gvLabs" runat="server" CssClass="labs-grid" AutoGenerateColumns="false"
            DataKeyNames="LabId" OnRowCommand="gvLabs_RowCommand" GridLines="None">
            <Columns>
                <asp:BoundField DataField="LabId"      HeaderText="ID"         ItemStyle-Width="40px" />
                <asp:BoundField DataField="Title"      HeaderText="Title" />
                <asp:BoundField DataField="Difficulty" HeaderText="Difficulty" />
                <asp:BoundField DataField="Points"     HeaderText="Points" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class='<%# (bool)Eval("IsActive") ? "badge-active" : "badge-inactive" %>'>
                            <%# (bool)Eval("IsActive") ? "ACTIVE" : "INACTIVE" %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:LinkButton runat="server" CssClass="grid-btn edit"
                            CommandName="EditLab" CommandArgument='<%# Eval("LabId") %>'>Edit</asp:LinkButton>
                        <asp:LinkButton runat="server" CssClass="grid-btn delete"
                            CommandName="DeleteLab" CommandArgument='<%# Eval("LabId") %>'
                            OnClientClick="return confirm('Delete this lab? This cannot be undone.');">Delete</asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

    </div>
</asp:Content>
