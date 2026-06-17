<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs"
         Inherits="CyberLearnHub.Admin.Reports" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Reports &amp; Analytics</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .rpt-stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 16px; margin-bottom: 28px;
        }
        .rpt-stat {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px; padding: 18px 20px;
        }
        .rpt-stat-val {
            font-family: 'Rajdhani', sans-serif;
            font-size: 28px; font-weight: 700;
            color: var(--cyber-heading); line-height: 1;
        }
        .rpt-stat-lbl {
            font-family: 'Share Tech Mono', monospace;
            font-size: 9px; color: var(--cyber-muted);
            letter-spacing: 1.5px; text-transform: uppercase; margin-top: 4px;
        }
    </style>

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

</asp:Content>
