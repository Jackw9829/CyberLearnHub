<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leaderboard.aspx.cs"
         Inherits="CyberLearnHub.Leaderboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Leaderboard — CyberLearn Hub</title>
    <style>
        .lb-wrap { max-width: 860px; margin: 0 auto; padding: 40px 24px 60px; }
        .lb-header { margin-bottom: 28px; }
        .lb-tag { font-family:'Share Tech Mono',monospace; font-size:11px; color:var(--cyber-accent); letter-spacing:3px; margin-bottom:6px; }
        .lb-title { font-family:'Rajdhani',sans-serif; font-size:32px; font-weight:700; color:var(--cyber-heading); }
        .lb-table { width:100%; border-collapse:collapse; }
        .lb-table th { font-family:'Share Tech Mono',monospace; font-size:10px; color:var(--cyber-muted); letter-spacing:1.5px; text-transform:uppercase; padding:0 16px 10px; text-align:left; border-bottom:1px solid var(--cyber-border); }
        .lb-table td { padding:12px 16px; font-size:13px; color:var(--cyber-text); border-bottom:1px solid rgba(26,48,80,0.5); }
        .lb-table tr:hover td { background:rgba(0,212,255,0.03); }
        .lb-table tr.me td { background:rgba(0,212,255,0.06); }
        .rank-1 td:first-child { color:#ffd700; font-weight:700; }
        .rank-2 td:first-child { color:#c0c0c0; font-weight:700; }
        .rank-3 td:first-child { color:#cd7f32; font-weight:700; }
        .level-badge { font-family:'Share Tech Mono',monospace; font-size:9px; padding:2px 8px; border-radius:20px; background:rgba(0,212,255,0.1); color:var(--cyber-accent); border:1px solid rgba(0,212,255,0.2); }
        .xp-val { font-family:'Rajdhani',sans-serif; font-size:15px; font-weight:700; color:var(--cyber-amber); }
        .streak-val { color:var(--cyber-danger); font-family:'Share Tech Mono',monospace; font-size:11px; }
        .lb-divider { border:none; border-top:1px dashed var(--cyber-border); margin:4px 0; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="lb-wrap">
        <div class="lb-header">
            <div class="lb-tag">// global</div>
            <div class="lb-title">XP Leaderboard</div>
        </div>
        <table class="lb-table">
            <thead>
                <tr><th>#</th><th>Student</th><th>Level</th><th>XP</th><th>Streak</th></tr>
            </thead>
            <tbody>
                <asp:Literal ID="litRows" runat="server" />
            </tbody>
        </table>
    </div>
</asp:Content>
