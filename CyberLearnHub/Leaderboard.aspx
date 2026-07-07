<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leaderboard.aspx.cs"
         Inherits="CyberLearnHub.Leaderboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Leaderboard — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/leaderboard.css") %>" />
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
