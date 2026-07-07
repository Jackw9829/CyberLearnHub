<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs"
         Inherits="CyberLearnHub.Admin.Reports" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Reports &amp; Analytics</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/admin-reports.css") %>" />

    <!-- Platform stats -->
    <div class="rpt-stat-grid">
        <div class="rpt-stat">
            <div class="rpt-stat-val"><asp:Label ID="lblTotalUsers" runat="server" Text="0" /></div>
            <div class="rpt-stat-lbl">Total Users</div>
        </div>
        <div class="rpt-stat">
            <div class="rpt-stat-val"><asp:Label ID="lblTotalCourses" runat="server" Text="0" /></div>
            <div class="rpt-stat-lbl">Courses</div>
        </div>
        <div class="rpt-stat">
            <div class="rpt-stat-val"><asp:Label ID="lblTotalEnrollments" runat="server" Text="0" /></div>
            <div class="rpt-stat-lbl">Enrollments</div>
        </div>
        <div class="rpt-stat">
            <div class="rpt-stat-val"><asp:Label ID="lblTotalAttempts" runat="server" Text="0" /></div>
            <div class="rpt-stat-lbl">Quiz Attempts</div>
        </div>
        <div class="rpt-stat">
            <div class="rpt-stat-val" style="color:var(--cyber-accent2);"><asp:Label ID="lblPassRate" runat="server" Text="N/A" /></div>
            <div class="rpt-stat-lbl">Pass Rate</div>
        </div>
    </div>

    <!-- Course performance -->
    <div class="admin-card">
        <div class="admin-card-title"><i class="ti ti-trophy"></i> Course Performance</div>
        <asp:Repeater ID="rptCourses" runat="server">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>Course</th>
                    <th>Enrolled</th>
                    <th>Quiz Attempts</th>
                    <th>Pass Rate</th>
                    <th>Avg Score</th>
                </tr></thead><tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="color:var(--cyber-heading);font-weight:500;"><%# Server.HtmlEncode(Eval("Title") as string) %></td>
                    <td style="color:var(--cyber-muted);"><%# Eval("EnrollCount") %></td>
                    <td style="color:var(--cyber-muted);"><%# Eval("AttemptCount") %></td>
                    <td>
                        <span class='<%# (int)Eval("PassCount") > 0 ? "badge badge-pub" : "badge badge-draft" %>'>
                            <%# Eval("PassRate") %>%
                        </span>
                    </td>
                    <td style="color:var(--cyber-accent2);font-family:'Share Tech Mono',monospace;font-size:12px;">
                        <%# string.Format("{0:0.0}", Eval("AvgScore")) %>%
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
    </div>

    <!-- Quiz performance across users -->
    <div class="admin-card">
        <div class="admin-card-title"><i class="ti ti-chart-bar"></i> Recent Quiz Activity</div>
        <asp:Repeater ID="rptActivity" runat="server">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>User</th>
                    <th>Course</th>
                    <th>Score</th>
                    <th>Result</th>
                    <th>Date</th>
                </tr></thead><tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="color:var(--cyber-heading);"><%# Server.HtmlEncode(Eval("FullName") as string) %></td>
                    <td style="color:var(--cyber-muted);font-size:12px;"><%# Server.HtmlEncode(Eval("CourseTitle") as string) %></td>
                    <td style="font-family:'Share Tech Mono',monospace;font-size:12px;"><%# Eval("Score") %>/<%# Eval("TotalQuestions") %> (<%# string.Format("{0:0}", Eval("Percentage")) %>%)</td>
                    <td>
                        <%# (bool)Eval("Passed")
                            ? "<span class=\"badge badge-pub\">PASSED</span>"
                            : "<span class=\"badge badge-draft\">FAILED</span>" %>
                    </td>
                    <td style="color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:11px;">
                        <%# Convert.ToDateTime(Eval("AttemptDate")).ToString("dd MMM yyyy HH:mm") %>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
    </div>

    <!-- User progress -->
    <div class="admin-card">
        <div class="admin-card-title"><i class="ti ti-users"></i> User Enrollment &amp; Progress</div>
        <asp:Repeater ID="rptUserProgress" runat="server">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>User</th>
                    <th>Email</th>
                    <th>Enrolled In</th>
                    <th>Quizzes Taken</th>
                    <th>Passed</th>
                    <th>Best Score</th>
                </tr></thead><tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="color:var(--cyber-heading);font-weight:500;"><%# Server.HtmlEncode(Eval("FullName") as string) %></td>
                    <td style="color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:11px;"><%# Server.HtmlEncode(Eval("Email") as string) %></td>
                    <td style="color:var(--cyber-muted);"><%# Eval("EnrolledCourses") %></td>
                    <td style="color:var(--cyber-muted);"><%# Eval("QuizzesTaken") %></td>
                    <td><span class="badge badge-pub"><%# Eval("QuizzesPassed") %></span></td>
                    <td style="color:var(--cyber-accent2);font-family:'Share Tech Mono',monospace;font-size:12px;">
                        <%# Eval("BestScore") != DBNull.Value ? string.Format("{0:0.0}", Eval("BestScore")) + "%" : "N/A" %>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
    </div>

        <!-- CSV Export buttons -->
        <div style="display:flex;gap:12px;margin-bottom:28px;flex-wrap:wrap;">
            <a href="../ExportResults.ashx" class="btn-admin-primary" style="text-decoration:none;display:inline-flex;align-items:center;gap:6px;">
                <i class="ti ti-download"></i> Export Results CSV
            </a>
            <a href="../ExportQuestionStats.ashx" class="btn-secondary" style="text-decoration:none;display:inline-flex;align-items:center;gap:6px;">
                <i class="ti ti-download"></i> Export Question Stats CSV
            </a>
        </div>

        <!-- Worst performing questions -->
        <div class="admin-section-title" style="font-family:'Rajdhani',sans-serif;font-size:18px;font-weight:700;color:var(--cyber-heading);margin-bottom:14px;">
            // Worst Performing Questions
            <span style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);font-weight:400;margin-left:10px;">(min. 5 attempts)</span>
        </div>
        <asp:Panel ID="pnlNoFailStats" runat="server" Visible="false">
            <p style="font-family:'Share Tech Mono',monospace;font-size:11px;color:var(--cyber-muted);">&gt; Not enough data yet (need 5+ attempts per question).</p>
        </asp:Panel>
        <asp:Panel ID="pnlFailStats" runat="server" Visible="false">
            <div style="overflow-x:auto;margin-bottom:32px;">
            <table class="admin-table">
                <thead><tr>
                    <th>Question</th><th>Quiz</th><th>Type</th><th>Difficulty</th><th>Fail Rate</th><th>Attempts</th>
                </tr></thead>
                <tbody>
                    <asp:Repeater ID="rptFailStats" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="max-width:300px;"><%# Server.HtmlEncode(((string)Eval("QuestionText")).Length > 60 ? ((string)Eval("QuestionText")).Substring(0,60) + "..." : (string)Eval("QuestionText")) %></td>
                                <td><%# Server.HtmlEncode(Eval("QuizTitle") as string) %></td>
                                <td><%# Eval("QuestionType") %></td>
                                <td><%# Eval("Difficulty") %></td>
                                <td style="color:var(--cyber-danger);font-weight:700;"><%# Eval("FailRate") %>%</td>
                                <td style="color:var(--cyber-muted);"><%# Eval("Attempts") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            </div>
        </asp:Panel>

        <!-- Score distribution -->
        <div class="admin-section-title" style="font-family:'Rajdhani',sans-serif;font-size:18px;font-weight:700;color:var(--cyber-heading);margin-bottom:14px;">
            // Score Distribution
        </div>
        <asp:Repeater ID="rptDistribution" runat="server">
            <ItemTemplate>
                <div style="margin-bottom:20px;">
                    <div style="font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;color:var(--cyber-heading);margin-bottom:8px;">
                        <%# Server.HtmlEncode(Eval("QuizTitle") as string) %>
                        <span style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);font-weight:400;margin-left:8px;"><%# Eval("TotalAttempts") %> attempts</span>
                    </div>
                    <%# Eval("BarsHtml") %>
                </div>
            </ItemTemplate>
        </asp:Repeater>

</asp:Content>
