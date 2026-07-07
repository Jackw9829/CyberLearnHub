<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Contact.aspx.cs"
         Inherits="CyberLearnHub.Contact" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Contact &ndash; CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/contact.css") %>" />
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
