<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ForgotPassword.aspx.cs" Inherits="CyberLearnHub.ForgotPassword" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Forgot Password &ndash; CyberLearnHub</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #0d1117;
            color: #e6edf3;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .card {
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 12px;
            padding: 40px 36px;
            width: 100%;
            max-width: 420px;
        }

        .logo {
            text-align: center;
            margin-bottom: 28px;
        }

        .logo-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 52px;
            height: 52px;
            background: linear-gradient(135deg, #00c6ff, #0072ff);
            border-radius: 12px;
            margin-bottom: 12px;
        }

        .logo-icon svg { width: 28px; height: 28px; fill: #fff; }

        h1 {
            font-size: 1.4rem;
            font-weight: 700;
            text-align: center;
            color: #e6edf3;
            margin-bottom: 6px;
        }

        .subtitle {
            font-size: 0.875rem;
            color: #8b949e;
            text-align: center;
            margin-bottom: 28px;
            line-height: 1.5;
        }

        label {
            display: block;
            font-size: 0.8rem;
            font-weight: 600;
            color: #c9d1d9;
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .input-wrap { position: relative; margin-bottom: 20px; }

        .input-wrap input {
            width: 100%;
            padding: 11px 14px;
            background: #0d1117;
            border: 1px solid #30363d;
            border-radius: 8px;
            color: #e6edf3;
            font-size: 0.95rem;
            transition: border-color 0.2s;
            outline: none;
        }

        .input-wrap input:focus { border-color: #0072ff; }

        .btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #00c6ff, #0072ff);
            border: none;
            border-radius: 8px;
            color: #fff;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.2s;
            margin-top: 4px;
        }

        .btn:hover { opacity: 0.9; }

        .message {
            margin-top: 18px;
            padding: 12px 14px;
            border-radius: 8px;
            font-size: 0.875rem;
            text-align: center;
            display: none;
        }

        .message.show { display: block; }
        .message.success { background: #0f2a1d; border: 1px solid #1a7f4b; color: #3fb950; }
        .message.error   { background: #2a0f0f; border: 1px solid #7f1a1a; color: #f85149; }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 22px;
            font-size: 0.875rem;
            color: #58a6ff;
            text-decoration: none;
        }

        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">
            <div class="logo">
                <div class="logo-icon">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 4a3 3 0 1 1 0 6 3 3 0 0 1 0-6zm0 8c2 0 6 1.34 6 2v1H6v-1c0-.66 4-2 6-2z"/>
                    </svg>
                </div>
                <h1>Forgot your password?</h1>
                <p class="subtitle">Enter your registered email and we'll send you a reset link.</p>
            </div>

            <label for="txtEmail">Email address</label>
            <div class="input-wrap">
                <asp:TextBox
                    ID="txtEmail"
                    runat="server"
                    TextMode="Email"
                    placeholder="you@example.com"
                    MaxLength="200" />
            </div>

            <asp:Button
                ID="btnSendReset"
                runat="server"
                Text="Send reset link"
                CssClass="btn"
                OnClick="btnSendReset_Click" />

            <asp:Label
                ID="lblMessage"
                runat="server"
                CssClass="message"
                EnableViewState="false" />

            <a href="Login.aspx" class="back-link">&larr; Back to login</a>
        </div>
    </form>

    <script>
        // Apply success/error class to the message label based on its content
        window.addEventListener('DOMContentLoaded', function () {
            var lbl = document.getElementById('<%= lblMessage.ClientID %>');
            if (lbl && lbl.innerText.trim() !== '') {
                lbl.classList.add('show');
                // The code-behind sets data-type="success" or data-type="error"
                lbl.classList.add(lbl.getAttribute('data-type') || 'success');
            }
        });
    </script>
</body>
</html>
