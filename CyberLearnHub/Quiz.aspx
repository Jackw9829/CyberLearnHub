<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs"
         Inherits="CyberLearnHub.Quiz" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Quiz — CyberLearn Hub</title>
    <style>
        .quiz-wrap { max-width:800px; margin:0 auto; padding:40px 24px 60px; }
        .quiz-header { margin-bottom:28px; }
        .quiz-course-name {
            font-family:'Share Tech Mono',monospace; font-size:11px;
            color:var(--cyber-accent); letter-spacing:2px; text-transform:uppercase; margin-bottom:8px;
        }
        .quiz-title { font-family:'Rajdhani',sans-serif; font-size:28px; font-weight:700; color:var(--cyber-heading); }

        .quiz-progress-wrap {
            background:var(--cyber-border); border-radius:4px; height:4px;
            margin:16px 0 28px; overflow:hidden;
        }
        .quiz-progress-bar {
            height:100%;
            background:linear-gradient(90deg, var(--cyber-accent), var(--cyber-accent2));
            border-radius:4px; transition:width 0.3s;
        }
        .quiz-progress-label {
            font-family:'Share Tech Mono',monospace; font-size:11px;
            color:var(--cyber-muted); letter-spacing:1px;
            text-align:right; margin-top:-22px; margin-bottom:28px;
        }

        .question-card {
            background:var(--cyber-card); border:1px solid var(--cyber-border);
            border-radius:10px; padding:24px; margin-bottom:16px;
            transition:border-color 0.2s;
        }
        .question-card:hover { border-color:rgba(0,212,255,0.3); }
        .question-number {
            font-family:'Share Tech Mono',monospace; font-size:10px;
            color:var(--cyber-accent); letter-spacing:2px; margin-bottom:6px;
            display:flex; align-items:center; gap:10px;
        }
        .qtype-pill {
            font-family:'Share Tech Mono',monospace; font-size:9px;
            padding:2px 8px; border-radius:20px; letter-spacing:1px; text-transform:uppercase;
        }
        .qtype-mcq  { background:rgba(0,212,255,0.1);  color:var(--cyber-accent);  border:1px solid rgba(0,212,255,0.2); }
        .qtype-tf   { background:rgba(0,255,157,0.1);  color:var(--cyber-accent2); border:1px solid rgba(0,255,157,0.2); }
        .qtype-fill { background:rgba(250,199,117,0.1);color:var(--cyber-amber);   border:1px solid rgba(250,199,117,0.2);}

        .question-text { font-size:15px; color:var(--cyber-heading); font-weight:500; margin-bottom:18px; line-height:1.6; }
        .option-list { display:flex; flex-direction:column; gap:10px; }
        .option-label {
            display:flex; align-items:center; gap:12px;
            padding:10px 14px; border:1px solid var(--cyber-border);
            border-radius:6px; cursor:pointer;
            transition:border-color 0.2s, background 0.2s;
            font-size:14px; color:var(--cyber-text);
        }
        .option-label:hover { border-color:var(--cyber-accent); background:rgba(0,212,255,0.05); }
        .option-label input[type="radio"] { accent-color:var(--cyber-accent); width:16px; height:16px; flex-shrink:0; }

        /* True/False special styling */
        .tf-true-label:hover  { border-color:var(--cyber-accent2); background:rgba(0,255,157,0.05); }
        .tf-false-label:hover { border-color:var(--cyber-danger);  background:rgba(255,59,92,0.05); }

        /* Fill in the blank */
        .fill-input-wrap { display:flex; flex-direction:column; gap:6px; }
        .quiz-fill-input {
            width:100%; background:rgba(8,13,20,0.6);
            border:1px solid var(--cyber-border); border-radius:6px;
            padding:11px 14px; color:var(--cyber-text);
            font-family:'Inter',sans-serif; font-size:14px;
            outline:none; transition:border-color 0.2s, box-shadow 0.2s;
            box-sizing:border-box;
        }
        .quiz-fill-input:focus { border-color:var(--cyber-amber); box-shadow:0 0 0 3px rgba(250,199,117,0.1); }
        .fill-hint {
            font-family:'Share Tech Mono',monospace; font-size:10px;
            color:var(--cyber-muted); letter-spacing:0.5px;
        }

        .quiz-actions { margin-top:28px; text-align:center; }
        .btn-submit-quiz {
            padding:13px 40px; background:var(--cyber-accent);
            color:#080d14; border:none;
            font-family:'Rajdhani',sans-serif; font-size:15px;
            font-weight:700; letter-spacing:1.5px;
            border-radius:6px; cursor:pointer; text-transform:uppercase;
            transition:background 0.2s;
        }
        .btn-submit-quiz:hover { background:#33ddff; }

        .quiz-alert {
            padding:12px 16px; background:rgba(255,59,92,0.08);
            border:1px solid rgba(255,59,92,0.3); color:var(--cyber-danger);
            border-radius:6px; font-size:13px; margin-bottom:20px;
            font-family:'Share Tech Mono',monospace; letter-spacing:0.5px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="quiz-wrap">

        <div class="quiz-header">
            <div class="quiz-course-name"><asp:Label ID="lblCourseName" runat="server" /></div>
            <div class="quiz-title">// Course Quiz</div>
        </div>

        <div class="quiz-progress-wrap">
            <div class="quiz-progress-bar" id="quizProgressBar" style="width:100%"></div>
        </div>
        <div class="quiz-progress-label">
            <asp:Label ID="lblProgress" runat="server" />
        </div>

        <asp:Panel ID="pnlAlert" runat="server" Visible="false">
            <div class="quiz-alert"><asp:Label ID="lblAlert" runat="server" /></div>
        </asp:Panel>

        <asp:Panel ID="pnlQuiz" runat="server">
            <asp:Repeater ID="rptQuestions" runat="server">
                <ItemTemplate>
                    <div class="question-card">
                        <div class="question-number">
                            Q<%# Container.ItemIndex + 1 %>
                            <%# GetTypePill(Eval("QuestionType") as string) %>
                        </div>
                        <div class="question-text"><%# Server.HtmlEncode(Eval("QuestionText") as string) %></div>

                        <%-- Multiple Choice --%>
                        <div class="option-list" style='<%# (string)Eval("QuestionType") != "MultipleChoice" ? "display:none" : "" %>'>
                            <label class="option-label">
                                <input type="radio" name="q_<%# Eval("QuestionID") %>" value="A" />
                                <span>A. <%# Server.HtmlEncode(Eval("OptionA") as string) %></span>
                            </label>
                            <label class="option-label">
                                <input type="radio" name="q_<%# Eval("QuestionID") %>" value="B" />
                                <span>B. <%# Server.HtmlEncode(Eval("OptionB") as string) %></span>
                            </label>
                            <label class="option-label">
                                <input type="radio" name="q_<%# Eval("QuestionID") %>" value="C" />
                                <span>C. <%# Server.HtmlEncode(Eval("OptionC") as string) %></span>
                            </label>
                            <label class="option-label">
                                <input type="radio" name="q_<%# Eval("QuestionID") %>" value="D" />
                                <span>D. <%# Server.HtmlEncode(Eval("OptionD") as string) %></span>
                            </label>
                        </div>

                        <%-- True / False --%>
                        <div class="option-list" style='<%# (string)Eval("QuestionType") != "TrueFalse" ? "display:none" : "" %>'>
                            <label class="option-label tf-true-label">
                                <input type="radio" name="q_<%# Eval("QuestionID") %>" value="A" />
                                <span style="color:var(--cyber-accent2);">&#10003; True</span>
                            </label>
                            <label class="option-label tf-false-label">
                                <input type="radio" name="q_<%# Eval("QuestionID") %>" value="B" />
                                <span style="color:var(--cyber-danger);">&#10007; False</span>
                            </label>
                        </div>

                        <%-- Fill in the Blank --%>
                        <div class="fill-input-wrap" style='<%# (string)Eval("QuestionType") != "FillBlank" ? "display:none" : "" %>'>
                            <input type="text" name="fb_<%# Eval("QuestionID") %>"
                                   class="quiz-fill-input"
                                   placeholder="Type your answer here..."
                                   autocomplete="off" />
                            <span class="fill-hint">&gt; Case-insensitive — spelling counts</span>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <div class="quiz-actions">
                <asp:Button ID="btnSubmit" runat="server" Text="Submit Quiz"
                    CssClass="btn-submit-quiz" OnClick="btnSubmit_Click"
                    OnClientClick="return confirmSubmit();" />
            </div>
        </asp:Panel>
    </div>

<script type="text/javascript">
    function confirmSubmit() {
        var answered = 0, total = 0;
        // Count radio groups answered
        var radioGroups = {};
        document.querySelectorAll('.option-list:not([style*="display:none"]) input[type="radio"]').forEach(function(r) {
            if (!radioGroups[r.name]) radioGroups[r.name] = false;
            if (r.checked) radioGroups[r.name] = true;
        });
        Object.values(radioGroups).forEach(function(v) { total++; if (v) answered++; });

        // Count fill-in inputs answered
        document.querySelectorAll('.fill-input-wrap:not([style*="display:none"]) .quiz-fill-input').forEach(function(inp) {
            total++;
            if (inp.value.trim()) answered++;
        });

        if (answered < total) {
            return confirm('You have ' + (total - answered) + ' unanswered question(s). Submit anyway?');
        }
        return true;
    }
</script>
</asp:Content>
