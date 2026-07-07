<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs"
         Inherits="CyberLearnHub.Quiz" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Quiz — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/quiz.css") %>" />
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

        <div id="timerPanel" style="display:none;">
            <div class="quiz-timer-wrap">
                <i class="ti ti-clock quiz-timer-icon"></i>
                <span class="quiz-timer-label">TIME REMAINING</span>
                <span id="timerDisplay" class="quiz-timer-display">--:--</span>
            </div>
            <div class="timer-bar-wrap"><div id="timerBar" class="timer-bar" style="width:100%"></div></div>
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

    (function() {
        var limitSeconds = parseInt('<%: ViewState["TimeLimitMinutes"] ?? 0 %>') * 60;
        if (!limitSeconds) return;
        document.getElementById('timerPanel').style.display = 'block';
        var remaining = limitSeconds;
        var display   = document.getElementById('timerDisplay');
        var bar       = document.getElementById('timerBar');
        var submitBtn = document.getElementById('<%= btnSubmit.ClientID %>');
        function tick() {
            if (remaining <= 0) {
                display.textContent = '00:00';
                submitBtn.click();
                return;
            }
            var m = Math.floor(remaining / 60);
            var s = remaining % 60;
            display.textContent = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
            bar.style.width = (remaining / limitSeconds * 100) + '%';
            if (remaining <= 60) display.classList.add('danger');
            remaining--;
            setTimeout(tick, 1000);
        }
        tick();
    })();
</script>
</asp:Content>
