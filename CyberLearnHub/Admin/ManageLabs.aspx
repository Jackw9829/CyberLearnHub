<%@ Page Title="Manage Labs" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="ManageLabs.aspx.cs" Inherits="CyberLearnHub.ManageLabs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/admin-manage-labs.css") %>" />
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

            <div class="checkbox-row">
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
