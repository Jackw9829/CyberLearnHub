<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ForgotPassword.aspx.cs" Inherits="CyberLearnHub.ForgotPassword" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Forgot Password &ndash; CyberLearnHub</title>
    <link rel="stylesheet" href="Styles/forgot-password.css" />
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
