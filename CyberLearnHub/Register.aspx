<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs"
         Inherits="CyberLearnHub.Register" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Register — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/register.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="auth-wrapper">
        <div class="auth-card">

            <div class="auth-header">
                <div class="auth-icon" aria-hidden="true">
                    <i class="ti ti-user-plus"></i>
                </div>
                <div class="auth-title">Create Account</div>
                <div class="auth-subtitle">&gt; join the platform</div>
            </div>

            <%-- Success alert --%>
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
                <div class="alert alert-success">
                    <asp:Label ID="lblSuccess" runat="server" />
                </div>
            </asp:Panel>

            <%-- Error alert --%>
            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div class="alert alert-danger">
                    <asp:Label ID="lblError" runat="server" />
                </div>
            </asp:Panel>

            <%-- Username --%>
            <div class="form-group">
                <label class="form-label" for="txtUsername">Username</label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"
                    placeholder="e.g. cyber_hawk" MaxLength="50" />
                <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                    ControlToValidate="txtUsername"
                    CssClass="form-error"
                    ErrorMessage="&gt; Username is required."
                    Display="Dynamic" />
                <span class="form-hint">3 - 50 characters</span>
            </div>

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
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtEmail"
                    CssClass="form-error"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="&gt; Enter a valid email address."
                    Display="Dynamic" />
            </div>

            <%-- Password --%>
            <div class="form-group">
                <label class="form-label" for="txtPassword">Password</label>
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
                <asp:RegularExpressionValidator ID="revPassword" runat="server"
                    ControlToValidate="txtPassword"
                    CssClass="form-error"
                    ValidationExpression=".{8,}"
                    ErrorMessage="&gt; Password must be at least 8 characters."
                    Display="Dynamic" />
                <span class="form-hint">Minimum 8 characters</span>
            </div>

            <%-- Confirm Password --%>
            <div class="form-group">
                <label class="form-label" for="txtConfirmPassword">Confirm Password</label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control"
                        placeholder="********" TextMode="Password" MaxLength="100" />
                    <button type="button" class="pw-toggle" onclick="togglePw('<%= txtConfirmPassword.ClientID %>', this)" tabindex="-1" aria-label="Show password">
                        <i class="ti ti-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvConfirm" runat="server"
                    ControlToValidate="txtConfirmPassword"
                    CssClass="form-error"
                    ErrorMessage="&gt; Please confirm your password."
                    Display="Dynamic" />
                <asp:CompareValidator ID="cvPasswords" runat="server"
                    ControlToValidate="txtConfirmPassword"
                    ControlToCompare="txtPassword"
                    CssClass="form-error"
                    ErrorMessage="&gt; Passwords do not match."
                    Display="Dynamic" />
            </div>

            <%-- Submit --%>
            <asp:Button ID="btnRegister" runat="server" Text="Create Account"
                CssClass="btn-submit" OnClick="btnRegister_Click" />

            <hr class="divider" />

            <div class="auth-footer">
                Already have an account?
                <a href="Login.aspx">Log in here</a>
            </div>

        </div>
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
