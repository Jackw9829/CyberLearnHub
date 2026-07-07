<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
         Inherits="CyberLearnHub.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Dashboard — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/dashboard.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dash-wrap">

        <!-- Greeting -->
        <div class="dash-greeting">
            <div class="dash-greeting-tag">// student dashboard</div>
            <div class="dash-greeting-name">
                Welcome back, <span><asp:Label ID="lblUsername" runat="server" /></span>
            </div>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="ti ti-book"></i></div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblStatEnrolled" runat="server" Text="0" /></div>
                    <div class="stat-label">Enrolled</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber"><i class="ti ti-help-circle"></i></div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblStatAttempts" runat="server" Text="0" /></div>
                    <div class="stat-label">Quizzes Taken</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="ti ti-circle-check"></i></div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblStatPassed" runat="server" Text="0" /></div>
                    <div class="stat-label">Passed</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue"><i class="ti ti-trophy"></i></div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblStatBest" runat="server" Text="—" /></div>
                    <div class="stat-label">Best Score</div>
                </div>
            </div>
        </div>

        <div class="stats-grid" style="margin-bottom:28px;">
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(250,199,117,0.1);color:var(--cyber-amber);">
                    <i class="ti ti-star"></i>
                </div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblXP" runat="server" Text="0 XP" /></div>
                    <div class="stat-label">Total XP</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(0,212,255,0.1);color:var(--cyber-accent);">
                    <i class="ti ti-shield-star"></i>
                </div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblLevel" runat="server" Text="LVL 1" /></div>
                    <div class="stat-label">Level</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(255,59,92,0.1);color:var(--cyber-danger);">
                    <i class="ti ti-flame"></i>
                </div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblStreak" runat="server" Text="No streak" /></div>
                    <div class="stat-label">Pass Streak</div>
                </div>
            </div>
        </div>

        <!-- My Courses -->
        <div class="section-header">
            <div class="section-title">// My Courses</div>
            <a href="CourseListing.aspx" class="section-link">Browse all &rarr;</a>
        </div>

        <asp:Panel ID="pnlNoCourses" runat="server" Visible="false">
            <div class="dash-empty">
                <i class="ti ti-book-off"></i>
                &gt; You haven't enrolled in any courses yet.<br />
                <a href="CourseListing.aspx" style="color:var(--cyber-accent);text-decoration:none;margin-top:10px;display:inline-block;">Browse courses &rarr;</a>
            </div>
        </asp:Panel>

        <div class="my-courses-grid">
            <asp:Repeater ID="rptMyCourses" runat="server">
                <ItemTemplate>
                    <div class="my-course-card">
                        <div class="my-course-title"><%# Server.HtmlEncode(Eval("Title") as string) %></div>
                        <div><%# GetQuizStatusBadge(Eval("QuizStatus") as string) %></div>
                        <div class="my-course-actions">
                            <a href="CourseDetail.aspx?id=<%# Eval("CourseID") %>" class="btn-sm btn-sm-outline">Details</a>
                            <a href="Quiz.aspx?courseId=<%# Eval("CourseID") %>" class="btn-sm btn-sm-accent">
                                <i class="ti ti-help-circle"></i> Quiz
                            </a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- Recent Activity -->
        <div class="section-header">
            <div class="section-title">// Recent Activity</div>
        </div>

        <asp:Panel ID="pnlNoActivity" runat="server" Visible="false">
            <div class="dash-empty">
                <i class="ti ti-history-off"></i>
                &gt; No quiz attempts yet.
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlActivity" runat="server" Visible="false">
            <table class="activity-table">
                <thead>
                    <tr>
                        <th>Course</th>
                        <th>Score</th>
                        <th>Result</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptActivity" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# Server.HtmlEncode(Eval("Title") as string) %></td>
                                <td><%# Eval("Score") %> / <%# Eval("TotalQuestions") %></td>
                                <td>
                                    <%# (bool)Eval("Passed")
                                        ? "<span class=\"quiz-status-badge qs-passed\">PASSED</span>"
                                        : "<span class=\"quiz-status-badge qs-failed\">FAILED</span>" %>
                                </td>
                                <td style="color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:11px;">
                                    <%# Convert.ToDateTime(Eval("AttemptDate")).ToString("dd MMM yyyy HH:mm") %>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </asp:Panel>

        <!-- Quick links -->
        <div style="display:flex;gap:12px;flex-wrap:wrap;">
            <a href="CourseListing.aspx" class="btn-sm btn-sm-accent" style="font-size:13px;padding:10px 20px;">
                <i class="ti ti-book"></i> Browse Courses
            </a>
            <a href="Profile.aspx" class="btn-sm btn-sm-outline" style="font-size:13px;padding:10px 20px;">
                <i class="ti ti-user"></i> Edit Profile
            </a>
        </div>

    </div>
</asp:Content>
