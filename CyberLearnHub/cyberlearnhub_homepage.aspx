<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="cyberlearnhub_homepage.aspx.cs"
         Inherits="CyberLearnHub.cyberlearnhub_homepage" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>CyberLearn Hub - Master Cybersecurity</title>
    <style>
        /* =============================================
           HERO SECTION
        ============================================= */
        .hero {
            position: relative;
            z-index: 5;
            padding: 80px 40px 60px;
            text-align: center;
            max-width: 820px;
            margin: 0 auto;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 5px 16px;
            border: 1px solid rgba(0,212,255,0.3);
            background: rgba(0,212,255,0.05);
            border-radius: 20px;
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-accent);
            letter-spacing: 1.5px;
            margin-bottom: 28px;
            text-transform: uppercase;
        }

        .hero h1 {
            font-family: 'Rajdhani', sans-serif;
            font-size: 56px;
            font-weight: 700;
            line-height: 1.1;
            color: var(--cyber-heading);
            letter-spacing: -0.5px;
            margin-bottom: 22px;
        }

        .hero h1 .accent { color: var(--cyber-accent); }

        .hero p {
            font-size: 16px;
            line-height: 1.75;
            color: var(--cyber-muted);
            max-width: 560px;
            margin: 0 auto 12px;
        }

        .terminal-tag {
            font-family: 'Share Tech Mono', monospace;
            font-size: 12px;
            color: var(--cyber-accent2);
            margin-bottom: 32px;
            display: block;
        }

        .hero-ctas {
            display: flex;
            gap: 14px;
            justify-content: center;
            flex-wrap: wrap;
        }

        /* =============================================
           STATS BAR
        ============================================= */
        .stats-bar {
            position: relative;
            z-index: 5;
            display: flex;
            margin: 0 40px;
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            background: var(--cyber-surface);
            overflow: hidden;
        }

        .stat-item {
            flex: 1;
            padding: 20px 24px;
            text-align: center;
            border-right: 1px solid var(--cyber-border);
        }

        .stat-item:last-child { border-right: none; }

        .stat-num {
            font-family: 'Share Tech Mono', monospace;
            font-size: 24px;
            color: var(--cyber-accent);
            display: block;
            margin-bottom: 4px;
        }

        .stat-label {
            font-size: 11px;
            color: var(--cyber-muted);
            text-transform: uppercase;
            letter-spacing: 1.5px;
        }

        /* =============================================
           SEARCH BAR
        ============================================= */
        .search-section {
            position: relative;
            z-index: 5;
            padding: 48px 40px 0;
        }

        .search-wrapper {
            display: flex;
            gap: 10px;
            max-width: 600px;
            margin: 0 auto;
        }

        .search-input {
            flex: 1;
            padding: 12px 18px;
            background: var(--cyber-surface);
            border: 1px solid var(--cyber-border);
            border-radius: 5px;
            color: var(--cyber-text);
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
            letter-spacing: 0.5px;
            outline: none;
            transition: border-color 0.2s;
        }

        .search-input:focus { border-color: var(--cyber-accent); }
        .search-input::placeholder { color: var(--cyber-muted); }

        /* =============================================
           COURSES SECTION
        ============================================= */
        .courses-section {
            position: relative;
            z-index: 5;
            padding: 40px 40px;
        }

        .section-header {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            margin-bottom: 24px;
        }

        .link-all {
            font-size: 12px;
            color: var(--cyber-accent);
            text-decoration: none;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 500;
        }

        .link-all:hover { color: #33ddff; }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
        }

        /* =============================================
           FEATURES SECTION
        ============================================= */
        .features-section {
            position: relative;
            z-index: 5;
            padding: 0 40px 52px;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
        }

        .feature-card {
            background: var(--cyber-surface);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 22px 18px;
            text-align: center;
            transition: border-color 0.2s;
        }

        .feature-card:hover { border-color: rgba(0,212,255,0.35); }

        .feature-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px;
            font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin-bottom: 7px;
        }

        .feature-desc {
            font-size: 12px;
            color: var(--cyber-muted);
            line-height: 1.65;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- =============================================
         HERO
    ============================================= -->
    <section class="hero" aria-label="Hero section">
        <div class="hero-badge" aria-label="Platform status">
            <div class="badge-dot" aria-hidden="true"></div>
            LIVE PLATFORM &mdash; CYBERSECURITY EDUCATION
        </div>

        <h1>Master <span class="accent">Cybersecurity</span><br />from the Ground Up</h1>

        <p>
            Interactive courses, auto-graded quizzes, and real-time progress tracking &mdash;
            designed for students and beginners entering the world of digital defence.
        </p>

        <span class="terminal-tag">&gt; enrollment.open // all skill levels welcome</span>

        <div class="hero-ctas">
            <asp:Button ID="btnBrowseCourses" runat="server" Text="Browse Courses"
                CssClass="btn-primary btn-lg" OnClick="btnBrowseCourses_Click" />
            <a href="About.aspx" class="btn-outline-lg">Learn More</a>
        </div>
    </section>

    <!-- =============================================
         STATS BAR
    ============================================= -->
    <div class="stats-bar" role="region" aria-label="Platform statistics">
        <div class="stat-item">
            <span class="stat-num">12+</span>
            <span class="stat-label">Courses Available</span>
        </div>
        <div class="stat-item">
            <span class="stat-num">100%</span>
            <span class="stat-label">Auto-Marked Quizzes</span>
        </div>
        <div class="stat-item">
            <span class="stat-num">3</span>
            <span class="stat-label">User Roles</span>
        </div>
        <div class="stat-item">
            <span class="stat-num">24/7</span>
            <span class="stat-label">Self-Paced Access</span>
        </div>
    </div>

    <!-- =============================================
         SEARCH BAR
    ============================================= -->
    <div class="search-section" role="search" aria-label="Course search">
        <div class="search-wrapper">
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="search-input"
                placeholder="Search courses, topics, keywords..."
                AutoCompleteType="Disabled" />
            <asp:Button ID="btnSearch" runat="server" Text="Search"
                CssClass="btn-primary" OnClick="btnSearch_Click" />
        </div>
        <asp:Label ID="lblSearchMsg" runat="server" Text=""
            Style="display:block; text-align:center; margin-top:10px;
                   font-family:'Share Tech Mono',monospace; font-size:12px;
                   color:var(--cyber-muted);" />
    </div>

    <!-- =============================================
         FEATURED COURSES
    ============================================= -->
    <section class="courses-section" aria-label="Featured courses">
        <div class="section-header">
            <div>
                <span class="section-title">Featured Courses</span>
                <span class="section-subtitle">// curated content</span>
            </div>
            <a href="CourseListing.aspx" class="link-all">View All &rarr;</a>
        </div>

        <div class="course-grid">

            <div class="course-card card-green">
                <div class="course-level level-beginner">&#9679; Beginner</div>
                <div class="course-title">Introduction to Cybersecurity</div>
                <div class="course-desc">
                    Core concepts, threats, and terminology for those starting their security journey.
                </div>
                <div class="course-meta">
                    <span class="meta-item">
                        <i class="ti ti-clock" style="font-size:13px;" aria-hidden="true"></i> 4h 30m
                    </span>
                    <span class="meta-item">
                        <i class="ti ti-list-check" style="font-size:13px;" aria-hidden="true"></i> 8 quizzes
                    </span>
                </div>
                <asp:Button ID="btnEnroll1" runat="server" Text="Enroll Now"
                    CssClass="btn-enroll" OnClick="btnEnroll1_Click" CommandArgument="1" />
            </div>

            <div class="course-card card-blue">
                <div class="course-level level-intermediate">&#9670; Intermediate</div>
                <div class="course-title">TBC</div>
                <div class="course-desc">TBC</div>
                <div class="course-meta">
                    <span class="meta-item">TBC</span>
                </div>
                <asp:Button ID="btnEnroll2" runat="server" Text="Enroll Now"
                    CssClass="btn-enroll" OnClick="btnEnroll2_Click" CommandArgument="2" />
            </div>

            <div class="course-card card-red">
                <div class="course-level level-advanced">&#9650; Advanced</div>
                <div class="course-title">TBC</div>
                <div class="course-desc">TBC</div>
                <div class="course-meta">
                    <span class="meta-item">TBC</span>
                </div>
                <asp:Button ID="btnEnroll3" runat="server" Text="Enroll Now"
                    CssClass="btn-enroll" OnClick="btnEnroll3_Click" CommandArgument="3" />
            </div>

        </div>
    </section>

    <!-- =============================================
         FEATURES HIGHLIGHT
    ============================================= -->
    <div class="features-section" role="region" aria-label="Platform features">
        <div class="feature-card">
            <div class="feature-icon fi-cyan" aria-hidden="true"><i class="ti ti-school"></i></div>
            <div class="feature-title">Structured Learning</div>
            <div class="feature-desc">Courses organised by difficulty with downloadable resources.</div>
        </div>
        <div class="feature-card">
            <div class="feature-icon fi-green" aria-hidden="true"><i class="ti ti-checkbox"></i></div>
            <div class="feature-title">Auto-Graded Quizzes</div>
            <div class="feature-desc">Instant feedback on every quiz with detailed result breakdowns.</div>
        </div>
        <div class="feature-card">
            <div class="feature-icon fi-amber" aria-hidden="true"><i class="ti ti-chart-line"></i></div>
            <div class="feature-title">Progress Tracking</div>
            <div class="feature-desc">Dashboard statistics to monitor your learning milestones.</div>
        </div>
        <div class="feature-card">
            <div class="feature-icon fi-red" aria-hidden="true"><i class="ti ti-shield-check"></i></div>
            <div class="feature-title">Secure Platform</div>
            <div class="feature-desc">Session-based authentication protecting your account and data.</div>
        </div>
    </div>

</asp:Content>
