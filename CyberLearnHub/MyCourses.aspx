<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs"
         Inherits="CyberLearnHub.MyCourses" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>My Courses — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/my-courses.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mc-wrap">

        <div class="page-header">
            <div class="page-tag">// student</div>
            <div class="page-title">My Courses</div>
        </div>

        <div class="mc-count">
            Enrolled in <span><asp:Label ID="lblCount" runat="server" Text="0" /></span> course(s)
        </div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="mc-grid">
                <div class="mc-empty">
                    <i class="ti ti-book-off"></i>
                    &gt; You haven't enrolled in any courses yet.<br />
                    <a href="CourseListing.aspx" style="color:var(--cyber-accent);text-decoration:none;margin-top:12px;display:inline-block;">
                        Browse courses &rarr;
                    </a>
                </div>
            </div>
        </asp:Panel>

        <div class="mc-grid">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <div class="mc-card">
                        <div class="mc-card-thumb">
                            <%# GetThumbHtml(Eval("ImageUrl") as string) %>
                        </div>
                        <div class="mc-card-body">
                            <div class="mc-card-title"><%# Server.HtmlEncode(Eval("Title") as string) %></div>
                            <div class="mc-card-meta">
                                <%# GetDiffBadge(Eval("Difficulty") as string) %>
                                <%# GetCatBadge(Eval("Category") as string) %>
                                <%# GetQuizBadge(Eval("QuizStatus") as string) %>
                            </div>
                            <%# GetBestScore(Eval("BestScore"), Eval("QuizStatus") as string) %>
                            <div class="mc-card-actions">
                                <a href="CourseDetail.aspx?id=<%# Eval("CourseID") %>" class="btn-sm btn-sm-outline">
                                    <i class="ti ti-book"></i> Content
                                </a>
                                <a href="Quiz.aspx?courseId=<%# Eval("CourseID") %>" class="btn-sm btn-sm-accent">
                                    <i class="ti ti-help-circle"></i> <%# (string)Eval("QuizStatus") == "None" ? "Take Quiz" : "Retake" %>
                                </a>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

    </div>
</asp:Content>
