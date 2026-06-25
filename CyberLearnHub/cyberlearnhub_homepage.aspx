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

    <style>
        /* =============================================
           RESET & ROOT VARIABLES
        ============================================= */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --cyber-bg:      #080d14;
            --cyber-surface: #0d1520;
            --cyber-card:    #111c2b;
            --cyber-border:  #1a3050;
            --cyber-accent:  #00d4ff;
            --cyber-accent2: #00ff9d;
            --cyber-danger:  #ff3b5c;
            --cyber-text:    #c8dff0;
            --cyber-muted:   #5a7a99;
            --cyber-heading: #e8f4ff;
        }

        body {
            background: var(--cyber-bg);
            font-family: 'Inter', sans-serif;
            color: var(--cyber-text);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* =============================================
           BACKGROUND EFFECTS
        ============================================= */
        .grid-overlay {
            position: fixed;
            inset: 0;
            background-image:
                linear-gradient(rgba(0,212,255,0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(0,212,255,0.03) 1px, transparent 1px);
            background-size: 40px 40px;
            pointer-events: none;
            z-index: 0;
        }

        .scanline {
            position: fixed;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: linear-gradient(90deg, transparent, rgba(0,212,255,0.4), transparent);
            animation: scan 8s linear infinite;
            pointer-events: none;
            z-index: 1;
        }

        @keyframes scan {
            0%   { top: 0; }
            100% { top: 100vh; }
        }

        /* =============================================
           NAVIGATION
        ============================================= */
        .navbar {
            position: relative;
            z-index: 100;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 40px;
            border-bottom: 1px solid var(--cyber-border);
            background: rgba(8,13,20,0.95);
            backdrop-filter: blur(8px);
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            font-family: 'Rajdhani', sans-serif;
            font-weight: 700;
            font-size: 20px;
            color: var(--cyber-heading);
            letter-spacing: 1px;
            text-decoration: none;
        }

        .logo-icon {
            width: 34px;
            height: 34px;
            background: rgba(0,212,255,0.1);
            border: 1px solid var(--cyber-accent);
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
            color: var(--cyber-accent);
        }

        .logo-accent { color: var(--cyber-accent); }

        .nav-links {
            display: flex;
            list-style: none;
            gap: 30px;
            align-items: center;
        }

        .nav-links li a {
            text-decoration: none;
            color: var(--cyber-muted);
            font-size: 12px;
            font-weight: 500;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            transition: color 0.2s;
        }

        .nav-links li a:hover { color: var(--cyber-accent); }

        .nav-buttons { display: flex; gap: 10px; }

        /* ASP.NET Button controls — override default styling */
        .btn-ghost,
        input[type="submit"].btn-ghost,
        .btn-ghost[type="submit"] {
            padding: 8px 18px;
            border: 1px solid var(--cyber-border);
            background: transparent;
            color: var(--cyber-text);
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 1px;
            border-radius: 4px;
            cursor: pointer;
            text-transform: uppercase;
            transition: all 0.2s;
        }

        .btn-ghost:hover { border-color: var(--cyber-accent); color: var(--cyber-accent); }

        .btn-primary,
        input[type="submit"].btn-primary,
        .btn-primary[type="submit"] {
            padding: 8px 20px;
            background: var(--cyber-accent);
            border: none;
            color: #080d14;
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            border-radius: 4px;
            cursor: pointer;
            text-transform: uppercase;
            transition: background 0.2s;
        }

        .btn-primary:hover { background: #33ddff; }

        .btn-danger,
        input[type="submit"].btn-danger,
        .btn-danger[type="submit"] {
            padding: 8px 18px;
            background: transparent;
            border: 1px solid var(--cyber-danger);
            color: var(--cyber-danger);
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 1px;
            border-radius: 4px;
            cursor: pointer;
            text-transform: uppercase;
            transition: all 0.2s;
        }

        .btn-danger:hover { background: var(--cyber-danger); color: #fff; }

        .nav-user-chip {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            background: rgba(0,212,255,0.06);
            border: 1px solid rgba(0,212,255,0.2);
            border-radius: 4px;
        }

        .nav-user-chip .user-icon {
            font-size: 14px;
            color: var(--cyber-accent);
            line-height: 1;
        }

        .nav-user-chip .user-name {
            font-family: 'Share Tech Mono', monospace;
            font-size: 13px;
            color: var(--cyber-accent);
            letter-spacing: 0.5px;
        }

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

        .badge-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--cyber-accent2);
            animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50%       { opacity: 0.3; }
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

        .btn-lg {
            padding: 13px 30px !important;
            font-size: 14px !important;
            letter-spacing: 1.5px !important;
            border-radius: 5px !important;
        }

        .btn-outline-lg {
            padding: 13px 30px;
            border: 1px solid var(--cyber-border);
            background: transparent;
            color: var(--cyber-text);
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px;
            font-weight: 600;
            letter-spacing: 1.5px;
            border-radius: 5px;
            cursor: pointer;
            text-transform: uppercase;
            transition: all 0.2s;
        }

        .btn-outline-lg:hover { border-color: var(--cyber-accent); color: var(--cyber-accent); }

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

        .section-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 22px;
            font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 0.5px;
        }

        .section-subtitle {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-muted);
            letter-spacing: 2px;
            margin-left: 10px;
            text-transform: uppercase;
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

        .course-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 22px;
            position: relative;
            overflow: hidden;
            transition: border-color 0.2s, transform 0.2s;
        }

        .course-card:hover {
            border-color: var(--cyber-accent);
            transform: translateY(-3px);
        }

        /* Coloured top accent bar */
        .course-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
        }

        .card-green::before  { background: var(--cyber-accent2); }
        .card-blue::before   { background: var(--cyber-accent); }
        .card-red::before    { background: var(--cyber-danger); }

        .course-level {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 12px;
        }

        .level-beginner     { color: var(--cyber-accent2); }
        .level-intermediate { color: var(--cyber-accent); }
        .level-advanced     { color: var(--cyber-danger); }

        .course-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 17px;
            font-weight: 600;
            color: var(--cyber-heading);
            margin-bottom: 10px;
            line-height: 1.3;
        }

        .course-desc {
            font-size: 13px;
            color: var(--cyber-muted);
            line-height: 1.65;
            margin-bottom: 18px;
        }

        .course-meta {
            display: flex;
            gap: 16px;
            font-size: 11px;
            color: var(--cyber-muted);
            font-family: 'Share Tech Mono', monospace;
            margin-bottom: 16px;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        /* Enroll button — asp:Button rendered as input[type=submit] */
        .btn-enroll,
        input[type="submit"].btn-enroll {
            width: 100%;
            padding: 9px;
            background: rgba(0,212,255,0.06);
            border: 1px solid rgba(0,212,255,0.22);
            border-radius: 4px;
            color: var(--cyber-accent);
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-enroll:hover { background: rgba(0,212,255,0.14); }

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

        .feature-icon {
            width: 46px;
            height: 46px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 14px;
            font-size: 20px;
            border: 1px solid;
        }

        .fi-cyan   { background: rgba(0,212,255,0.08); border-color: rgba(0,212,255,0.3); color: var(--cyber-accent); }
        .fi-green  { background: rgba(0,255,157,0.08); border-color: rgba(0,255,157,0.3); color: var(--cyber-accent2); }
        .fi-amber  { background: rgba(250,199,117,0.08); border-color: rgba(250,199,117,0.3); color: #fac775; }
        .fi-red    { background: rgba(255,59,92,0.08); border-color: rgba(255,59,92,0.3); color: var(--cyber-danger); }

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

        /* =============================================
           FOOTER
        ============================================= */
        .site-footer {
            position: relative;
            z-index: 5;
            border-top: 1px solid var(--cyber-border);
            padding: 22px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--cyber-surface);
        }

        .footer-copy {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-muted);
        }

        .footer-links {
            display: flex;
            gap: 22px;
        }

        .footer-links a {
            font-size: 11px;
            color: var(--cyber-muted);
            text-decoration: none;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: color 0.2s;
        }

        .footer-links a:hover { color: var(--cyber-accent); }

        /* =============================================
           FLOATING CHATBOT
        ============================================= */
        #cb-container {
            position: fixed;
            bottom: 28px;
            right: 28px;
            z-index: 9998;
            user-select: none;
        }

        #cb-toggle {
            position: relative;
            width: 54px;
            height: 54px;
            background: linear-gradient(135deg, #0f3460, #00d4ff);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: grab;
            box-shadow: 0 4px 20px rgba(0,212,255,0.45);
            transition: box-shadow 0.2s;
            font-size: 22px;
            border: none;
            z-index: 1;
        }

        #cb-toggle:active { cursor: grabbing; }

        #cb-toggle:hover {
            box-shadow: 0 6px 24px rgba(0,212,255,0.65);
        }

        #cb-badge {
            position: absolute;
            top: -3px;
            right: -3px;
            width: 14px;
            height: 14px;
            background: var(--cyber-danger);
            border-radius: 50%;
            border: 2px solid var(--cyber-bg);
            display: none;
        }

        #cb-window {
            position: absolute;
            bottom: 64px;
            right: 0;
            width: 340px;
            height: 460px;
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-top: 2px solid var(--cyber-accent);
            border-radius: 12px;
            box-shadow: 0 12px 40px rgba(0,0,0,0.7);
            display: none;
            flex-direction: column;
            overflow: hidden;
            animation: cb-slide-up 0.25s ease;
        }

        #cb-window.open { display: flex; }

        @keyframes cb-slide-up {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        #cb-head {
            display: flex;
            align-items: center;
            gap: 9px;
            padding: 11px 14px;
            background: var(--cyber-surface);
            border-bottom: 1px solid var(--cyber-border);
            flex-shrink: 0;
        }

        #cb-head .cb-av {
            width: 30px; height: 30px;
            background: rgba(0,212,255,0.1);
            border: 1px solid var(--cyber-accent);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; flex-shrink: 0;
        }

        #cb-head .cb-title { flex: 1; }

        #cb-head .cb-name {
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px;
            font-weight: 700;
            color: var(--cyber-accent);
            letter-spacing: 1px;
        }

        #cb-head .cb-sub {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-muted);
            margin-top: 1px;
        }

        .cb-online {
            width: 8px; height: 8px;
            background: var(--cyber-accent2);
            border-radius: 50%;
            box-shadow: 0 0 6px var(--cyber-accent2);
            animation: pulse 1.5s ease-in-out infinite;
        }

        #cb-close,
        #cb-expand {
            background: none;
            border: none;
            color: var(--cyber-muted);
            font-size: 16px;
            cursor: pointer;
            line-height: 1;
            padding: 0 2px;
            transition: color 0.2s;
        }

        #cb-close:hover  { color: var(--cyber-danger); }
        #cb-expand:hover { color: var(--cyber-accent); }

        #cb-msgs {
            flex: 1;
            overflow-y: auto;
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            background: var(--cyber-card);
        }

        #cb-msgs::-webkit-scrollbar { width: 3px; }
        #cb-msgs::-webkit-scrollbar-thumb { background: var(--cyber-border); border-radius: 3px; }

        .cb-row {
            display: flex;
            gap: 7px;
            align-items: flex-end;
            animation: cb-msg-in 0.2s ease both;
        }

        .cb-row.user { flex-direction: row-reverse; }

        @keyframes cb-msg-in {
            from { opacity: 0; transform: translateY(6px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .cb-row .cb-av {
            width: 24px; height: 24px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; flex-shrink: 0;
        }

        .cb-row.bot  .cb-av { background: rgba(0,212,255,0.1);  border: 1px solid var(--cyber-accent); }
        .cb-row.user .cb-av { background: rgba(0,255,157,0.1);  border: 1px solid var(--cyber-accent2); }

        .cb-bubble {
            max-width: 80%;
            padding: 8px 12px;
            font-size: 13px;
            line-height: 1.55;
            border-radius: 10px;
            word-wrap: break-word;
        }

        .cb-row.bot  .cb-bubble {
            background: var(--cyber-surface);
            border: 1px solid var(--cyber-border);
            border-bottom-left-radius: 3px;
            color: var(--cyber-text);
        }

        .cb-row.user .cb-bubble {
            background: rgba(0,212,255,0.1);
            border: 1px solid rgba(0,212,255,0.25);
            border-bottom-right-radius: 3px;
            color: var(--cyber-heading);
        }

        .cb-dots { display: flex; gap: 4px; padding: 3px 0; align-items: center; }
        .cb-dots span {
            width: 5px; height: 5px;
            background: var(--cyber-accent);
            border-radius: 50%;
            animation: cb-bounce 1s infinite;
        }
        .cb-dots span:nth-child(2) { animation-delay: 0.15s; }
        .cb-dots span:nth-child(3) { animation-delay: 0.30s; }
        @keyframes cb-bounce {
            0%,60%,100% { transform: translateY(0); }
            30%          { transform: translateY(-5px); }
        }

        #cb-foot {
            padding: 10px 12px;
            border-top: 1px solid var(--cyber-border);
            display: flex;
            gap: 8px;
            background: var(--cyber-surface);
            flex-shrink: 0;
        }

        #cb-input {
            flex: 1;
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 6px;
            padding: 8px 11px;
            color: var(--cyber-text);
            font-family: 'Inter', sans-serif;
            font-size: 13px;
            outline: none;
            transition: border-color 0.2s;
        }

        #cb-input:focus { border-color: var(--cyber-accent); }
        #cb-input::placeholder { color: var(--cyber-muted); }

        #cb-send {
            background: var(--cyber-accent);
            color: var(--cyber-bg);
            border: none;
            border-radius: 6px;
            padding: 8px 14px;
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            cursor: pointer;
            transition: background 0.2s;
            text-transform: uppercase;
        }

        #cb-send:hover    { background: #33ddff; }
        #cb-send:disabled { background: var(--cyber-border); color: var(--cyber-muted); cursor: not-allowed; }

        #cb-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            padding: 8px 12px 4px;
            border-top: 1px solid var(--cyber-border);
            background: rgba(0,0,0,0.25);
        }
        .cb-chip {
            background: rgba(0,212,255,0.08);
            border: 1px solid rgba(0,212,255,0.35);
            color: var(--cyber-accent);
            font-family: 'Rajdhani', sans-serif;
            font-size: 11px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 20px;
            cursor: pointer;
            transition: background 0.2s, border-color 0.2s;
            white-space: nowrap;
        }
        .cb-chip:hover {
            background: rgba(0,212,255,0.18);
            border-color: var(--cyber-accent);
        }

        /* =============================================
           LOGOUT CONFIRMATION MODAL
        ============================================= */
        .logout-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 10000;
            background: rgba(8,13,20,0.8);
            backdrop-filter: blur(4px);
            align-items: center;
            justify-content: center;
        }
        .logout-modal-overlay.open { display: flex; }
        .logout-modal {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-top: 2px solid var(--cyber-danger);
            border-radius: 12px;
            padding: 30px 28px 24px;
            width: 90%;
            max-width: 380px;
            text-align: center;
            box-shadow: 0 12px 40px rgba(0,0,0,0.7);
            animation: cb-slide-up 0.25s ease;
        }
        .logout-modal-icon {
            width: 52px; height: 52px;
            margin: 0 auto 16px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 24px;
            color: var(--cyber-danger);
            background: rgba(255,59,92,0.1);
            border: 1px solid rgba(255,59,92,0.4);
        }
        .logout-modal-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 20px; font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 0.5px; margin-bottom: 8px;
        }
        .logout-modal-text {
            font-size: 13px; color: var(--cyber-muted);
            line-height: 1.6; margin-bottom: 22px;
        }
        .logout-modal-actions {
            display: flex; gap: 12px; justify-content: center;
        }
        .logout-modal-actions .btn-ghost,
        .logout-modal-actions .btn-danger {
            min-width: 110px;
        }
    </style>
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
        <nav class="navbar" role="navigation" aria-label="Main navigation">
            <a href="cyberlearnhub_homepage.aspx" class="logo">
                <div class="logo-icon" aria-hidden="true">
                    <i class="ti ti-shield-lock"></i>
                </div>
                CYBER<span class="logo-accent">LEARN</span> HUB
            </a>

            <ul class="nav-links">
                <li><a href="CourseListing.aspx">Courses</a></li>
                <li><a href="About.aspx">About</a></li>
                <asp:PlaceHolder ID="pnlUserNav" runat="server" Visible="false">
                    <li><a href="Dashboard.aspx">Dashboard</a></li>
                    <li><a href="MyCourses.aspx">My Courses</a></li>
                    <li><a href="MyProgress.aspx">Progress</a></li>
                    <li><a href="Leaderboard.aspx">Leaderboard</a></li>
                    <li><a href="Labs.aspx">Labs</a></li>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="pnlAdminNav" runat="server" Visible="false">
                    <li><a href="Admin/Default.aspx" style="color:var(--cyber-accent);">Admin</a></li>
                </asp:PlaceHolder>
            </ul>

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
                <a href="Privacy.aspx">Privacy</a>
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
</body>
</html>
