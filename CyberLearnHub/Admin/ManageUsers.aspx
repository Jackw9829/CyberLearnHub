<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs"
         Inherits="CyberLearnHub.Admin.ManageUsers" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Manage Users</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <!-- Add / Edit user form -->
    <asp:Panel ID="pnlUserForm" runat="server" Visible="false" DefaultButton="btnSaveUser"
        CssClass="admin-card" Style="background:var(--cyber-surface);">
        <div class="admin-card-title">
            <i class="ti ti-user-plus"></i> <asp:Literal ID="litFormTitle" runat="server" Text="Add User" />
        </div>

        <asp:HiddenField ID="hdnUserId" runat="server" />

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Full Name</label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvName" runat="server"
                    ControlToValidate="txtName" ValidationGroup="vgUser"
                    CssClass="form-error" ErrorMessage="&gt; Name is required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label class="form-label">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" MaxLength="150" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                    ControlToValidate="txtEmail" ValidationGroup="vgUser"
                    CssClass="form-error" ErrorMessage="&gt; Email is required." Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtEmail" ValidationGroup="vgUser"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    CssClass="form-error" ErrorMessage="&gt; Enter a valid email." Display="Dynamic" />
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Role</label>
                <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control">
                    <asp:ListItem Value="Member">Member</asp:ListItem>
                    <asp:ListItem Value="Admin">Admin</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="form-group">
                <label class="form-label">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control"
                    TextMode="Password" MaxLength="100" />
                <span class="form-hint">Required for new users (min 6 chars). Leave blank when editing to keep the current password.</span>
            </div>
        </div>

        <div style="display:flex;gap:10px;margin-top:6px;">
            <asp:Button ID="btnSaveUser" runat="server" Text="Save User"
                CssClass="btn-admin-primary" ValidationGroup="vgUser" OnClick="btnSaveUser_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                CssClass="btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
        </div>
    </asp:Panel>

    <div class="admin-card">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;flex-wrap:wrap;gap:10px;">
            <div class="admin-card-title" style="margin-bottom:0;"><i class="ti ti-users"></i> All Users</div>
            <asp:Button ID="btnShowAdd" runat="server" Text="+ Add User"
                CssClass="btn-admin-primary" OnClick="btnShowAdd_Click" CausesValidation="false" />
        </div>

        <asp:Repeater ID="rptUsers" runat="server">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr></thead>
                <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="color:var(--cyber-heading);font-weight:500;"><%# Server.HtmlEncode(Eval("FullName") as string) %></td>
                    <td style="font-family:'Share Tech Mono',monospace;font-size:11px;color:var(--cyber-muted);"><%# Server.HtmlEncode(Eval("Email") as string) %></td>
                    <td>
                        <%# Eval("Role") as string == "Admin"
                            ? "<span class=\"badge badge-admin\">Admin</span>"
                            : "<span class=\"badge badge-member\">Member</span>" %>
                    </td>
                    <td>
                        <%# Convert.ToBoolean(Eval("IsActive"))
                            ? "<span class=\"badge badge-pub\">Active</span>"
                            : "<span class=\"badge badge-draft\">Inactive</span>" %>
                    </td>
                    <td>
                        <div style="display:flex;gap:6px;flex-wrap:wrap;">
                            <asp:LinkButton ID="lbEdit" runat="server"
                                CommandName="Edit"
                                CommandArgument='<%# Eval("UserID") %>'
                                OnCommand="lbAction_Command"
                                CausesValidation="false"
                                CssClass="btn-admin-sm btn-edit">Edit</asp:LinkButton>

                            <asp:LinkButton ID="lbToggleActive" runat="server"
                                CommandName="ToggleActive"
                                CommandArgument='<%# Eval("UserID") + "," + Eval("IsActive") %>'
                                OnCommand="lbAction_Command"
                                CausesValidation="false"
                                CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "btn-admin-sm btn-delete" : "btn-admin-sm btn-view" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>
                            </asp:LinkButton>

                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandName="Delete"
                                CommandArgument='<%# Eval("UserID") %>'
                                OnCommand="lbAction_Command"
                                CausesValidation="false"
                                OnClientClick="return confirm('Delete this user permanently? This cannot be undone.');"
                                CssClass="btn-admin-sm btn-delete"
                                Visible='<%# (int)Eval("UserID") != (int)Session["UserID"] %>'>Delete</asp:LinkButton>
                        </div>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
    </div>

</asp:Content>
