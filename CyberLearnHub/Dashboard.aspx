<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
         Inherits="CyberLearnHub.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Dashboard — CyberLearn Hub</title>
    <style>
        .dash-wrap { max-width: 1100px; margin: 0 auto; padding: 40px 24px 60px; }

        /* Greeting */
        .dash-greeting {
            margin-bottom: 32px;
        }
        .dash-greeting-tag {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-accent);
            letter-spacing: 3px;
            margin-bottom: 6px;
        }
        .dash-greeting-name {
            font-family: 'Rajdhani', sans-serif;
            font-size: 32px;
            font-weight: 700;
            color: var(--cyber-heading);
        }
        .dash-greeting-name span { color: var(--cyber-accent); }

        /* Stats row */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
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
            gap: 16px;
            transition: border-color 0.2s;
        }
        .stat-card:hover { border-color: rgba(0,212,255,0.3); }
        .stat-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }
        .stat-icon.blue   { background: rgba(0,212,255,0.1);  color: var(--cyber-accent); }
        .stat-icon.green  { background: rgba(0,255,157,0.1);  color: var(--cyber-accent2); }
        .stat-icon.amber  { background: rgba(250,199,117,0.1); color: var(--cyber-amber); }
        .stat-icon.danger { background: rgba(255,59,92,0.1);  color: var(--cyber-danger); }
        .stat-value {
            font-family: 'Rajdhani', sans-serif;
            font-size: 26px;
            font-weight: 700;
            color: var(--cyber-heading);
            line-height: 1;
        }
        .stat-label {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-muted);
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-top: 2px;
        }

        /* Section header */
        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }
        .section-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 18px;
            font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 0.5px;
        }
        .section-link {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-accent);
            text-decoration: none;
            letter-spacing: 1px;
        }
        .section-link:hover { color: #33ddff; }

        /* My courses grid */
        .my-courses-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 16px;
            margin-bottom: 40px;
        }
        .my-course-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px;
            padding: 18px;
            transition: border-color 0.2s;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .my-course-card:hover { border-color: rgba(0,212,255,0.3); }
        .my-course-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 16px;
            font-weight: 700;
            color: var(--cyber-heading);
        }
        .quiz-status-badge {
            font-family: 'Share Tech Mono', monospace;
            font-size: 9px;
            padding: 3px 10px;
            border-radius: 20px;
            letter-spacing: 1px;
            text-transform: uppercase;
            display: inline-block;
        }
        .qs-none   { background: rgba(90,122,153,0.15); color: var(--cyber-muted);    border: 1px solid var(--cyber-border); }
        .qs-passed { background: rgba(0,255,157,0.1);   color: var(--cyber-accent2);  border: 1px solid rgba(0,255,157,0.3); }
        .qs-failed { background: rgba(255,59,92,0.1);   color: var(--cyber-danger);   border: 1px solid rgba(255,59,92,0.3); }
        .my-course-actions { display: flex; gap: 8px; margin-top: auto; }
        .btn-sm {
            font-family: 'Rajdhani', sans-serif;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 1px;
            padding: 6px 12px;
            border-radius: 5px;
            text-transform: uppercase;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.2s, color 0.2s;
        }
        .btn-sm-outline { border: 1px solid var(--cyber-border); color: var(--cyber-muted); background: transparent; }
        .btn-sm-outline:hover { border-color: var(--cyber-accent); color: var(--cyber-accent); }
        .btn-sm-accent  { border: 1px solid var(--cyber-accent); color: var(--cyber-accent); background: rgba(0,212,255,0.05); }
        .btn-sm-accent:hover { background: rgba(0,212,255,0.12); }

        /* Recent activity table */
        .activity-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 40px;
        }
        .activity-table th {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-muted);
            letter-spacing: 1.5px;
            text-transform: uppercase;
            padding: 0 16px 10px;
            text-align: left;
            border-bottom: 1px solid var(--cyber-border);
        }
        .activity-table td {
            padding: 12px 16px;
            font-size: 13px;
            color: var(--cyber-text);
            border-bottom: 1px solid rgba(26,48,80,0.5);
        }
        .activity-table tr:last-child td { border-bottom: none; }
        .activity-table tr:hover td { background: rgba(0,212,255,0.03); }

        /* Empty */
        .dash-empty {
            text-align: center;
            padding: 48px 20px;
            color: var(--cyber-muted);
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            letter-spacing: 1px;
        }
        .dash-empty i { font-size: 36px; display: block; margin-bottom: 12px; color: var(--cyber-border); }
    </style>
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
