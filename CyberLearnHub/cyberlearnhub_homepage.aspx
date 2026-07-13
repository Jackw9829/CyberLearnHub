<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="cyberlearnhub_homepage.aspx.cs" Inherits="CyberLearnHub.cyberlearnhub_homepage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CyberLearn Hub - Master Cybersecurity</title>

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500&display=swap" rel="stylesheet" />

    <!-- Tabler Icons -->
    <link href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css" rel="stylesheet" />

    <link rel="stylesheet" href="Styles/homepage.css" />
</head>
<body>
    <!-- Background decorative elements -->
    <div class="grid-overlay" aria-hidden="true"></div>
    <div class="scanline" aria-hidden="true"></div>

    <!-- ASP.NET requires one server-side form wrapping all server controls -->
    <form id="form1" runat="server">

        <!-- =============================================
             NAVIGATION
        ============================================= -->
        <!-- Nav overlay outside <nav> so position:fixed isn't clipped by backdrop-filter stacking context -->
        <div class="nav-overlay" id="navOverlay"></div>

        <nav class="navbar" role="navigation" aria-label="Main navigation">

            <a href="cyberlearnhub_homepage.aspx" class="logo">
                <div class="logo-icon" aria-hidden="true">
                    <i class="ti ti-shield-lock"></i>
                </div>
                CYBER<span class="logo-accent">LEARN</span> HUB
            </a>

            <ul class="nav-links" id="navLinks">
                <li><a href="CourseListing.aspx">Courses</a></li>
                <li><a href="About.aspx">About</a></li>
                <asp:PlaceHolder ID="pnlUserNav" runat="server" Visible="false">
                    <li><a href="Dashboard.aspx">Dashboard</a></li>
                    <li><a href="MyCourses.aspx">My Courses</a></li>
                    <li><a href="MyProgress.aspx">Progress</a></li>
                    <li><a href="Leaderboard.aspx">Leaderboard</a></li>
                    <li><a href="Labs.aspx">Labs</a></li>
                    <li><a href="~/Forum/Index.aspx" runat="server">Forums</a></li>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="pnlAdminNav" runat="server" Visible="false">
                </asp:PlaceHolder>
            </ul>

            <button class="btn-hamburger" id="navHamburger" type="button" aria-label="Open menu" aria-expanded="false" aria-controls="navLinks">
                <i class="ti ti-menu-2"></i>
            </button>

            <div class="nav-buttons">
                <%-- Guest buttons: shown when not logged in --%>
                <asp:Panel ID="pnlGuestButtons" runat="server" Visible="true" style="display:flex;gap:10px;">
                    <asp:Button ID="btnLogin"    runat="server" Text="Log In"   CssClass="btn-ghost"   OnClick="btnLogin_Click"    CausesValidation="false" />
                    <asp:Button ID="btnRegister" runat="server" Text="Register" CssClass="btn-primary" OnClick="btnRegister_Click" CausesValidation="false" />
                </asp:Panel>

                <%-- Logged-in buttons: shown when session is active --%>
                <asp:Panel ID="pnlUserButtons" runat="server" Visible="false" style="display:flex;gap:10px;align-items:center;">
                    <span class="nav-user-chip">
                        <i class="ti ti-user user-icon"></i>
                        <asp:Label ID="lblNavUsername" runat="server" CssClass="user-name" />
                    </span>
                    <asp:HyperLink ID="hlProfile" runat="server" NavigateUrl="~/Profile.aspx" CssClass="btn-ghost">Profile</asp:HyperLink>
                    <asp:Button ID="btnLogout" runat="server" Text="Log Out" CssClass="btn-danger" OnClick="btnLogout_Click" OnClientClick="return confirmLogout(this);" CausesValidation="false" />
                </asp:Panel>
            </div>
        </nav>

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
                Interactive courses, auto-graded quizzes, and real-time progress tracking -
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
        <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch"
            CssClass="search-section">
            <div class="search-wrapper">
                <%-- TextBox renders as <input type="text"> --%>
                <asp:TextBox ID="txtSearch" runat="server"
                    CssClass="search-input"
                    placeholder="Search courses, topics, keywords..."
                    AutoCompleteType="Disabled" />

                <asp:Button ID="btnSearch" runat="server" Text="Search"
                    CssClass="btn-primary" OnClick="btnSearch_Click" />
            </div>

            <%-- Label to show search feedback from code-behind --%>
            <asp:Label ID="lblSearchMsg" runat="server" Text=""
                Style="display:block; text-align:center; margin-top:10px;
                       font-family:'Share Tech Mono',monospace; font-size:12px;
                       color:#5a7a99;" />
        </asp:Panel>

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

                <!-- Course Card 1 — Beginner -->
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
                        CssClass="btn-enroll" OnClick="btnEnroll1_Click"
                        CommandArgument="1" />
                </div>

                <!-- Course Card 2 — Intermediate -->
                <div class="course-card card-blue">
                    <div class="course-level level-intermediate">&#9670; Intermediate</div>
                    <div class="course-title">Network Security Basics</div>
                    <div class="course-desc">Firewalls, VPNs and securing network traffic.</div>
                    <div class="course-meta">
                        <span class="meta-item">
                            <i class="ti ti-clock" style="font-size:13px;" aria-hidden="true"></i> 9h 15m
                        </span>
                        <span class="meta-item">
                            <i class="ti ti-list-check" style="font-size:13px;" aria-hidden="true"></i> 10 quizzes
                        </span>
                    </div>
                    <asp:Button ID="btnEnroll2" runat="server" Text="Enroll Now"
                        CssClass="btn-enroll" OnClick="btnEnroll2_Click"
                        CommandArgument="2" />
                </div>

                <!-- Course Card 3 — Advanced -->
                <div class="course-card card-red">
                    <div class="course-level level-advanced">&#9650; Advanced</div>
                    <div class="course-title">Cryptography Essentials</div>
                    <div class="course-desc">Encryption, hashing and digital signatures.</div>
                    <div class="course-meta">
                        <span class="meta-item">
                            <i class="ti ti-clock" style="font-size:13px;" aria-hidden="true"></i> 12h 15m
                        </span>
                        <span class="meta-item">
                            <i class="ti ti-list-check" style="font-size:13px;" aria-hidden="true"></i> 12 quizzes
                        </span>
                    </div>
                    <asp:Button ID="btnEnroll3" runat="server" Text="Enroll Now"
                        CssClass="btn-enroll" OnClick="btnEnroll3_Click"
                        CommandArgument="3" />
                </div>

            </div>
        </section>

        <!-- =============================================
             FEATURES HIGHLIGHT
        ============================================= -->
        <div class="features-section" role="region" aria-label="Platform features">
            <div class="feature-card">
                <div class="feature-icon fi-cyan" aria-hidden="true">
                    <i class="ti ti-school"></i>
                </div>
                <div class="feature-title">Structured Learning</div>
                <div class="feature-desc">Courses organised by difficulty with downloadable PDF resources.</div>
            </div>

            <div class="feature-card">
                <div class="feature-icon fi-green" aria-hidden="true">
                    <i class="ti ti-checkbox"></i>
                </div>
                <div class="feature-title">Auto-Graded Quizzes</div>
                <div class="feature-desc">Instant feedback on every quiz with detailed result breakdowns.</div>
            </div>

            <div class="feature-card">
                <div class="feature-icon fi-amber" aria-hidden="true">
                    <i class="ti ti-chart-line"></i>
                </div>
                <div class="feature-title">Progress Tracking</div>
                <div class="feature-desc">Dashboard statistics to monitor your learning milestones.</div>
            </div>

            <div class="feature-card">
                <div class="feature-icon fi-red" aria-hidden="true">
                    <i class="ti ti-shield-check"></i>
                </div>
                <div class="feature-title">Secure Platform</div>
                <div class="feature-desc">Session-based authentication protecting your account and data.</div>
            </div>
        </div>

        <!-- =============================================
             FOOTER
        ============================================= -->
        <footer class="site-footer" role="contentinfo">
            <span class="footer-copy">
                © 2025 CyberLearn Hub
            </span>
            <nav class="footer-links" aria-label="Footer navigation">
                <a href="About.aspx">About</a>
                <%--<a href="Privacy.aspx">Privacy</a>--%>
                <a href="Contact.aspx">Contact</a>
            </nav>
        </footer>

        <!-- =============================================
             FLOATING CHATBOT
        ============================================= -->

        <div id="cb-container">

        <!-- Toggle Button -->
        <button id="cb-toggle" title="Chat with CyberBot" type="button">
            <i class="ti ti-shield-bolt" style="color:#fff; font-size:22px;"></i>
            <span id="cb-badge"></span>
        </button>

        <!-- Chat Window -->
        <div id="cb-window" role="dialog" aria-label="CyberBot chat">

            <!-- Header -->
            <div id="cb-head">
                <div class="cb-av">
                    <i class="ti ti-robot" style="color:var(--cyber-accent);"></i>
                </div>
                <div class="cb-title">
                    <div class="cb-name">CYBERBOT</div>
                    <div class="cb-sub">// AI Security Assistant</div>
                </div>
                <div class="cb-online"></div>
                <button id="cb-expand" onclick="window.open('Chatbot.aspx','_blank')" title="Open full page" type="button"><i class="ti ti-external-link"></i></button>
                <button id="cb-close" onclick="cbToggle()" title="Close" type="button">&#10005;</button>
            </div>

            <!-- Messages -->
            <div id="cb-msgs">
                <div class="cb-row bot">
                    <div class="cb-av"><i class="ti ti-robot" style="color:var(--cyber-accent);font-size:11px;"></i></div>
                    <div class="cb-bubble">
                        Hi! I&#39;m <strong>CyberBot</strong> &#128737;<br />
                        Ask me anything about cybersecurity!
                    </div>
                </div>
            </div>

            <!-- Suggestion chips -->
            <div id="cb-chips">
                <button class="cb-chip" onclick="cbChip(this)" type="button">What is phishing?</button>
                <button class="cb-chip" onclick="cbChip(this)" type="button">How does encryption work?</button>
                <button class="cb-chip" onclick="cbChip(this)" type="button">What is the OWASP Top 10?</button>
                <button class="cb-chip" onclick="cbChip(this)" type="button">Explain SQL Injection</button>
            </div>

            <!-- Input -->
            <div id="cb-foot">
                <input id="cb-input" type="text" placeholder="Ask a question..."
                       autocomplete="off" onkeydown="if(event.key==='Enter'){cbSend();return false;}" />
                <button id="cb-send" onclick="cbSend()" type="button">Send</button>
            </div>
        </div>

        </div><!-- end cb-container -->

        <!-- Floating Admin Button -->
        <% if (Session["UserID"] != null && (Session["Role"] as string) == "Admin") { %>
        <a href="Admin/Default.aspx" title="Admin Panel"
           style="position:fixed;top:80px;right:24px;width:44px;height:44px;border-radius:50%;background:#080d14;border:1.5px solid #00d4ff;color:#00d4ff;display:flex;align-items:center;justify-content:center;font-size:20px;text-decoration:none;z-index:9999;box-shadow:0 0 8px rgba(0,212,255,0.25);backdrop-filter:blur(6px);">
            <i class="ti ti-user-cog"></i>
        </a>
        <% } %>

        <!-- Chatbot Script -->
        <script type="text/javascript">
            var cbIsOpen = false;
            var cbIsBusy = false;
            var cbHadChat = false;
            var cbGuestLimit = 3;
            var cbLoggedIn = <%= Session["UserID"] != null ? "true" : "false" %>;

            // ---- Drag logic ----
            (function () {
                var container = document.getElementById('cb-container');
                var toggle    = document.getElementById('cb-toggle');
                var startX, startY, origLeft, origTop, moved;

                function getPos() {
                    var r = container.getBoundingClientRect();
                    return { left: r.left, top: r.top };
                }

                function onDown(e) {
                    var pt = e.touches ? e.touches[0] : e;
                    startX = pt.clientX;
                    startY = pt.clientY;
                    var pos = getPos();
                    origLeft = pos.left;
                    origTop  = pos.top;
                    moved = false;
                    document.addEventListener('mousemove', onMove);
                    document.addEventListener('mouseup',   onUp);
                    document.addEventListener('touchmove', onMove, { passive: false });
                    document.addEventListener('touchend',  onUp);
                }

                function onMove(e) {
                    if (e.cancelable) e.preventDefault();
                    var pt = e.touches ? e.touches[0] : e;
                    var dx = pt.clientX - startX;
                    var dy = pt.clientY - startY;
                    if (Math.abs(dx) > 4 || Math.abs(dy) > 4) moved = true;
                    var newLeft = Math.max(0, Math.min(origLeft + dx, window.innerWidth  - container.offsetWidth));
                    var newTop  = Math.max(0, Math.min(origTop  + dy, window.innerHeight - container.offsetHeight));
                    container.style.left   = newLeft + 'px';
                    container.style.top    = newTop  + 'px';
                    container.style.right  = 'auto';
                    container.style.bottom = 'auto';
                }

                function onUp() {
                    document.removeEventListener('mousemove', onMove);
                    document.removeEventListener('mouseup',   onUp);
                    document.removeEventListener('touchmove', onMove);
                    document.removeEventListener('touchend',  onUp);
                    if (!moved) cbToggle();
                }

                toggle.addEventListener('mousedown', onDown);
                toggle.addEventListener('touchstart', onDown, { passive: true });
            })();
            // ---- End drag logic ----

            function cbToggle() {
                cbIsOpen = !cbIsOpen;
                var win   = document.getElementById('cb-window');
                var badge = document.getElementById('cb-badge');
                if (cbIsOpen) {
                    win.classList.add('open');
                    badge.style.display = 'none';
                    document.getElementById('cb-input').focus();
                } else {
                    win.classList.remove('open');
                }
            }

            function cbScroll() {
                var m = document.getElementById('cb-msgs');
                m.scrollTop = m.scrollHeight;
            }

            function cbAddMsg(role, html) {
                var msgs   = document.getElementById('cb-msgs');
                var row    = document.createElement('div');
                row.className = 'cb-row ' + role;

                var av = document.createElement('div');
                av.className = 'cb-av';
                av.innerHTML = role === 'bot'
                    ? '<i class="ti ti-robot"    style="color:var(--cyber-accent);font-size:11px;"></i>'
                    : '<i class="ti ti-user"     style="color:var(--cyber-accent2);font-size:11px;"></i>';

                var bubble = document.createElement('div');
                bubble.className = 'cb-bubble';
                bubble.innerHTML = html;

                row.appendChild(av);
                row.appendChild(bubble);
                msgs.appendChild(row);
                cbScroll();
                return row;
            }

            function cbShowTyping() {
                var row = cbAddMsg('bot',
                    '<div class="cb-dots">' +
                    '<span></span><span></span><span></span>' +
                    '</div>');
                row.id = 'cb-typing';
            }

            function cbFmt(t) {
                return t
                    .replace(/&/g,  '&amp;')
                    .replace(/</g,  '&lt;')
                    .replace(/>/g,  '&gt;')
                    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                    .replace(/`([^`]+)`/g, '<code style="background:rgba(0,212,255,0.1);padding:1px 4px;border-radius:3px;font-size:11px;color:var(--cyber-accent)">' + '$1' + '</code>')
                    .replace(/^[\*\-] (.+)$/gm, '<div style="margin:2px 0 2px 6px">&bull; $1</div>')
                    .replace(/\n\n/g, '<br /><br />')
                    .replace(/\n/g,  '<br />');
            }

            function cbGuestBlocked() {
                if (cbLoggedIn) return false;
                var count = parseInt(sessionStorage.getItem('cb_guest_count') || '0', 10);
                return count >= cbGuestLimit;
            }

            function cbShowGuestLimit() {
                cbAddMsg('bot',
                    '<span style="color:var(--cyber-amber)">' +
                    '&#9888; You have used your 3 free questions.</span><br />' +
                    'Please <a href="Login.aspx" ' +
                    'style="color:var(--cyber-accent);text-decoration:underline;">Log In</a> or ' +
                    '<a href="Register.aspx" ' +
                    'style="color:var(--cyber-accent2);text-decoration:underline;">Register</a> ' +
                    'to continue chatting.');
                var inp  = document.getElementById('cb-input');
                var send = document.getElementById('cb-send');
                inp.disabled  = true;
                send.disabled = true;
                inp.placeholder = 'Login or register to continue...';
            }

            function cbHideChips() {
                var c = document.getElementById('cb-chips');
                if (c) c.style.display = 'none';
            }

            function cbChip(btn) {
                document.getElementById('cb-input').value = btn.textContent || btn.innerText;
                cbHideChips();
                cbSend();
            }

            function cbSend() {
                if (cbIsBusy) return;
                var input = document.getElementById('cb-input');
                var msg   = input.value.replace(/^\s+|\s+$/g, '');
                if (!msg) return;

                if (cbGuestBlocked()) { cbShowGuestLimit(); return; }

                cbHideChips();
                input.value = '';
                cbIsBusy    = true;
                cbHadChat   = true;
                document.getElementById('cb-send').disabled = true;

                if (!cbLoggedIn) {
                    var count = parseInt(sessionStorage.getItem('cb_guest_count') || '0', 10);
                    sessionStorage.setItem('cb_guest_count', count + 1);
                }

                cbAddMsg('user', cbFmt(msg));
                cbShowTyping();

                fetch('ChatbotHandler.ashx', {
                    method:  'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body:    JSON.stringify({ message: msg })
                })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    var t = document.getElementById('cb-typing');
                    if (t) t.parentNode.removeChild(t);
                    if (data.success) {
                        cbAddMsg('bot', cbFmt(data.reply));
                    } else {
                        cbAddMsg('bot', '&#9888; ' + (data.error || data.reply || 'Something went wrong.'));
                    }
                    if (!cbIsOpen) {
                        document.getElementById('cb-badge').style.display = 'block';
                    }
                })
                .catch(function() {
                    var t = document.getElementById('cb-typing');
                    if (t) t.parentNode.removeChild(t);
                    cbAddMsg('bot', '&#9888; Could not reach the server. Please try again.');
                })
                ['finally'](function() {
                    cbIsBusy = false;
                    document.getElementById('cb-send').disabled = false;
                    document.getElementById('cb-input').focus();
                });
            }
        </script>
        <!-- =============================================
             END FLOATING CHATBOT
        ============================================= -->

        <!-- =============================================
             LOGOUT CONFIRMATION MODAL
        ============================================= -->
        <div id="logoutModal" class="logout-modal-overlay" role="dialog" aria-modal="true" aria-labelledby="logoutModalTitle">
            <div class="logout-modal">
                <div class="logout-modal-icon" aria-hidden="true"><i class="ti ti-logout"></i></div>
                <h3 id="logoutModalTitle" class="logout-modal-title">Confirm Logout</h3>
                <p class="logout-modal-text">Are you sure you want to log out?</p>
                <div class="logout-modal-actions">
                    <button type="button" class="btn-ghost" onclick="logoutCancel()">Cancel</button>
                    <button type="button" class="btn-danger" onclick="logoutYes()">Yes</button>
                </div>
            </div>
        </div>

        <script type="text/javascript">
            var _logoutConfirmed = false;
            var _logoutBtn = null;
            function confirmLogout(btn) {
                if (_logoutConfirmed) { _logoutConfirmed = false; return true; }
                _logoutBtn = btn;
                document.getElementById('logoutModal').classList.add('open');
                return false;
            }
            function logoutYes() {
                _logoutConfirmed = true;
                document.getElementById('logoutModal').classList.remove('open');
                if (_logoutBtn) _logoutBtn.click();
            }
            function logoutCancel() {
                _logoutBtn = null;
                document.getElementById('logoutModal').classList.remove('open');
            }
        </script>

    </form><!-- end form1 -->
    <script src="Scripts/nav.js"></script>
</body>
</html>
