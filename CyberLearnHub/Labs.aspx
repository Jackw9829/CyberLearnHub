<%@ Page Title="Labs" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Labs.aspx.cs" Inherits="CyberLearnHub.Labs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .labs-container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 32px 16px;
        }

        .labs-header {
            margin-bottom: 28px;
        }

        .labs-header h1 {
            font-family: 'Rajdhani', sans-serif;
            font-size: 28px;
            color: var(--cyber-accent);
            margin: 0 0 6px 0;
        }

        .labs-header p {
            color: #9aa4ad;
            font-family: 'Share Tech Mono', monospace;
            font-size: 14px;
        }

        .lab-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 20px;
        }

        .lab-card {
            background: var(--cyber-card);
            border: 1px solid #2a3540;
            border-radius: 8px;
            padding: 20px;
            position: relative;
            transition: border-color 0.2s ease;
        }

        .lab-card:hover {
            border-color: var(--cyber-accent);
        }

        .lab-card.solved {
            border-color: #2ecc71;
        }

        .lab-card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 10px;
        }

        .lab-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 19px;
            color: #e6edf3;
            margin: 0;
        }

        .lab-badge {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            padding: 3px 9px;
            border-radius: 4px;
            white-space: nowrap;
            text-transform: uppercase;
        }

        .badge-easy   { background: rgba(46, 204, 113, 0.15); color: #2ecc71; }
        .badge-medium { background: rgba(241, 196, 15, 0.15);  color: #f1c40f; }
        .badge-hard   { background: rgba(231, 76, 60, 0.15);   color: #e74c3c; }

        .solved-tag {
            display: inline-block;
            color: #2ecc71;
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            background: rgba(46, 204, 113, 0.12);
            border: 1px solid rgba(46, 204, 113, 0.35);
            padding: 3px 9px;
            border-radius: 4px;
            white-space: nowrap;
        }

        .lab-desc {
            color: #9aa4ad;
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 10px;
        }

        .lab-target {
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            color: var(--cyber-accent);
            background: rgba(0, 255, 200, 0.06);
            padding: 6px 10px;
            border-radius: 4px;
            margin-bottom: 14px;
            display: inline-block;
        }

        .lab-points {
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
            color: #f1c40f;
        }

        .lab-actions {
            display: flex;
            gap: 8px;
            margin-top: 14px;
        }

        .btn-vpn {
            background: transparent;
            border: 1px solid var(--cyber-accent);
            color: var(--cyber-accent);
            padding: 8px 14px;
            border-radius: 6px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-vpn:hover {
            background: rgba(0, 255, 200, 0.08);
        }

        .btn-attackbox {
            background: transparent;
            border: 1px solid #f1c40f;
            color: #f1c40f;
            padding: 8px 14px;
            border-radius: 6px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-attackbox:hover {
            background: rgba(241, 196, 15, 0.08);
        }

        .flag-row {
            display: flex;
            gap: 8px;
            margin-top: 12px;
        }

        .flag-input {
            flex: 1;
            background: #10151a;
            border: 1px solid #2a3540;
            color: #e6edf3;
            padding: 8px 10px;
            border-radius: 6px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
        }

        .btn-submit-flag {
            background: var(--cyber-accent);
            border: none;
            color: #0b0f12;
            padding: 8px 16px;
            border-radius: 6px;
            font-family: 'Rajdhani', sans-serif;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
        }

        .flag-msg {
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            margin-top: 8px;
            min-height: 16px;
            display: block;
        }

        .flag-msg.success { color: #2ecc71; }
        .flag-msg.error   { color: #e74c3c; }

        .no-labs {
            color: #9aa4ad;
            font-family: 'Share Tech Mono', monospace;
            text-align: center;
            padding: 40px 0;
        }

        /* Lab materials */
        .lab-materials {
            margin-top: 14px;
            border-top: 1px solid rgba(42,53,64,0.7);
            padding-top: 10px;
        }

        .lab-materials-title {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: #9aa4ad;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }

        .material-link {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 5px 0;
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            color: var(--cyber-accent);
            text-decoration: none;
            background: none;
            border: none;
            cursor: pointer;
        }

        .material-link:hover { color: #33ddff; text-decoration: underline; }

        .material-size {
            color: #9aa4ad;
            font-size: 11px;
        }
    </style>
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
