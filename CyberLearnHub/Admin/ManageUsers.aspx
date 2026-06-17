<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs"
         Inherits="CyberLearnHub.Admin.ManageUsers" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Manage Users</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <div class="admin-card">
        <div class="admin-card-title"><i class="ti ti-users"></i> All Users</div>

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
                            <asp:LinkButton ID="lbToggleActive" runat="server"
                                CommandName="ToggleActive"
                                CommandArgument='<%# Eval("UserID") + "," + Eval("IsActive") %>'
                                OnCommand="lbAction_Command"
                                CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "btn-admin-sm btn-delete" : "btn-admin-sm btn-view" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>
                            </asp:LinkButton>
                            <asp:LinkButton ID="lbToggleRole" runat="server"
                                CommandName="ToggleRole"
                                CommandArgument='<%# Eval("UserID") + "," + Eval("Role") %>'
                                OnCommand="lbAction_Command"
                                CssClass="btn-admin-sm btn-edit"
                                Visible='<%# (int)Eval("UserID") != (int)Session["UserID"] %>'>
                                <%# Eval("Role") as string == "Admin" ? "Make Member" : "Make Admin" %>
                            </asp:LinkButton>
                        </div>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
    </div>

</asp:Content>
