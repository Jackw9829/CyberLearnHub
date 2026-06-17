<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageContent.aspx.cs"
         Inherits="CyberLearnHub.Admin.ManageContent" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Website Content</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .content-body-preview {
            max-width: 320px; overflow: hidden;
            white-space: nowrap; text-overflow: ellipsis;
            display: block; color: var(--cyber-muted); font-size: 12px;
        }
        .inline-edit-area { display: none; margin-top: 16px; }
        .inline-edit-area.open { display: block; }
    </style>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <div class="admin-card">
        <div class="admin-card-title" style="justify-content:space-between;">
            <span><i class="ti ti-layout"></i> Website Content Blocks</span>
            <a href="ContentForm.aspx" class="btn-admin-primary"><i class="ti ti-plus"></i> Add Block</a>
        </div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div style="text-align:center;padding:40px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:12px;letter-spacing:1px;">
                <i class="ti ti-layout-off" style="font-size:36px;display:block;margin-bottom:12px;color:var(--cyber-border);"></i>
                &gt; No content blocks yet.
            </div>
        </asp:Panel>

        <asp:Repeater ID="rptContent" runat="server">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>Section Key</th>
                    <th>Title</th>
                    <th>Body Preview</th>
                    <th>Last Updated</th>
                    <th>Actions</th>
                </tr></thead>
                <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="font-family:'Share Tech Mono',monospace;font-size:11px;color:var(--cyber-accent);"><%# Server.HtmlEncode(Eval("SectionKey") as string) %></td>
                    <td style="color:var(--cyber-heading);font-weight:500;"><%# Server.HtmlEncode(Eval("Title") as string) %></td>
                    <td><span class="content-body-preview"><%# Server.HtmlEncode(Eval("Body") as string ?? "") %></span></td>
                    <td style="color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:11px;">
                        <%# Eval("UpdatedDate") != DBNull.Value ? Convert.ToDateTime(Eval("UpdatedDate")).ToString("dd MMM yyyy") : "—" %>
                    </td>
                    <td>
                        <div style="display:flex;gap:6px;">
                            <a href='ContentForm.aspx?id=<%# Eval("ContentID") %>' class="btn-admin-sm btn-edit"><i class="ti ti-pencil"></i> Edit</a>
                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandArgument='<%# Eval("ContentID") %>'
                                OnClick="lbDelete_Click"
                                CssClass="btn-admin-sm btn-delete"
                                OnClientClick="return confirm('Delete this content block?');">
                                <i class="ti ti-trash"></i> Delete
                            </asp:LinkButton>
                        </div>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
    </div>

</asp:Content>
