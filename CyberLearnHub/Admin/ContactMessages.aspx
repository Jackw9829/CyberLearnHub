<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContactMessages.aspx.cs"
         Inherits="CyberLearnHub.Admin.ContactMessages" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Contact Messages</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <!-- Detail modal -->
    <asp:Panel ID="pnlDetail" runat="server" Visible="false" CssClass="admin-card"
               Style="background:var(--cyber-surface);margin-bottom:24px;">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;">
            <div class="admin-card-title" style="margin-bottom:0;">
                <i class="ti ti-mail-opened"></i>
                <asp:Literal ID="litDetailSubject" runat="server" />
            </div>
            <asp:Button ID="btnCloseDetail" runat="server" Text="&times; Close"
                        CssClass="btn-secondary" OnClick="btnCloseDetail_Click" CausesValidation="false" />
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:18px;">
            <div>
                <div style="font-family:'Share Tech Mono',monospace;font-size:10px;letter-spacing:1.5px;text-transform:uppercase;color:var(--cyber-accent);margin-bottom:5px;">From</div>
                <div style="font-size:13px;color:var(--cyber-text);">
                    <asp:Literal ID="litDetailName" runat="server" />
                </div>
                <div style="font-size:12px;color:var(--cyber-muted);">
                    <asp:Literal ID="litDetailEmail" runat="server" />
                </div>
            </div>
            <div>
                <div style="font-family:'Share Tech Mono',monospace;font-size:10px;letter-spacing:1.5px;text-transform:uppercase;color:var(--cyber-accent);margin-bottom:5px;">Received</div>
                <div style="font-size:13px;color:var(--cyber-text);">
                    <asp:Literal ID="litDetailDate" runat="server" />
                </div>
            </div>
        </div>

        <div style="font-family:'Share Tech Mono',monospace;font-size:10px;letter-spacing:1.5px;text-transform:uppercase;color:var(--cyber-accent);margin-bottom:8px;">Message</div>
        <div style="background:var(--cyber-card);border:1px solid var(--cyber-border);border-radius:8px;padding:18px 20px;font-size:13px;color:var(--cyber-text);line-height:1.75;white-space:pre-wrap;">
            <asp:Literal ID="litDetailMessage" runat="server" />
        </div>

        <div style="margin-top:16px;display:flex;gap:10px;">
            <a id="aReply" runat="server" class="btn-admin-primary"
               style="display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:6px;font-size:13px;text-decoration:none;">
                <i class="ti ti-send"></i> Reply via Email
            </a>
        </div>
    </asp:Panel>

    <!-- Messages table -->
    <div class="admin-card">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;flex-wrap:wrap;gap:10px;">
            <div class="admin-card-title" style="margin-bottom:0;">
                <i class="ti ti-messages"></i> Contact Messages
                <asp:Label ID="lblUnreadBadge" runat="server"
                    Style="margin-left:10px;background:var(--cyber-danger);color:#fff;border-radius:12px;padding:2px 9px;font-size:11px;font-family:'Share Tech Mono',monospace;" />
            </div>
            <asp:Button ID="btnMarkAllRead" runat="server" Text="Mark All as Read"
                        CssClass="btn-secondary" OnClick="btnMarkAllRead_Click" CausesValidation="false" />
        </div>

        <asp:Repeater ID="rptMessages" runat="server" OnItemCommand="rptMessages_ItemCommand">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th style="width:24px;"></th>
                    <th>From</th>
                    <th>Subject</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr></thead>
                <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr style='<%# (bool)Eval("IsRead") ? "" : "background:rgba(0,212,255,0.04);font-weight:600;" %>'>
                    <td>
                        <%# (bool)Eval("IsRead")
                            ? "<i class=\"ti ti-mail\" style=\"color:var(--cyber-muted);font-size:14px;\"></i>"
                            : "<i class=\"ti ti-mail-unread\" style=\"color:var(--cyber-accent);font-size:14px;\"></i>" %>
                    </td>
                    <td>
                        <div style="font-size:13px;"><%# Eval("SenderName") %></div>
                        <div style="font-size:11px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;"><%# Eval("SenderEmail") %></div>
                    </td>
                    <td style="font-size:13px;"><%# Eval("Subject") %></td>
                    <td style="font-size:12px;color:var(--cyber-muted);white-space:nowrap;">
                        <%# ((DateTime)Eval("SentDate")).ToString("dd MMM yyyy HH:mm") %>
                    </td>
                    <td>
                        <div style="display:flex;gap:8px;">
                            <asp:LinkButton runat="server" CommandName="View" CommandArgument='<%# Eval("MessageID") %>'
                                CssClass="btn-admin-primary"
                                Style="padding:5px 12px;font-size:12px;border-radius:5px;">
                                <i class="ti ti-eye"></i> View
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="Delete" CommandArgument='<%# Eval("MessageID") %>'
                                CssClass="btn-danger"
                                Style="padding:5px 12px;font-size:12px;border-radius:5px;"
                                OnClientClick="return confirm('Delete this message?');">
                                <i class="ti ti-trash"></i>
                            </asp:LinkButton>
                        </div>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                </tbody></table>
            </FooterTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false"
                   Style="text-align:center;padding:48px 20px;color:var(--cyber-muted);font-size:13px;">
            <i class="ti ti-inbox" style="font-size:40px;display:block;margin-bottom:12px;color:var(--cyber-border);"></i>
            No contact messages yet.
        </asp:Panel>
    </div>

</asp:Content>
