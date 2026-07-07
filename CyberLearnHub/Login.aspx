<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs"
         Inherits="CyberLearnHub.Login" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Login — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/login.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- DefaultButton ensures Enter key submits the login button, not the navbar button --%>
    <asp:Panel ID="pnlLoginOuter" runat="server" DefaultButton="btnLogin">
    <div class="auth-wrapper">
        <div class="auth-card">

            <div class="auth-header">
                <div class="auth-icon" aria-hidden="true">
                    <i class="ti ti-lock"></i>
                </div>
                <div class="auth-title">Welcome Back</div>
                <div class="auth-subtitle">&gt; authenticate to continue</div>
            </div>

            <%-- Global alert (shown on invalid credentials) --%>
            <asp:Panel ID="pnlAlert" runat="server" Visible="false">
                <div class="alert alert-danger">
                    <asp:Label ID="lblAlert" runat="server" />
                </div>
            </asp:Panel>

            <%-- Email --%>
            <div class="form-group">
                <label class="form-label" for="txtEmail">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                    placeholder="you@example.com" TextMode="Email" MaxLength="150" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                    ControlToValidate="txtEmail"
                    CssClass="form-error"
                    ErrorMessage="&gt; Email is required."
                    Display="Dynamic" />
            </div>

            <%-- Password --%>
            <div class="form-group">
                <label class="form-label" for="txtPassword">
                    Password
                    <a href="ForgotPassword.aspx" class="forgot-link">Forgot password?</a>
                </label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control"
                        placeholder="********" TextMode="Password" MaxLength="100" />
                    <button type="button" class="pw-toggle" onclick="togglePw('<%= txtPassword.ClientID %>', this)" tabindex="-1" aria-label="Show password">
                        <i class="ti ti-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword"
                    CssClass="form-error"
                    ErrorMessage="&gt; Password is required."
                    Display="Dynamic" />
            </div>

            <%-- Submit --%>
            <asp:Button ID="btnLogin" runat="server" Text="Log In"
                CssClass="btn-submit" OnClick="btnLogin_Click" />

            <hr class="divider" />

            <div class="auth-footer">
                Don't have an account?
                <a href="Register.aspx">Register here</a>
            </div>

        </div>
    </div>
    </asp:Panel>

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
