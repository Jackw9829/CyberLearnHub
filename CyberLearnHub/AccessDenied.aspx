<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs"
         Inherits="CyberLearnHub.AccessDenied" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Access Denied — CyberLearn Hub</title>
    <style>
        .error-wrapper {
            min-height: calc(100vh - 120px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }

        .error-card {
            width: 100%;
            max-width: 520px;
            background: var(--cyber-card);
            border: 1px solid rgba(255,59,92,0.35);
            border-radius: 10px;
            padding: 48px 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .error-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: var(--cyber-danger);
        }

        .error-code {
            font-family: 'Share Tech Mono', monospace;
            font-size: 72px;
            color: rgba(255,59,92,0.15);
            line-height: 1;
            margin-bottom: 8px;
            letter-spacing: -2px;
        }

        .error-icon {
            width: 60px;
            height: 60px;
            background: rgba(255,59,92,0.08);
            border: 1px solid rgba(255,59,92,0.3);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 28px;
            color: var(--cyber-danger);
        }

        .error-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 28px;
            font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 0.5px;
            margin-bottom: 10px;
        }

        .error-msg {
            font-size: 14px;
            line-height: 1.75;
            color: var(--cyber-muted);
            margin-bottom: 32px;
        }

        .error-tag {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-danger);
            letter-spacing: 1.5px;
            margin-bottom: 32px;
            display: block;
        }

        .btn-row {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn-home,
        input[type="submit"].btn-home {
            padding: 11px 28px;
            background: var(--cyber-accent);
            border: none;
            color: #080d14;
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1.5px;
            border-radius: 5px;
            cursor: pointer;
            text-transform: uppercase;
            transition: background 0.2s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-home:hover { background: #33ddff; }

        .btn-login-link {
            padding: 11px 28px;
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
            text-decoration: none;
            display: inline-block;
        }

        .btn-login-link:hover { border-color: var(--cyber-accent); color: var(--cyber-accent); }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="error-wrapper">
        <div class="error-card">

            <div class="error-code" aria-hidden="true">403</div>

            <div class="error-icon" aria-hidden="true">
                <i class="ti ti-lock-x"></i>
            </div>

            <div class="error-title">Access Denied</div>

            <span class="error-tag">&gt; authorisation_failed // insufficient_privileges</span>

            <p class="error-msg">
                You do not have permission to view this page.<br />
                Please log in with an account that has the required access level,
                or return to the homepage.
            </p>

            <div class="btn-row">
                <a href="~/cyberlearnhub_homepage.aspx" runat="server" class="btn-home">
                    <i class="ti ti-home" style="margin-right:6px;"></i> Go Home
                </a>
                <a href="~/Login.aspx" runat="server" class="btn-login-link">
                    <i class="ti ti-lock" style="margin-right:6px;"></i> Log In
                </a>
            </div>

        </div>
    </div>

</asp:Content>
