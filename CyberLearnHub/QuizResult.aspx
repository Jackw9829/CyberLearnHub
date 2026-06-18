<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizResult.aspx.cs"
         Inherits="CyberLearnHub.QuizResult" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Quiz Result — CyberLearn Hub</title>
    <style>
        .result-wrap {
            max-width: 760px;
            margin: 0 auto;
            padding: 40px 24px 60px;
        }

        /* Score card */
        .score-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 12px;
            padding: 36px;
            text-align: center;
            margin-bottom: 36px;
            position: relative;
            overflow: hidden;
        }
        .score-card.passed  { border-color: rgba(0,255,157,0.4); }
        .score-card.failed  { border-color: rgba(255,59,92,0.4); }
        .score-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
        }
        .score-card.passed::before { background: linear-gradient(90deg, var(--cyber-accent2), var(--cyber-accent)); }
        .score-card.failed::before { background: linear-gradient(90deg, var(--cyber-danger), #ff8a5c); }

        .score-icon { font-size: 52px; margin-bottom: 12px; }
        .score-card.passed .score-icon { color: var(--cyber-accent2); }
        .score-card.failed .score-icon { color: var(--cyber-danger); }
        .score-label {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            letter-spacing: 3px;
            text-transform: uppercase;
            margin-bottom: 8px;
        }
        .score-card.passed .score-label { color: var(--cyber-accent2); }
        .score-card.failed .score-label { color: var(--cyber-danger); }
        .score-number {
            font-family: 'Rajdhani', sans-serif;
            font-size: 56px;
            font-weight: 700;
            color: var(--cyber-heading);
            line-height: 1;
            margin-bottom: 6px;
        }
        .score-total {
            font-size: 16px;
            color: var(--cyber-muted);
            margin-bottom: 16px;
        }
        .score-course {
            font-size: 13px;
            color: var(--cyber-muted);
            font-family: 'Share Tech Mono', monospace;
            letter-spacing: 1px;
        }

        /* Action buttons */
        .result-actions {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 36px;
        }
        .btn-retake {
            padding: 10px 24px;
            background: var(--cyber-accent);
            color: #080d14;
            border: none;
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            border-radius: 6px;
            cursor: pointer;
            text-transform: uppercase;
            text-decoration: none;
            transition: background 0.2s;
        }
        .btn-retake:hover { background: #33ddff; color: #080d14; }
        .btn-back {
            padding: 10px 24px;
            background: transparent;
            color: var(--cyber-muted);
            border: 1px solid var(--cyber-border);
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            border-radius: 6px;
            cursor: pointer;
            text-transform: uppercase;
            text-decoration: none;
            transition: color 0.2s, border-color 0.2s;
        }
        .btn-back:hover { color: var(--cyber-text); border-color: var(--cyber-text); }

        /* Review section */
        .review-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 18px;
            font-weight: 700;
            color: var(--cyber-heading);
            margin-bottom: 16px;
            letter-spacing: 0.5px;
        }
        .review-item {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 16px 20px;
            margin-bottom: 12px;
        }
        .review-item.correct { border-left: 3px solid var(--cyber-accent2); }
        .review-item.wrong   { border-left: 3px solid var(--cyber-danger); }
        .review-q-num {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            letter-spacing: 2px;
            margin-bottom: 6px;
        }
        .review-item.correct .review-q-num { color: var(--cyber-accent2); }
        .review-item.wrong   .review-q-num { color: var(--cyber-danger); }
        .review-q-text { font-size: 14px; color: var(--cyber-heading); margin-bottom: 10px; line-height: 1.5; }
        .review-answer { font-size: 12px; font-family: 'Share Tech Mono', monospace; letter-spacing: 0.5px; }
        .review-answer.your-correct { color: var(--cyber-accent2); }
        .review-answer.your-wrong   { color: var(--cyber-danger); }
        .review-answer.correct-ans  { color: var(--cyber-accent); margin-top: 4px; }
        .review-explanation {
            margin-top: 8px; padding: 8px 12px;
            background: rgba(250,199,117,0.06);
            border-left: 3px solid var(--cyber-amber);
            font-size: 12px; color: var(--cyber-amber);
            font-family: 'Share Tech Mono', monospace;
            letter-spacing: 0.5px; line-height: 1.6;
        }
    </style>
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
            <div class="review-title" style="margin-top:8px;">// Quiz Leaderboard — Top 5</div>
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
