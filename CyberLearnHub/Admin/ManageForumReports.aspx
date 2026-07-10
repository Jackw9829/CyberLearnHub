<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageForumReports.aspx.cs"
         Inherits="CyberLearnHub.Admin.ManageForumReports" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Manage Forum Reports</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <!-- Filter bar -->
    <div class="admin-card" style="margin-bottom:20px;">
        <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;">
            <label style="font-family:'Share Tech Mono',monospace;font-size:11px;color:var(--cyber-muted);text-transform:uppercase;letter-spacing:1px;">Filter:</label>
            <asp:DropDownList ID="ddlFilter" runat="server" CssClass="form-control" Style="width:160px;" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                <asp:ListItem Value="all"      Text="All Reports"    />
                <asp:ListItem Value="open"     Text="Open Only"      Selected="True" />
                <asp:ListItem Value="resolved" Text="Resolved Only"  />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control" Style="width:160px;" AutoPostBack="true" OnSelectedIndexChanged="ddlType_Changed">
                <asp:ListItem Value="all"     Text="All Types"  />
                <asp:ListItem Value="Forum"   Text="Forum Posts" />
                <asp:ListItem Value="Comment" Text="Comments"   />
            </asp:DropDownList>
            <asp:Label ID="lblCount" runat="server" style="margin-left:auto;font-family:'Share Tech Mono',monospace;font-size:11px;color:var(--cyber-muted);" />
        </div>
    </div>

    <!-- Reports table -->
    <div class="admin-card">
        <div class="admin-card-title"><i class="ti ti-flag"></i> Forum Reports</div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div style="text-align:center;padding:40px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:12px;">
                <i class="ti ti-flag-off" style="font-size:36px;display:block;margin-bottom:12px;color:var(--cyber-border);"></i>
                &gt; No reports found.
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlTable" runat="server" Visible="false">
            <div style="overflow-x:auto;">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th style="width:60px;">ID</th>
                            <th style="width:80px;">Type</th>
                            <th>Reported Content</th>
                            <th style="width:140px;">Reporter</th>
                            <th>Reason</th>
                            <th style="width:110px;">Date</th>
                            <th style="width:90px;">Status</th>
                            <th style="width:140px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
                            <ItemTemplate>
                                <tr style='<%# (bool)Eval("IsResolved") ? "opacity:0.55;" : "" %>'>
                                    <td style="font-family:'Share Tech Mono',monospace;font-size:11px;color:var(--cyber-muted);">#<%# Eval("ReportID") %></td>
                                    <td>
                                        <span style='font-family:"Share Tech Mono",monospace;font-size:10px;padding:2px 8px;border-radius:4px;
                                              <%# (string)Eval("TargetType") == "Forum"
                                                  ? "background:rgba(0,212,255,0.1);color:var(--cyber-accent);"
                                                  : "background:rgba(0,255,157,0.1);color:var(--cyber-accent2);" %>'>
                                            <%# Server.HtmlEncode((string)Eval("TargetType")) %>
                                        </span>
                                    </td>
                                    <td>
                                        <div style="font-size:13px;color:var(--cyber-text);max-width:220px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"
                                             title="<%# Server.HtmlEncode((string)Eval("ContentPreview")) %>">
                                            <%# Server.HtmlEncode((string)Eval("ContentPreview")) %>
                                        </div>
                                        <div style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);margin-top:2px;">
                                            by <%# Server.HtmlEncode((string)Eval("ContentAuthor")) %>
                                            &nbsp;&bull;&nbsp;
                                            <a href='<%# GetViewLink((string)Eval("TargetType"), (int)Eval("TargetID"), (int)Eval("ForumID")) %>'
                                               target="_blank" style="color:var(--cyber-accent);text-decoration:none;">view &rarr;</a>
                                        </div>
                                    </td>
                                    <td style="font-family:'Share Tech Mono',monospace;font-size:11px;">
                                        <%# Server.HtmlEncode((string)Eval("ReporterName")) %>
                                    </td>
                                    <td>
                                        <div style="font-size:12px;color:var(--cyber-text);max-width:200px;word-break:break-word;">
                                            <%# Server.HtmlEncode((string)Eval("Reason")) %>
                                        </div>
                                    </td>
                                    <td style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);">
                                        <%# ((DateTime)Eval("CreatedAt")).ToString("dd MMM yyyy") %><br />
                                        <%# ((DateTime)Eval("CreatedAt")).ToString("HH:mm") %>
                                    </td>
                                    <td>
                                        <span style='font-family:"Share Tech Mono",monospace;font-size:10px;padding:2px 8px;border-radius:4px;
                                              <%# (bool)Eval("IsResolved")
                                                  ? "background:rgba(0,255,157,0.1);color:var(--cyber-accent2);"
                                                  : "background:rgba(255,59,92,0.12);color:var(--cyber-danger);" %>'>
                                            <%# (bool)Eval("IsResolved") ? "RESOLVED" : "OPEN" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                            <asp:LinkButton ID="btnResolve" runat="server"
                                                CommandName='<%# (bool)Eval("IsResolved") ? "Unresolve" : "Resolve" %>'
                                                CommandArgument='<%# Eval("ReportID") %>'
                                                CssClass="btn-admin-sm"
                                                Style='<%# (bool)Eval("IsResolved") ? "background:rgba(255,255,255,0.05);color:var(--cyber-muted);" : "background:rgba(0,255,157,0.1);color:var(--cyber-accent2);border-color:var(--cyber-accent2);" %>'
                                                OnClientClick="return true;"
                                                CausesValidation="false">
                                                <i class='<%# (bool)Eval("IsResolved") ? "ti ti-refresh" : "ti ti-check" %>'></i>
                                                <%# (bool)Eval("IsResolved") ? "Reopen" : "Resolve" %>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server"
                                                CommandName="Delete"
                                                CommandArgument='<%# Eval("ReportID") %>'
                                                CssClass="btn-admin-sm btn-admin-danger"
                                                OnClientClick="return confirm('Delete this report permanently?');"
                                                CausesValidation="false">
                                                <i class="ti ti-trash"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </asp:Panel>
    </div>

</asp:Content>
