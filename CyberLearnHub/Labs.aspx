<%@ Page Title="Labs" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Labs.aspx.cs" Inherits="CyberLearnHub.Labs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/labs.css") %>" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="labs-container">
        <div class="labs-header">
            <h1><i class="ti ti-target"></i> Labs</h1>
            <p>Connect via VPN, attack the target machine, and submit your flag.</p>
        </div>

        <asp:Repeater ID="rptLabs" runat="server" OnItemCommand="rptLabs_ItemCommand" OnItemDataBound="rptLabs_ItemDataBound">
            <HeaderTemplate>
                <div class="lab-grid">
            </HeaderTemplate>
            <ItemTemplate>
                <div class='<%# (bool)Eval("IsSolved") ? "lab-card solved" : "lab-card" %>'>

                    <div class="lab-card-top">
                        <h3 class="lab-title"><%# Server.HtmlEncode(Eval("Title") as string) %></h3>
                        <div style="display:flex;gap:6px;align-items:center;flex-shrink:0;">
                            <span class='<%# "lab-badge badge-" + Eval("Difficulty").ToString().ToLower() %>'><%# Eval("Difficulty") %></span>
                            <asp:Label ID="lblSolvedTag" runat="server" CssClass="solved-tag"
                                Text="&#10003; SOLVED" Visible='<%# (bool)Eval("IsSolved") %>' />
                        </div>
                    </div>

                    <p class="lab-desc"><%# Server.HtmlEncode(Eval("Description") as string) %></p>

                    <asp:Label ID="lblTarget" runat="server" CssClass="lab-target"
                        Text='<%# Server.HtmlEncode(Eval("TargetInfo") as string ?? "") %>'
                        Visible='<%# !string.IsNullOrEmpty(Eval("TargetInfo") as string) %>' />

                    <div>
                        <span class="lab-points"><i class="ti ti-star"></i> <%# Eval("Points") %> pts</span>
                    </div>

                    <div class="lab-actions">
                        <asp:LinkButton ID="btnDownloadVpn" runat="server" CssClass="btn-vpn" CommandName="DownloadVpn">
                            <i class="ti ti-download"></i> Download VPN
                        </asp:LinkButton>
                        <a class="btn-attackbox" href="<%= AttackBoxUrl %>" target="_blank" rel="noopener">
                            <i class="ti ti-terminal-2"></i> Open Attack Box
                        </a>
                    </div>

                    <div class="flag-row">
                        <asp:TextBox ID="txtFlag" runat="server" CssClass="flag-input" placeholder="flag{...}" />
                        <asp:LinkButton ID="btnSubmitFlag" runat="server" CssClass="btn-submit-flag"
                            CommandName="SubmitFlag" CommandArgument='<%# Eval("LabId") %>'>Submit</asp:LinkButton>
                    </div>

                    <asp:Label ID="lblFlagMsg" runat="server" CssClass="flag-msg" />

                    <%-- Materials download section --%>
                    <asp:Panel ID="pnlLabMaterials" runat="server" CssClass="lab-materials" Visible="false">
                        <div class="lab-materials-title"><i class="ti ti-paperclip"></i> Materials</div>
                        <asp:Repeater ID="rptLabMaterials" runat="server" OnItemCommand="rptLabs_ItemCommand">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CssClass="material-link"
                                    CommandName="DownloadMaterial"
                                    CommandArgument='<%# Eval("MaterialId") %>'>
                                    <i class="ti ti-file-download"></i>
                                    <%# Server.HtmlEncode(Eval("FileName") as string) %>
                                    <span class="material-size">(<%# Eval("FileSizeDisplay") %>)</span>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                    </asp:Panel>
                </div>
            </ItemTemplate>
            <FooterTemplate>
                </div>
            </FooterTemplate>
        </asp:Repeater>

        <asp:Label ID="lblNoLabs" runat="server" CssClass="no-labs"
            Text="No labs available right now. Check back soon!" Visible="false" />
    </div>
</asp:Content>
