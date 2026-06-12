<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs"
         Inherits="CyberLearnHub.Login" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Login — CyberLearn Hub</title>
    <style>
        .auth-wrapper {
            min-height: calc(100vh - 120px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }

        .auth-card {
            width: 100%;
            max-width: 440px;
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px;
            padding: 40px;
            position: relative;
            overflow: hidden;
        }

        /* Cyan top accent bar */
        .auth-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: linear-gradient(90deg, var(--cyber-accent), var(--cyber-accent2));
        }

        .auth-header {
            text-align: center;
            margin-bottom: 32px;
        }

        .auth-icon {
            width: 52px;
            height: 52px;
            background: rgba(0,212,255,0.08);
            border: 1px solid rgba(0,212,255,0.3);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            font-size: 24px;
            color: var(--cyber-accent);
        }

        .auth-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 26px;
            font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 0.5px;
            margin-bottom: 6px;
        }

        .auth-subtitle {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-muted);
            letter-spacing: 1.5px;
        }

        .form-group { margin-bottom: 20px; }

        .forgot-link {
            float: right;
            font-size: 11px;
            color: var(--cyber-muted);
            text-decoration: none;
            transition: color 0.2s;
            margin-top: 2px;
        }

        .forgot-link:hover { color: var(--cyber-accent); }

        .btn-submit,
        input[type="submit"].btn-submit {
            width: 100%;
            padding: 12px;
            background: var(--cyber-accent);
            border: none;
            color: #080d14;
            font-family: 'Rajdhani', sans-serif;
            font-size: 15px;
            font-weight: 700;
            letter-spacing: 1.5px;
            border-radius: 5px;
            cursor: pointer;
            text-transform: uppercase;
            transition: background 0.2s;
            margin-top: 8px;
        }

        .btn-submit:hover { background: #33ddff; }

        .pw-wrap {
            position: relative;
        }

        .pw-wrap .form-control {
            padding-right: 42px;
        }

        .pw-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: var(--cyber-muted);
            font-size: 16px;
            line-height: 1;
            padding: 0;
            transition: color 0.2s;
        }

        .pw-toggle:hover { color: var(--cyber-accent); }

        .auth-footer {
            text-align: center;
            margin-top: 24px;
            font-size: 13px;
            color: var(--cyber-muted);
        }

        .auth-footer a {
            color: var(--cyber-accent);
            text-decoration: none;
            font-weight: 500;
        }

        .auth-footer a:hover { color: #33ddff; }

        .divider {
            border: none;
            border-top: 1px solid var(--cyber-border);
            margin: 24px 0;
        }
    </style>
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
