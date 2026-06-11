<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="About.aspx.cs"
         Inherits="CyberLearnHub.About" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>About — CyberLearn Hub</title>
    <style>
        .about-wrapper {
            max-width: 900px;
            margin: 0 auto;
            padding: 52px 40px 60px;
        }

        .page-header { margin-bottom: 48px; }
        .page-header .badge { margin-bottom: 16px; }

        /* ── Section ── */
        .about-section { margin-bottom: 48px; }

        .about-section-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 18px;
            font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 0.5px;
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .about-section-title i { color: var(--cyber-accent); font-size: 20px; }

        .about-section p {
            font-size: 14px;
            line-height: 1.85;
            color: var(--cyber-muted);
            margin-bottom: 14px;
        }

        /* ── Intro highlight block ── */
        .intro-block {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-left: 3px solid var(--cyber-accent);
            border-radius: 8px;
            padding: 28px 32px;
            margin-bottom: 40px;
        }

        .intro-block p {
            font-size: 15px;
            line-height: 1.85;
            color: var(--cyber-text);
            margin: 0;
        }

        /* ── Mission / Vision cards ── */
        .mv-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .mv-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 24px;
            position: relative;
            overflow: hidden;
        }

        .mv-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
        }

        .mv-mission::before { background: var(--cyber-accent); }
        .mv-vision::before  { background: var(--cyber-accent2); }

        .mv-label {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 10px;
        }

        .mv-mission .mv-label { color: var(--cyber-accent); }
        .mv-vision  .mv-label { color: var(--cyber-accent2); }

        .mv-card p {
            font-size: 13px;
            line-height: 1.75;
            color: var(--cyber-text);
            margin: 0;
        }

        /* ── What we offer ── */
        .offer-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
        }

        .offer-card {
            background: var(--cyber-surface);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 22px 18px;
            text-align: center;
            transition: border-color 0.2s;
        }

        .offer-card:hover { border-color: rgba(0,212,255,0.3); }

        .offer-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 14px;
            font-size: 20px;
            border: 1px solid;
        }

        .oi-cyan  { background: rgba(0,212,255,0.08); border-color: rgba(0,212,255,0.3); color: var(--cyber-accent); }
        .oi-green { background: rgba(0,255,157,0.08); border-color: rgba(0,255,157,0.3); color: var(--cyber-accent2); }
        .oi-amber { background: rgba(250,199,117,0.08); border-color: rgba(250,199,117,0.3); color: var(--cyber-amber); }
        .oi-red   { background: rgba(255,59,92,0.08); border-color: rgba(255,59,92,0.3); color: var(--cyber-danger); }

        .offer-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px;
            font-weight: 700;
            color: var(--cyber-heading);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        .offer-desc {
            font-size: 12px;
            color: var(--cyber-muted);
            line-height: 1.65;
        }

        /* ── Timeline / history ── */
        .timeline {
            position: relative;
            padding-left: 28px;
        }

        .timeline::before {
            content: '';
            position: absolute;
            left: 7px;
            top: 6px;
            bottom: 0;
            width: 1px;
            background: var(--cyber-border);
        }

        .tl-item {
            position: relative;
            margin-bottom: 28px;
        }

        .tl-item::before {
            content: '';
            position: absolute;
            left: -24px;
            top: 6px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--cyber-accent);
            border: 2px solid var(--cyber-bg);
            box-shadow: 0 0 0 1px var(--cyber-accent);
        }

        .tl-year {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-accent);
            letter-spacing: 2px;
            margin-bottom: 4px;
        }

        .tl-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 15px;
            font-weight: 700;
            color: var(--cyber-heading);
            margin-bottom: 4px;
        }

        .tl-desc {
            font-size: 13px;
            color: var(--cyber-muted);
            line-height: 1.65;
        }

        /* ── Achievements ── */
        .achieve-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
        }

        .achieve-card {
            background: var(--cyber-surface);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 20px 16px;
            text-align: center;
        }

        .achieve-num {
            font-family: 'Share Tech Mono', monospace;
            font-size: 28px;
            color: var(--cyber-accent);
            display: block;
            margin-bottom: 4px;
        }

        .achieve-label {
            font-size: 11px;
            color: var(--cyber-muted);
            text-transform: uppercase;
            letter-spacing: 1.5px;
        }

        /* ── Contact ── */
        .contact-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
        }

        .contact-item {
            background: var(--cyber-surface);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .contact-icon {
            width: 38px;
            height: 38px;
            background: rgba(0,212,255,0.08);
            border: 1px solid rgba(0,212,255,0.25);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            color: var(--cyber-accent);
            flex-shrink: 0;
        }

        .contact-label {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-muted);
            letter-spacing: 1.5px;
            text-transform: uppercase;
            margin-bottom: 3px;
        }

        .contact-value {
            font-size: 13px;
            color: var(--cyber-text);
        }

        /* ── Divider ── */
        .section-divider {
            border: none;
            border-top: 1px solid var(--cyber-border);
            margin: 44px 0;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="about-wrapper">

        <!-- Page header -->
        <div class="page-header">
            <div class="badge badge-cyan">
                <div class="badge-dot"></div>
                About Us
            </div>
            <div class="page-title">About CyberLearn Hub</div>
            <div class="page-subtitle">&gt; empowering the next generation of cybersecurity professionals</div>
        </div>

        <!-- Introduction -->
        <div class="about-section">
            <div class="about-section-title">
                <i class="ti ti-info-circle"></i> Introduction
            </div>
            <div class="intro-block">
                <p>
                    CyberLearn Hub is a free, interactive cybersecurity education platform designed for students,
                    beginners, and anyone who wants to build foundational knowledge in digital security.
                    In a world where cyber threats grow more sophisticated every day, understanding how to
                    protect yourself and your organisation has never been more important &mdash; and we make
                    that learning accessible to everyone, at their own pace.
                </p>
            </div>
            <p>
                Our platform provides structured cybersecurity courses, auto-graded quizzes, and real-time
                progress tracking &mdash; all within a modern, distraction-free learning environment. Whether you
                are taking your very first step into cybersecurity or refreshing existing knowledge, CyberLearn
                Hub gives you the tools and content you need to succeed.
            </p>
        </div>

        <hr class="section-divider" />

        <!-- Mission & Vision -->
        <div class="about-section">
            <div class="about-section-title">
                <i class="ti ti-target"></i> Mission &amp; Vision
            </div>
            <div class="mv-grid">
                <div class="mv-card mv-mission">
                    <div class="mv-label">&#9632; Mission</div>
                    <p>
                        To provide an accessible, interactive cybersecurity e-learning platform that empowers
                        students and beginners to build real-world security skills through structured courses,
                        practical quizzes, and personalised progress tracking &mdash; anytime, anywhere.
                    </p>
                </div>
                <div class="mv-card mv-vision">
                    <div class="mv-label">&#9632; Vision</div>
                    <p>
                        To become the go-to starting point for cybersecurity education, where every learner &mdash;
                        regardless of background or experience &mdash; can develop the awareness and technical
                        knowledge needed to navigate and protect the digital world safely.
                    </p>
                </div>
            </div>
        </div>

        <hr class="section-divider" />

        <!-- Background -->
        <div class="about-section">
            <div class="about-section-title">
                <i class="ti ti-history"></i> Background
            </div>
            <div class="timeline">
                <div class="tl-item">
                    <div class="tl-year">2024 &mdash; THE PROBLEM</div>
                    <div class="tl-title">A Gap in Accessible Cybersecurity Learning</div>
                    <div class="tl-desc">
                        As cyberattacks increased globally, it became clear that most learning resources
                        were either too technical for beginners or hidden behind expensive certifications.
                        Students and entry-level professionals had nowhere to start.
                    </div>
                </div>
                <div class="tl-item">
                    <div class="tl-year">2025 &mdash; THE IDEA</div>
                    <div class="tl-title">CyberLearn Hub Is Born</div>
                    <div class="tl-desc">
                        A team of computing students envisioned a platform that strips away the complexity &mdash;
                        delivering bite-sized cybersecurity content with immediate feedback through
                        auto-marked quizzes and visual progress tracking.
                    </div>
                </div>
                <div class="tl-item">
                    <div class="tl-year">2025 &mdash; TODAY</div>
                    <div class="tl-title">A Growing Learning Platform</div>
                    <div class="tl-desc">
                        Built on ASP.NET Web Forms and SQL Server, CyberLearn Hub now hosts a growing
                        library of cybersecurity courses, supporting guest browsing, registered learners,
                        and administrative management under one roof.
                    </div>
                </div>
            </div>
        </div>

        <hr class="section-divider" />

        <!-- What we offer -->
        <div class="about-section">
            <div class="about-section-title">
                <i class="ti ti-layout-grid"></i> What We Offer
            </div>
            <div class="offer-grid">
                <div class="offer-card">
                    <div class="offer-icon oi-cyan"><i class="ti ti-school"></i></div>
                    <div class="offer-title">Cybersecurity Courses</div>
                    <div class="offer-desc">
                        Structured modules covering topics from basic threats to advanced concepts,
                        organised by difficulty level.
                    </div>
                </div>
                <div class="offer-card">
                    <div class="offer-icon oi-green"><i class="ti ti-checkbox"></i></div>
                    <div class="offer-title">Auto-Marked Quizzes</div>
                    <div class="offer-desc">
                        Instant quiz results with score breakdowns so learners know exactly where
                        they stand after every assessment.
                    </div>
                </div>
                <div class="offer-card">
                    <div class="offer-icon oi-amber"><i class="ti ti-chart-line"></i></div>
                    <div class="offer-title">Progress Tracking</div>
                    <div class="offer-desc">
                        Personal dashboards showing enrolled courses, quiz scores, and overall
                        completion status at a glance.
                    </div>
                </div>
                <div class="offer-card">
                    <div class="offer-icon oi-red"><i class="ti ti-certificate"></i></div>
                    <div class="offer-title">Completion Certificates</div>
                    <div class="offer-desc">
                        Earn a certificate upon completing a course to recognise your
                        learning achievement.
                    </div>
                </div>
                <div class="offer-card">
                    <div class="offer-icon oi-cyan"><i class="ti ti-search"></i></div>
                    <div class="offer-title">Search &amp; Filter</div>
                    <div class="offer-desc">
                        Quickly find relevant courses by keyword, topic, or difficulty level
                        without scrolling through everything.
                    </div>
                </div>
                <div class="offer-card">
                    <div class="offer-icon oi-green"><i class="ti ti-lock"></i></div>
                    <div class="offer-title">Secure Accounts</div>
                    <div class="offer-desc">
                        Session-based authentication with hashed passwords keeps your
                        account and learning data safe.
                    </div>
                </div>
            </div>
        </div>

        <hr class="section-divider" />

        <!-- Achievements / Stats -->
        <div class="about-section">
            <div class="about-section-title">
                <i class="ti ti-trophy"></i> Platform Highlights
            </div>
            <div class="achieve-grid">
                <div class="achieve-card">
                    <span class="achieve-num">12+</span>
                    <span class="achieve-label">Courses Available</span>
                </div>
                <div class="achieve-card">
                    <span class="achieve-num">100%</span>
                    <span class="achieve-label">Auto-Marked Quizzes</span>
                </div>
                <div class="achieve-card">
                    <span class="achieve-num">3</span>
                    <span class="achieve-label">User Access Levels</span>
                </div>
                <div class="achieve-card">
                    <span class="achieve-num">24/7</span>
                    <span class="achieve-label">Self-Paced Access</span>
                </div>
            </div>
        </div>

        <hr class="section-divider" />

        <!-- Contact -->
        <div class="about-section">
            <div class="about-section-title">
                <i class="ti ti-mail"></i> Contact &amp; Support
            </div>
            <p>
                Have questions about a course, your account, or the platform? Reach out to us and
                our team will get back to you as soon as possible.
            </p>
            <div class="contact-grid">
                <div class="contact-item">
                    <div class="contact-icon"><i class="ti ti-mail"></i></div>
                    <div>
                        <div class="contact-label">Email Support</div>
                        <div class="contact-value">support@cyberlearnhub.edu</div>
                    </div>
                </div>
                <div class="contact-item">
                    <div class="contact-icon"><i class="ti ti-clock"></i></div>
                    <div>
                        <div class="contact-label">Response Time</div>
                        <div class="contact-value">Within 1&ndash;2 business days</div>
                    </div>
                </div>
                <div class="contact-item">
                    <div class="contact-icon"><i class="ti ti-map-pin"></i></div>
                    <div>
                        <div class="contact-label">Location</div>
                        <div class="contact-value">Asia Pacific University, Kuala Lumpur</div>
                    </div>
                </div>
                <div class="contact-item">
                    <div class="contact-icon"><i class="ti ti-help-circle"></i></div>
                    <div>
                        <div class="contact-label">General Enquiries</div>
                        <div class="contact-value">hello@cyberlearnhub.edu</div>
                    </div>
                </div>
            </div>
        </div>

    </div>

</asp:Content>
