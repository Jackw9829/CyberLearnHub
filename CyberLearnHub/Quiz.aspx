<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs"
         Inherits="CyberLearnHub.Quiz" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Quiz — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/quiz.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="quiz-wrap">

        <%-- Quiz selection panel — shown when a course has multiple quizzes --%>
        <asp:Panel ID="pnlQuizSelect" runat="server" Visible="false">
            <div class="quiz-header">
                <div class="quiz-course-name"><asp:Label ID="lblSelectCourseName" runat="server" /></div>
                <div class="quiz-title">// Select a Quiz</div>
            </div>
            <div class="quiz-select-list">
                <asp:Repeater ID="rptQuizzes" runat="server">
                    <ItemTemplate>
                        <a href='<%# "Quiz.aspx?courseId=" + Eval("CourseID") + "&quizId=" + Eval("QuizID") %>'
                           class="quiz-select-card">
                            <div class="quiz-select-title"><%# Server.HtmlEncode(Eval("Title") as string) %></div>
                            <div class="quiz-select-meta">
                                <span><%# Eval("QuestionCount") %> questions</span>
                                &nbsp;&bull;&nbsp;
                                <span>Passing: <%# Eval("PassingScore") %>%</span>
                                <%# (int)Eval("TimeLimitMinutes") > 0 ? "&nbsp;&bull;&nbsp;<span>" + Eval("TimeLimitMinutes") + " min</span>" : "" %>
                            </div>
                            <div class="quiz-select-arrow"><i class="ti ti-arrow-right"></i></div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlQuizMain" runat="server">

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
        </asp:Panel><%-- /pnlQuizMain --%>
    </div>

    <%-- Custom submit confirmation modal --%>
    <div id="quizConfirmModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.75);z-index:3000;align-items:center;justify-content:center;">
        <div style="background:#0d1520;border:1px solid #1a3050;border-radius:12px;padding:32px 28px 24px;width:100%;max-width:420px;box-shadow:0 8px 40px rgba(0,0,0,0.7);margin:0 16px;">
            <div style="display:flex;align-items:center;gap:14px;margin-bottom:16px;">
                <div style="width:44px;height:44px;border-radius:50%;background:rgba(250,199,117,0.12);display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                    <i class="ti ti-alert-triangle" style="font-size:22px;color:#fac777;"></i>
                </div>
                <h3 style="font-family:'Rajdhani',sans-serif;font-size:20px;font-weight:700;color:#e8f4ff;margin:0;">Unanswered Questions</h3>
            </div>
            <p id="quizConfirmMsg" style="font-size:14px;color:#5a7a99;line-height:1.6;margin:0 0 24px;padding-left:58px;font-family:'Share Tech Mono',monospace;"></p>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <button type="button" id="quizConfirmCancel"
                    style="padding:10px 22px;border-radius:7px;border:1px solid #1a3050;background:transparent;color:#5a7a99;font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:600;cursor:pointer;letter-spacing:.5px;transition:all .2s;">
                    KEEP ANSWERING
                </button>
                <button type="button" id="quizConfirmOk"
                    style="padding:10px 22px;border-radius:7px;border:none;background:var(--cyber-accent,#00d4ff);color:#080d14;font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;cursor:pointer;letter-spacing:.5px;transition:all .2s;">
                    SUBMIT ANYWAY
                </button>
            </div>
        </div>
    </div>

<script type="text/javascript">
    var _quizSubmitConfirmed = false;

    function confirmSubmit() {
        if (_quizSubmitConfirmed) { _quizSubmitConfirmed = false; return true; }

        var answered = 0, total = 0;
        var radioGroups = {};
        document.querySelectorAll('.option-list:not([style*="display:none"]) input[type="radio"]').forEach(function(r) {
            if (!radioGroups[r.name]) radioGroups[r.name] = false;
            if (r.checked) radioGroups[r.name] = true;
        });
        Object.values(radioGroups).forEach(function(v) { total++; if (v) answered++; });
        document.querySelectorAll('.fill-input-wrap:not([style*="display:none"]) .quiz-fill-input').forEach(function(inp) {
            total++;
            if (inp.value.trim()) answered++;
        });

        if (answered < total) {
            var unanswered = total - answered;
            document.getElementById('quizConfirmMsg').textContent =
                'You have ' + unanswered + ' unanswered question' + (unanswered > 1 ? 's' : '') + '. Are you sure you want to submit?';
            document.getElementById('quizConfirmModal').style.display = 'flex';
            return false; // block the postback
        }
        return true;
    }

    document.getElementById('quizConfirmOk').addEventListener('click', function() {
        document.getElementById('quizConfirmModal').style.display = 'none';
        _quizSubmitConfirmed = true;
        document.getElementById('<%= btnSubmit.ClientID %>').click();
    });
    document.getElementById('quizConfirmCancel').addEventListener('click', function() {
        document.getElementById('quizConfirmModal').style.display = 'none';
    });
    document.getElementById('quizConfirmModal').addEventListener('click', function(e) {
        if (e.target === this) this.style.display = 'none';
    });

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
                _quizSubmitConfirmed = true; // bypass confirmation modal on timeout
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
