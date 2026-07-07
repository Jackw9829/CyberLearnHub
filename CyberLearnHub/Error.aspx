<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Error.aspx.cs"
         Inherits="CyberLearnHub.Error" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Page Not Found — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/error.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="error-wrapper">
        <div class="error-card">

            <div class="error-code" aria-hidden="true">404</div>

            <div class="error-icon" aria-hidden="true">
                <i class="ti ti-file-x"></i>
            </div>

            <div class="error-title">Page Not Found</div>

            <span class="error-tag">&gt; error_404 // resource_not_found<span class="blink">_</span></span>

            <p class="error-msg">
                The page you are looking for does not exist or has been moved.<br />
                Check the URL or navigate back to a known page.
            </p>

            <div class="btn-row">
                <a href="~/cyberlearnhub_homepage.aspx" runat="server" class="btn-home">
                    <i class="ti ti-home" style="margin-right:6px;"></i> Go Home
                </a>
                <a href="~/CourseListing.aspx" runat="server" class="btn-courses">
                    <i class="ti ti-books" style="margin-right:6px;"></i> Browse Courses
                </a>
            </div>

        </div>
    </div>

</asp:Content>
