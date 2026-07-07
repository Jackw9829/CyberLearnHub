<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="About.aspx.cs"
         Inherits="CyberLearnHub.About" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>About — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/about.css") %>" />
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
