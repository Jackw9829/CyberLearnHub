<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizResult.aspx.cs"
         Inherits="CyberLearnHub.QuizResult" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Quiz Result — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/quiz-result.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="result-wrap">

        <!-- Score card -->
        <asp:Panel ID="pnlScore" runat="server" />

        <!-- Actions -->
        <div class="result-actions">
            <asp:HyperLink ID="hlRetake" runat="server" CssClass="btn-retake">
                <i class="ti ti-refresh"></i> Retake Quiz
            </asp:HyperLink>
            <asp:HyperLink ID="hlBack" runat="server" CssClass="btn-back">
                <i class="ti ti-arrow-left"></i> Back to Course
            </asp:HyperLink>
        </div>

        <!-- Certificate progress banner -->
        <asp:Panel ID="pnlCertProgress" runat="server" Visible="false">
            <div class="cert-progress-banner">
                <i class="ti ti-lock" style="font-size:15px;"></i>
                <asp:Label ID="lblCertProgress" runat="server" />
            </div>
        </asp:Panel>

        <!-- Certificate download -->
        <asp:Panel ID="pnlCertBtn" runat="server" Visible="false">
            <div style="text-align:center;margin-bottom:28px;">
                <asp:HyperLink ID="hlCert" runat="server"
                    style="display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(0,255,157,0.1);border:1px solid rgba(0,255,157,0.4);color:var(--cyber-accent2);font-family:'Rajdhani',sans-serif;font-size:13px;font-weight:700;letter-spacing:1px;border-radius:6px;text-transform:uppercase;text-decoration:none;">
                    <i class="ti ti-certificate"></i> Download Certificate
                </asp:HyperLink>
            </div>
        </asp:Panel>

        <!-- Per-quiz leaderboard -->
        <asp:Panel ID="pnlLeaderboard" runat="server" Visible="false">
            <div class="review-title" style="margin-top:8px;">// Quiz Leaderboard - Top 5</div>
            <asp:Literal ID="litLeaderboard" runat="server" />
        </asp:Panel>

        <!-- Question review -->
        <div class="review-title">// Answer Review</div>
        <asp:Repeater ID="rptReview" runat="server">
            <ItemTemplate>
                <div class="review-item <%# (bool)Eval("IsCorrect") ? "correct" : "wrong" %>">
                    <div class="review-q-num">
                        Q<%# Container.ItemIndex + 1 %> &mdash; <%# (bool)Eval("IsCorrect") ? "CORRECT" : "INCORRECT" %>
                    </div>
                    <div class="review-q-text"><%# Server.HtmlEncode(Eval("QuestionText") as string) %></div>
                    <div class="review-answer <%# (bool)Eval("IsCorrect") ? "your-correct" : "your-wrong" %>">
                        Your answer: <%# Server.HtmlEncode(Eval("YourAnswer") as string ?? "Not answered") %>
                    </div>
                    <%# !(bool)Eval("IsCorrect") ? "<div class=\"review-answer correct-ans\">Correct answer: " + Server.HtmlEncode(Eval("CorrectText") as string ?? "") + "</div>" : "" %>
                    <%# !string.IsNullOrEmpty(Eval("Explanation") as string) ? "<div class=\"review-explanation\">&gt; " + Server.HtmlEncode(Eval("Explanation") as string) + "</div>" : "" %>
                </div>
            </ItemTemplate>
        </asp:Repeater>

    </div>
</asp:Content>
