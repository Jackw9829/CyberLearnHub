<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ResetPassword.aspx.cs" Inherits="CyberLearnHub.ResetPassword" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Reset Password &ndash; CyberLearnHub</title>
    <link rel="stylesheet" href="Styles/reset-password.css" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfToken" runat="server" />

        <div class="card">
            <div class="logo">
                <div class="logo-icon">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 4a3 3 0 1 1 0 6 3 3 0 0 1 0-6zm0 8c2 0 6 1.34 6 2v1H6v-1c0-.66 4-2 6-2z"/>
                    </svg>
                </div>
                <h1>Set a new password</h1>
                <p class="subtitle">Choose something strong &mdash; at least 8 characters.</p>
            </div>

            <%-- Token-invalid / expired state is handled server-side; panel shown only when token is valid --%>
            <asp:Panel ID="pnlForm" runat="server">

                <label for="txtNewPassword">New password</label>
                <div class="input-wrap">
                    <asp:TextBox
                        ID="txtNewPassword"
                        runat="server"
                        TextMode="Password"
                        placeholder="Min. 8 characters"
                        MaxLength="100"
                        onkeyup="checkStrength(this.value)" />
                    <button type="button" class="toggle-pw" onclick="togglePw('txtNewPassword', this)" aria-label="Show password">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zm0 12.5a5 5 0 1 1 0-10 5 5 0 0 1 0 10zm0-8a3 3 0 1 0 0 6 3 3 0 0 0 0-6z"/></svg>
                    </button>
                </div>
                <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                <p class="strength-label" id="strengthLabel"></p>

                <label for="txtConfirmPassword">Confirm password</label>
                <div class="input-wrap">
                    <asp:TextBox
                        ID="txtConfirmPassword"
                        runat="server"
                        TextMode="Password"
                        placeholder="Repeat new password"
                        MaxLength="100" />
                    <button type="button" class="toggle-pw" onclick="togglePw('txtConfirmPassword', this)" aria-label="Show password">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zm0 12.5a5 5 0 1 1 0-10 5 5 0 0 1 0 10zm0-8a3 3 0 1 0 0 6 3 3 0 0 0 0-6z"/></svg>
                    </button>
                </div>

                <asp:Button
                    ID="btnReset"
                    runat="server"
                    Text="Reset password"
                    CssClass="btn"
                    OnClick="btnReset_Click" />

            </asp:Panel>

            <asp:Label
                ID="lblMessage"
                runat="server"
                CssClass="message"
                EnableViewState="false" />

            <a href="Login.aspx" class="back-link">&larr; Back to login</a>
        </div>
    </form>

    <script>
        // Reveal / hide password toggle
        function togglePw(fieldId, btn) {
            var field = document.getElementById('<%= txtNewPassword.ClientID %>');
            if (fieldId === 'txtConfirmPassword')
                field = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            field.type = field.type === 'password' ? 'text' : 'password';
        }

        // Simple password-strength indicator
        function checkStrength(val) {
            var fill  = document.getElementById('strengthFill');
            var label = document.getElementById('strengthLabel');
            if (!fill) return;
            var score = 0;
            if (val.length >= 8)  score++;
            if (val.length >= 12) score++;
            if (/[A-Z]/.test(val)) score++;
            if (/[0-9]/.test(val)) score++;
            if (/[^A-Za-z0-9]/.test(val)) score++;

            var levels = [
                { pct: '0%',   color: '#30363d', text: '' },
                { pct: '25%',  color: '#f85149', text: 'Weak' },
                { pct: '50%',  color: '#d29922', text: 'Fair' },
                { pct: '75%',  color: '#58a6ff', text: 'Good' },
                { pct: '100%', color: '#3fb950', text: 'Strong' }
            ];
            var lvl = val.length === 0 ? levels[0] : levels[Math.min(score, 4)];
            fill.style.width = lvl.pct;
            fill.style.background = lvl.color;
            label.textContent = lvl.text;
            label.style.color = lvl.color;
        }

        // Apply CSS classes to message label on postback
        window.addEventListener('DOMContentLoaded', function () {
            var lbl = document.getElementById('<%= lblMessage.ClientID %>');
            if (lbl && lbl.innerText.trim() !== '') {
                lbl.classList.add('show');
                lbl.classList.add(lbl.getAttribute('data-type') || 'error');
            }
        });
    </script>
</body>
</html>
