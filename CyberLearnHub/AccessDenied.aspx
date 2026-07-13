<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs"
         Inherits="CyberLearnHub.AccessDenied" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Access Denied — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/access-denied.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="error-wrapper">
        <div class="error-card">

            <asp:Panel ID="pnlDesktopRequired" runat="server" Visible="false">
                <div class="error-code error-code-text" aria-hidden="true">// MOBILE</div>
                <div class="error-icon" aria-hidden="true">
                    <i class="ti ti-device-desktop"></i>
                </div>
                <div class="error-title">Desktop Required</div>
                <span class="error-tag">&gt; mobile_blocked // desktop_only_section</span>
                <p class="error-msg">
                    <asp:Label ID="lblDesktopMsg" runat="server" />
                </p>
            </asp:Panel>

            <asp:Panel ID="pnlAccessDenied" runat="server" Visible="false">
                <div class="error-code" aria-hidden="true">403</div>
                <div class="error-icon" aria-hidden="true">
                    <i class="ti ti-lock-x"></i>
                </div>
                <div class="error-title">Access Denied</div>
                <span class="error-tag">&gt; authorisation_failed // insufficient_privileges</span>
                <p class="error-msg">
                    You do not have permission to view this page.<br />
                    Please log in with an account that has the required access level,
                    or return to the homepage.
                </p>
            </asp:Panel>

            <div class="btn-row">
                <a href="~/cyberlearnhub_homepage.aspx" runat="server" class="btn-home">
                    <i class="ti ti-home" style="margin-right:6px;"></i> Go Home
                </a>
                <asp:Panel ID="pnlLoginLink" runat="server" Visible="false" style="display:inline;">
                    <a href="~/Login.aspx" runat="server" class="btn-login-link">
                        <i class="ti ti-lock" style="margin-right:6px;"></i> Log In
                    </a>
                </asp:Panel>
            </div>

        </div>
    </div>

</asp:Content>
