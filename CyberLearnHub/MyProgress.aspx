<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProgress.aspx.cs"
         Inherits="CyberLearnHub.MyProgress" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>My Progress — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/my-progress.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="progress-wrap">

    <div class="page-header">
        <div class="page-tag">// STUDENT PROGRESS</div>
        <div class="page-title">My Progress</div>
    </div>

    <!-- Summary stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue"><i class="ti ti-book-2"></i></div>
            <div><div class="stat-value"><asp:Label ID="lblEnrolled" runat="server" Text="0"/></div><div class="stat-label">Enrolled</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="ti ti-clipboard-list"></i></div>
            <div><div class="stat-value"><asp:Label ID="lblAttempts" runat="server" Text="0"/></div><div class="stat-label">Attempts</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green"><i class="ti ti-circle-check"></i></div>
            <div><div class="stat-value"><asp:Label ID="lblPassed" runat="server" Text="0"/></div><div class="stat-label">Passed</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon blue"><i class="ti ti-trophy"></i></div>
            <div><div class="stat-value"><asp:Label ID="lblBest" runat="server" Text="N/A"/></div><div class="stat-label">Best Score</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon purple"><i class="ti ti-bolt"></i></div>
            <div><div class="stat-value"><asp:Label ID="lblXP" runat="server" Text="0 XP"/></div><div class="stat-label">Total XP</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon amber"><i class="ti ti-flame"></i></div>
            <div><div class="stat-value"><asp:Label ID="lblStreak" runat="server" Text="0"/></div><div class="stat-label">Day Streak</div></div>
        </div>
    </div>

    <!-- XP level bar -->
    <div class="xp-bar-wrap">
        <div class="xp-bar-header">
            <span class="xp-bar-level"><asp:Label ID="lblLevelFull" runat="server" Text="Level 1"/></span>
            <span class="xp-bar-next"><asp:Label ID="lblXPNext" runat="server" Text="0 / 500 XP to next level"/></span>
        </div>
        <div class="xp-bar-track">
            <div class="xp-bar-fill" style="width:<%: ViewState["XPBarPct"] ?? 0 %>%"></div>
        </div>
        <div class="xp-bar-sub"><asp:Label ID="lblLongestStreak" runat="server" Text="Longest streak: 0 days"/></div>
    </div>

    <!-- Course progress -->
    <div class="section-title">// Course Progress</div>
    <asp:Panel ID="pnlNoCourses" runat="server" Visible="false">
        <p class="empty-state">&gt; You have not enrolled in any courses yet. <a href="~/CourseListing.aspx" runat="server" style="color:var(--cyber-accent);">Browse courses</a></p>
    </asp:Panel>
    <asp:Panel ID="pnlCourses" runat="server" Visible="false">
        <div style="overflow-x:auto;margin-bottom:40px;">
        <table class="prog-table">
            <thead><tr>
                <th>Course</th><th>Quiz Status</th><th>Best Score</th><th>Attempts</th><th>Certificate</th>
            </tr></thead>
            <tbody>
                <asp:Repeater ID="rptCourses" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><a href='<%# "~/CourseDetail.aspx?id=" + Eval("CourseID") %>' runat="server" style="color:var(--cyber-accent);text-decoration:none;"><%# Server.HtmlEncode(Eval("Title") as string) %></a></td>
                            <td><%# GetStatusBadge(Eval("QuizStatus") as string) %></td>
                            <td><span class='<%# Convert.ToInt32(Eval("BestPct")) >= 70 ? "score-hi" : "score-lo" %>'><%# Convert.ToInt32(Eval("BestPct")) > 0 ? Eval("BestPct") + "%" : "-" %></span></td>
                            <td style="color:var(--cyber-muted);"><%# Eval("Attempts") %></td>
                            <td><%# GetCertLink(Convert.ToInt32(Eval("CourseID")), Convert.ToInt32(Eval("CertID"))) %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
        </div>
    </asp:Panel>

    <!-- Quiz history -->
    <div class="section-title">// Recent Quiz Attempts</div>
    <asp:Panel ID="pnlNoHistory" runat="server" Visible="false">
        <p class="empty-state">&gt; No quiz attempts yet.</p>
    </asp:Panel>
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <div style="overflow-x:auto;">
        <table class="history-table">
            <thead><tr>
                <th>Course</th><th>Date</th><th>Score</th><th>Result</th><th></th>
            </tr></thead>
            <tbody>
                <asp:Repeater ID="rptHistory" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><%# Server.HtmlEncode(Eval("CourseTitle") as string) %></td>
                            <td style="color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:11px;"><%# Convert.ToDateTime(Eval("AttemptDate")).ToString("MMM dd, yyyy HH:mm") %></td>
                            <td><span class='<%# Convert.ToBoolean(Eval("Passed")) ? "score-hi" : "score-lo" %>'><%# Eval("Percentage") %>%</span><span style="color:var(--cyber-muted);font-size:11px;margin-left:6px;">(<%# Eval("Score") %>/<%# Eval("TotalQuestions") %>)</span></td>
                            <td><%# Convert.ToBoolean(Eval("Passed")) ? "<span class=\"badge-passed\">PASSED</span>" : "<span class=\"badge-failed\">FAILED</span>" %></td>
                            <td><a href='<%# "~/QuizResult.aspx?attemptId=" + Eval("ResultID") %>' runat="server" style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-accent);text-decoration:none;">Review &rsaquo;</a></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
        </div>
    </asp:Panel>

</div>
</asp:Content>
