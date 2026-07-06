<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Contact.aspx.cs"
         Inherits="CyberLearnHub.Contact" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Contact &ndash; CyberLearn Hub</title>
    <style>
        .contact-wrapper {
            max-width: 860px;
            margin: 0 auto;
            padding: 52px 40px 60px;
        }

        .page-header { margin-bottom: 48px; }
        .page-header .badge { margin-bottom: 16px; }

        .contact-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 32px;
            align-items: start;
        }

        @media (max-width: 680px) {
            .contact-grid { grid-template-columns: 1fr; }
            .contact-wrapper { padding: 32px 20px 48px; }
        }

        /* ── Form card ── */
        .form-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px;
            padding: 32px 28px;
        }

        .form-card h2 {
            font-family: 'Rajdhani', sans-serif;
            font-size: 18px;
            font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 0.5px;
            margin: 0 0 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-card h2 i { color: var(--cyber-accent); font-size: 20px; }

        .form-group { margin-bottom: 18px; }

        .form-group label {
            display: block;
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            color: var(--cyber-accent);
            margin-bottom: 7px;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            background: var(--cyber-surface);
            border: 1px solid var(--cyber-border);
            border-radius: 6px;
            color: var(--cyber-text);
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            padding: 10px 14px;
            transition: border-color 0.2s;
            outline: none;
            box-sizing: border-box;
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus { border-color: var(--cyber-accent); }

        .form-group textarea { resize: vertical; min-height: 130px; }

        .form-group select option { background: var(--cyber-card); }

        .btn-send {
            width: 100%;
            padding: 11px 20px;
            background: var(--cyber-accent);
            border: none;
            border-radius: 6px;
            color: #0d1117;
            font-family: 'Rajdhani', sans-serif;
            font-size: 15px;
            font-weight: 700;
            letter-spacing: 1px;
            cursor: pointer;
            transition: opacity 0.2s;
            margin-top: 4px;
        }

        .btn-send:hover { opacity: 0.85; }

        /* ── Alert ── */
        .alert {
            border-radius: 7px;
            padding: 13px 16px;
            font-size: 13px;
            line-height: 1.55;
            margin-bottom: 20px;
            display: none;
        }

        .alert.show { display: block; }
        .alert-success { background: rgba(0,240,180,0.08); border: 1px solid var(--cyber-accent); color: var(--cyber-accent); }
        .alert-error   { background: rgba(255,60,60,0.08); border: 1px solid #ff3c3c; color: #ff3c3c; }

        /* ── Info panel ── */
        .info-panel { display: flex; flex-direction: column; gap: 20px; }

        .info-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px;
            padding: 24px;
        }

        .info-card h3 {
            font-family: 'Rajdhani', sans-serif;
            font-size: 16px;
            font-weight: 700;
            color: var(--cyber-heading);
            margin: 0 0 14px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .info-card h3 i { color: var(--cyber-accent2); font-size: 18px; }

        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 12px;
            font-size: 13px;
            color: var(--cyber-muted);
            line-height: 1.55;
        }

        .info-item:last-child { margin-bottom: 0; }

        .info-item i {
            color: var(--cyber-accent);
            font-size: 16px;
            flex-shrink: 0;
            margin-top: 1px;
        }

        .info-item strong { color: var(--cyber-text); display: block; margin-bottom: 2px; }

        .faq-item { margin-bottom: 16px; }
        .faq-item:last-child { margin-bottom: 0; }

        .faq-q {
            font-size: 13px;
            font-weight: 600;
            color: var(--cyber-text);
            margin-bottom: 5px;
        }

        .faq-a {
            font-size: 13px;
            color: var(--cyber-muted);
            line-height: 1.55;
            margin: 0;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="contact-wrapper">

    <!-- Header -->
    <div class="page-header">
        <div class="badge">
            <i class="ti ti-message-circle"></i> Get in Touch
        </div>
        <h1 class="page-title">Contact Us</h1>
        <p class="page-subtitle">
            Have a question, found a bug, or want to suggest a new course?
            We&rsquo;d love to hear from you.
        </p>
    </div>

    <div class="contact-grid">

        <!-- ── Left: contact form ── -->
        <div class="form-card">
            <h2><i class="ti ti-send"></i> Send a Message</h2>

            <asp:Label ID="lblAlert" runat="server" CssClass="alert" EnableViewState="false" />

            <div class="form-group">
                <label for="txtName">Your Name</label>
                <asp:TextBox ID="txtName" runat="server" placeholder="John Doe" MaxLength="100" />
            </div>

            <div class="form-group">
                <label for="txtEmail">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                             placeholder="you@example.com" MaxLength="200" />
            </div>

            <div class="form-group">
                <label for="ddlSubject">Subject</label>
                <asp:DropDownList ID="ddlSubject" runat="server">
                    <asp:ListItem Text="-- Select a subject --" Value="" />
                    <asp:ListItem Text="General Enquiry" Value="General Enquiry" />
                    <asp:ListItem Text="Course / Lab Content" Value="Course / Lab Content" />
                    <asp:ListItem Text="Technical Issue / Bug Report" Value="Technical Issue / Bug Report" />
                    <asp:ListItem Text="Account Help" Value="Account Help" />
                    <asp:ListItem Text="Feature Suggestion" Value="Feature Suggestion" />
                    <asp:ListItem Text="Other" Value="Other" />
                </asp:DropDownList>
            </div>

            <div class="form-group">
                <label for="txtMessage">Message</label>
                <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine"
                             placeholder="Describe your question or issue in detail..."
                             MaxLength="2000" />
            </div>

            <asp:Button ID="btnSend" runat="server" Text="Send Message"
                        CssClass="btn-send" OnClick="btnSend_Click" />
        </div>

        <!-- ── Right: info + FAQ ── -->
        <div class="info-panel">

            <div class="info-card">
                <h3><i class="ti ti-info-circle"></i> Contact Information</h3>

                <div class="info-item">
                    <i class="ti ti-mail"></i>
                    <div>
                        <strong>Email</strong>
                        support@cyberlearnhub.dpdns.org
                    </div>
                </div>

                <div class="info-item">
                    <i class="ti ti-clock"></i>
                    <div>
                        <strong>Response Time</strong>
                        We aim to reply within 1&ndash;2 business days.
                    </div>
                </div>

                <div class="info-item">
                    <i class="ti ti-shield-check"></i>
                    <div>
                        <strong>Security Reports</strong>
                        Found a vulnerability? Please report it responsibly
                        via email with subject &ldquo;Security Disclosure&rdquo;.
                    </div>
                </div>
            </div>

            <div class="info-card">
                <h3><i class="ti ti-help-circle"></i> Common Questions</h3>

                <div class="faq-item">
                    <p class="faq-q">I forgot my password. What do I do?</p>
                    <p class="faq-a">Use the <a href="~/ForgotPassword.aspx" runat="server"
                        style="color:var(--cyber-accent);">Forgot Password</a> link on the
                        login page to receive a reset link by email.</p>
                </div>

                <div class="faq-item">
                    <p class="faq-q">How do I earn a certificate?</p>
                    <p class="faq-a">Enrol in a course, pass the final quiz with a score of
                        70&nbsp;% or above, and your certificate will appear on your
                        <a href="~/MyProgress.aspx" runat="server"
                           style="color:var(--cyber-accent);">My Progress</a> page.</p>
                </div>

                <div class="faq-item">
                    <p class="faq-q">The virtual lab won&rsquo;t load. Help!</p>
                    <p class="faq-a">Make sure you&rsquo;re using a modern browser (Chrome or
                        Firefox). If the problem persists, contact us using the form on the
                        left and include the lab name.</p>
                </div>

                <div class="faq-item">
                    <p class="faq-q">Can I suggest a new course topic?</p>
                    <p class="faq-a">Absolutely &mdash; choose &ldquo;Feature Suggestion&rdquo;
                        from the subject dropdown and tell us what you&rsquo;d like to learn.</p>
                </div>
            </div>

        </div>
    </div>

</div>

<script>
    (function () {
        var lbl = document.getElementById('<%= lblAlert.ClientID %>');
        if (lbl && lbl.innerText.trim() !== '') {
            lbl.classList.add('show');
        }
    })();
</script>
</asp:Content>
