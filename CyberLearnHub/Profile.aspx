<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
         Inherits="CyberLearnHub.Profile" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Profile — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/profile.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="profile-wrap">

        <div class="profile-header">
            <div class="profile-tag">// account settings</div>
            <div class="profile-title">My Profile</div>
        </div>

        <!-- Account info card -->
        <asp:Panel ID="pnlAccountCard" runat="server" CssClass="profile-card" DefaultButton="btnSaveName">
            <div class="card-section-title"><i class="ti ti-user"></i> Account Information</div>

            <asp:Panel ID="pnlNameAlert" runat="server" Visible="false">
                <asp:Label ID="lblNameAlert" runat="server" />
            </asp:Panel>

            <div class="form-group">
                <label class="form-label">Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvFullName" runat="server"
                    ControlToValidate="txtFullName" ValidationGroup="vgName"
                    CssClass="form-error" ErrorMessage="&gt; Name is required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                    ReadOnly="true" style="opacity:0.6;cursor:not-allowed;" />
                <div style="font-size:11px;color:var(--cyber-muted);margin-top:4px;font-family:'Share Tech Mono',monospace;">
                    Email cannot be changed.
                </div>
            </div>

            <asp:Button ID="btnSaveName" runat="server" Text="Save Changes"
                CssClass="btn-save" ValidationGroup="vgName" OnClick="btnSaveName_Click" />
        </asp:Panel>

        <!-- Certificates card -->
        <div class="profile-card">
            <div class="card-section-title"><i class="ti ti-certificate"></i> My Certificates</div>

            <asp:Repeater ID="rptCertificates" runat="server">
                <HeaderTemplate>
                    <div class="cert-list">
                </HeaderTemplate>
                <ItemTemplate>
                    <div class="cert-item">
                        <div class="cert-icon"><i class="ti ti-award"></i></div>
                        <div class="cert-info">
                            <div class="cert-course"><%# Server.HtmlEncode(Eval("CourseTitle") as string) %></div>
                            <div class="cert-date">Issued <%# Eval("IssuedDate", "{0:dd MMM yyyy}") %></div>
                        </div>
                        <a class="cert-download" target="_blank"
                           href='<%# ResolveUrl("~/GetCertificate.ashx?id=" + Eval("CertificateID")) %>'>
                            <i class="ti ti-download"></i> Download
                        </a>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    </div>
                </FooterTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoCerts" runat="server" Visible="false">
                <div class="cert-empty">
                    <i class="ti ti-school"></i>
                    <span>You haven&#39;t earned any certificates yet. Complete a course and pass its quiz to earn one.</span>
                </div>
            </asp:Panel>
        </div>

        <!-- Change password card -->
        <asp:Panel ID="pnlPwCard" runat="server" CssClass="profile-card" DefaultButton="btnChangePw">
            <div class="card-section-title"><i class="ti ti-key"></i> Change Password</div>

            <asp:Panel ID="pnlPwAlert" runat="server" Visible="false">
                <asp:Label ID="lblPwAlert" runat="server" />
            </asp:Panel>

            <div class="form-group">
                <label class="form-label">Current Password</label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtCurrentPw" runat="server" CssClass="form-control"
                        TextMode="Password" MaxLength="100" />
                    <button type="button" class="pw-toggle" onclick="togglePw('<%= txtCurrentPw.ClientID %>', this)" tabindex="-1">
                        <i class="ti ti-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvCurrentPw" runat="server"
                    ControlToValidate="txtCurrentPw" ValidationGroup="vgPw"
                    CssClass="form-error" ErrorMessage="&gt; Current password required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label class="form-label">New Password</label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtNewPw" runat="server" CssClass="form-control"
                        TextMode="Password" MaxLength="100" />
                    <button type="button" class="pw-toggle" onclick="togglePw('<%= txtNewPw.ClientID %>', this)" tabindex="-1">
                        <i class="ti ti-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvNewPw" runat="server"
                    ControlToValidate="txtNewPw" ValidationGroup="vgPw"
                    CssClass="form-error" ErrorMessage="&gt; New password required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label class="form-label">Confirm New Password</label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtConfirmPw" runat="server" CssClass="form-control"
                        TextMode="Password" MaxLength="100" />
                    <button type="button" class="pw-toggle" onclick="togglePw('<%= txtConfirmPw.ClientID %>', this)" tabindex="-1">
                        <i class="ti ti-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvConfirmPw" runat="server"
                    ControlToValidate="txtConfirmPw" ValidationGroup="vgPw"
                    CssClass="form-error" ErrorMessage="&gt; Confirm password required." Display="Dynamic" />
                <asp:CompareValidator ID="cvPw" runat="server"
                    ControlToValidate="txtConfirmPw" ControlToCompare="txtNewPw"
                    ValidationGroup="vgPw" CssClass="form-error"
                    ErrorMessage="&gt; Passwords do not match." Display="Dynamic" />
            </div>

            <asp:Button ID="btnChangePw" runat="server" Text="Change Password"
                CssClass="btn-save" ValidationGroup="vgPw" OnClick="btnChangePw_Click" />
        </asp:Panel>

    </div>

    <script type="text/javascript">
        function togglePw(clientId, btn) {
            var box = document.getElementById(clientId);
            if (!box) return;
            var showing = box.type === 'text';
            box.type = showing ? 'password' : 'text';
            btn.querySelector('i').className = showing ? 'ti ti-eye' : 'ti ti-eye-off';
        }
    </script>
</asp:Content>
