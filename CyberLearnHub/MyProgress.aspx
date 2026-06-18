<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProgress.aspx.cs"
         Inherits="CyberLearnHub.MyProgress" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>My Progress — CyberLearn Hub</title>
    <style>
        .progress-wrap { max-width: 1100px; margin: 0 auto; padding: 40px 24px 60px; }

        .page-header { margin-bottom: 36px; }
        .page-tag {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-accent);
            letter-spacing: 3px;
            margin-bottom: 6px;
        }
        .page-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 32px;
            font-weight: 700;
            color: var(--cyber-heading);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 16px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .stat-icon {
            width: 42px; height: 42px;
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 19px; flex-shrink: 0;
        }
        .stat-icon.blue   { background: rgba(0,212,255,0.1);   color: var(--cyber-accent); }
        .stat-icon.green  { background: rgba(0,255,157,0.1);   color: var(--cyber-accent2); }
        .stat-icon.amber  { background: rgba(250,199,117,0.1); color: var(--cyber-amber); }
        .stat-icon.purple { background: rgba(139,92,246,0.12); color: #a78bfa; }
        .stat-icon.danger { background: rgba(255,59,92,0.1);   color: var(--cyber-danger); }
        .stat-value {
            font-family: 'Rajdhani', sans-serif;
            font-size: 22px;
            font-weight: 700;
            color: var(--cyber-heading);
            line-height: 1.1;
        }
        .stat-label {
            font-family: 'Share Tech Mono', monospace;
            font-size: 9px;
            color: var(--cyber-muted);
            text-transform: uppercase;
            letter-spacing: 1.2px;
            margin-top: 2px;
        }

        .section-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 18px;
            font-weight: 700;
            color: var(--cyber-heading);
            margin-bottom: 16px;
        }

        /* XP bar */
        .xp-bar-wrap {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px;
            padding: 20px 24px;
            margin-bottom: 32px;
        }
        .xp-bar-header {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            margin-bottom: 10px;
        }
        .xp-bar-level {
            font-family: 'Rajdhani', sans-serif;
            font-size: 20px;
            font-weight: 700;
            color: var(--cyber-accent);
        }
        .xp-bar-next {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-muted);
        }
        .xp-bar-track {
            background: var(--cyber-border);
            border-radius: 4px;
            height: 10px;
            overflow: hidden;
        }
        .xp-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--cyber-accent), var(--cyber-accent2));
            border-radius: 4px;
            transition: width 0.5s ease;
        }
        .xp-bar-sub {
            font-family: 'Share Tech Mono', monospace;
            font-size: 9px;
            color: var(--cyber-muted);
            margin-top: 6px;
        }

        /* Course progress table */
        .prog-table { width: 100%; border-collapse: collapse; margin-bottom: 40px; }
        .prog-table th {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-muted);
            letter-spacing: 1.5px;
            text-transform: uppercase;
            padding: 0 16px 10px;
            text-align: left;
            border-bottom: 1px solid var(--cyber-border);
        }
        .prog-table td {
            padding: 13px 16px;
            font-size: 13px;
            color: var(--cyber-text);
            border-bottom: 1px solid rgba(26,48,80,0.35);
        }
        .badge-passed  { background: rgba(0,255,157,0.12); color: var(--cyber-accent2); border: 1px solid rgba(0,255,157,0.25); border-radius: 20px; padding: 2px 10px; font-size: 10px; font-family: 'Share Tech Mono',monospace; }
        .badge-failed  { background: rgba(255,59,92,0.1);  color: var(--cyber-danger);  border: 1px solid rgba(255,59,92,0.25);  border-radius: 20px; padding: 2px 10px; font-size: 10px; font-family: 'Share Tech Mono',monospace; }
        .badge-none    { background: rgba(100,116,139,0.12); color: var(--cyber-muted); border: 1px solid rgba(100,116,139,0.2); border-radius: 20px; padding: 2px 10px; font-size: 10px; font-family: 'Share Tech Mono',monospace; }

        /* Quiz history */
        .history-table { width: 100%; border-collapse: collapse; }
        .history-table th {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-muted);
            letter-spacing: 1.5px;
            text-transform: uppercase;
            padding: 0 14px 10px;
            text-align: left;
            border-bottom: 1px solid var(--cyber-border);
        }
        .history-table td {
            padding: 12px 14px;
            font-size: 13px;
            color: var(--cyber-text);
            border-bottom: 1px solid rgba(26,48,80,0.3);
        }
        .score-hi  { font-family: 'Rajdhani',sans-serif; font-size: 15px; font-weight: 700; color: var(--cyber-accent2); }
        .score-lo  { font-family: 'Rajdhani',sans-serif; font-size: 15px; font-weight: 700; color: var(--cyber-danger); }
        .empty-state {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-muted);
            padding: 24px 0;
        }
    </style>
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
