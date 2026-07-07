<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuestionForm.aspx.cs"
         Inherits="CyberLearnHub.Admin.QuestionForm" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Add Question" />
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/admin-question-form.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-card" style="max-width:760px;">

        <asp:Panel ID="pnlAlert" runat="server" Visible="false">
            <asp:Label ID="lblAlert" runat="server" />
        </asp:Panel>

        <!-- Hidden field to track selected type -->
        <asp:HiddenField ID="hdnQuestionType" runat="server" Value="MultipleChoice" />

        <!-- Question Type Selector -->
        <div class="form-group">
            <label class="form-label">Question Type</label>
            <div class="qtype-selector">
                <button type="button" class="qtype-btn active" id="btnTypemc" onclick="setQType('MultipleChoice')">
                    <i class="ti ti-list-check"></i>
                    <span class="qtype-label">Multiple Choice</span>
                    <span class="qtype-desc">4 options, one correct</span>
                </button>
                <button type="button" class="qtype-btn" id="btnTypetf" onclick="setQType('TrueFalse')">
                    <i class="ti ti-toggle-right"></i>
                    <span class="qtype-label">True / False</span>
                    <span class="qtype-desc">Binary correct/incorrect</span>
                </button>
                <button type="button" class="qtype-btn" id="btnTypefb" onclick="setQType('FillBlank')">
                    <i class="ti ti-text-plus"></i>
                    <span class="qtype-label">Fill in the Blank</span>
                    <span class="qtype-desc">Student types the answer</span>
                </button>
            </div>
        </div>

        <!-- Difficulty -->
        <asp:HiddenField ID="hdnDifficulty" runat="server" Value="Medium" />
        <div class="form-group">
            <label class="form-label">Difficulty</label>
            <div class="qtype-selector">
                <button type="button" class="qtype-btn" id="btnDiffEasy" onclick="setDiff('Easy')">
                    <i class="ti ti-plant"></i>
                    <span class="qtype-label">Easy</span>
                    <span class="qtype-desc">+10 XP</span>
                </button>
                <button type="button" class="qtype-btn active" id="btnDiffMedium" onclick="setDiff('Medium')">
                    <i class="ti ti-flame"></i>
                    <span class="qtype-label">Medium</span>
                    <span class="qtype-desc">+20 XP</span>
                </button>
                <button type="button" class="qtype-btn" id="btnDiffHard" onclick="setDiff('Hard')">
                    <i class="ti ti-skull"></i>
                    <span class="qtype-label">Hard</span>
                    <span class="qtype-desc">+30 XP</span>
                </button>
            </div>
        </div>

        <!-- Topic -->
        <div class="form-group">
            <label class="form-label">Topic <span style="color:var(--cyber-muted);font-weight:400;">(optional)</span></label>
            <asp:TextBox ID="txtTopic" runat="server" CssClass="form-control" MaxLength="100"
                placeholder="e.g. Network Security" />
        </div>

        <!-- Question Text (shared across all types) -->
        <div class="form-group">
            <label class="form-label">Question Text *</label>
            <asp:TextBox ID="txtQuestion" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="4" MaxLength="2000"
                placeholder="Enter the question here..." />
            <asp:RequiredFieldValidator ID="rfvQ" runat="server"
                ControlToValidate="txtQuestion" CssClass="form-error"
                ErrorMessage="&gt; Question text is required." Display="Dynamic" />
        </div>

        <!-- ====== MULTIPLE CHOICE SECTION ====== -->
        <div id="sectionMC" class="qtype-section active">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label"><span class="option-badge">A</span> Option A *</label>
                    <asp:TextBox ID="txtA" runat="server" CssClass="form-control" MaxLength="500" />
                </div>
                <div class="form-group">
                    <label class="form-label"><span class="option-badge">B</span> Option B *</label>
                    <asp:TextBox ID="txtB" runat="server" CssClass="form-control" MaxLength="500" />
                </div>
                <div class="form-group">
                    <label class="form-label"><span class="option-badge">C</span> Option C *</label>
                    <asp:TextBox ID="txtC" runat="server" CssClass="form-control" MaxLength="500" />
                </div>
                <div class="form-group">
                    <label class="form-label"><span class="option-badge">D</span> Option D *</label>
                    <asp:TextBox ID="txtD" runat="server" CssClass="form-control" MaxLength="500" />
                </div>
            </div>
            <div class="form-group" style="max-width:220px;">
                <label class="form-label">Correct Answer *</label>
                <asp:DropDownList ID="ddlCorrect" runat="server" CssClass="form-control">
                    <asp:ListItem Value="A">A - Option A</asp:ListItem>
                    <asp:ListItem Value="B">B - Option B</asp:ListItem>
                    <asp:ListItem Value="C">C - Option C</asp:ListItem>
                    <asp:ListItem Value="D">D - Option D</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <!-- ====== TRUE / FALSE SECTION ====== -->
        <div id="sectionTF" class="qtype-section">
            <div class="form-group">
                <label class="form-label">Options (fixed)</label>
                <div class="tf-option-row tf-true">
                    <i class="ti ti-circle-check"></i>
                    <span>True</span>
                </div>
                <div class="tf-option-row tf-false">
                    <i class="ti ti-circle-x"></i>
                    <span>False</span>
                </div>
            </div>
            <div class="form-group" style="max-width:200px;">
                <label class="form-label">Correct Answer *</label>
                <asp:DropDownList ID="ddlTFCorrect" runat="server" CssClass="form-control">
                    <asp:ListItem Value="A">True</asp:ListItem>
                    <asp:ListItem Value="B">False</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <!-- ====== FILL IN THE BLANK SECTION ====== -->
        <div id="sectionFB" class="qtype-section">
            <div class="form-group">
                <label class="form-label">Correct Answer Text *</label>
                <div class="fill-answer-wrap">
                    <asp:TextBox ID="txtFillAnswer" runat="server" CssClass="form-control" MaxLength="300"
                        placeholder="e.g. firewall  (case-insensitive match)" />
                </div>
                <span class="form-hint">Student's answer is matched case-insensitively against this text</span>
            </div>
        </div>

        <!-- Explanation -->
        <div class="form-group" style="margin-top:8px;">
            <label class="form-label">Answer Explanation <span style="color:var(--cyber-muted);font-weight:400;">(optional)</span></label>
            <asp:TextBox ID="txtExplanation" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="3" MaxLength="1000"
                placeholder="Explain why this answer is correct - shown to students after the quiz" />
            <span class="form-hint">&gt; Students see this in the answer review</span>
        </div>

        <div style="display:flex;gap:12px;margin-top:8px;padding-top:16px;border-top:1px solid var(--cyber-border);">
            <asp:Button ID="btnSave" runat="server" Text="Save Question"
                CssClass="btn-admin-primary" OnClick="btnSave_Click" />
            <asp:HyperLink ID="hlBack" runat="server" CssClass="btn-secondary">Cancel</asp:HyperLink>
        </div>
    </div>

<script>
    var currentType = '<%= hdnQuestionType.Value %>';

    function setQType(type) {
        currentType = type;
        document.getElementById('<%= hdnQuestionType.ClientID %>').value = type;

        // Update buttons
        document.querySelectorAll('.qtype-btn').forEach(function(b) { b.classList.remove('active'); });
        var map = { 'MultipleChoice': 'btnTypemc', 'TrueFalse': 'btnTypetf', 'FillBlank': 'btnTypefb' };
        document.getElementById(map[type]).classList.add('active');

        // Show/hide sections
        document.querySelectorAll('.qtype-section').forEach(function(s) { s.classList.remove('active'); });
        var smap = { 'MultipleChoice': 'sectionMC', 'TrueFalse': 'sectionTF', 'FillBlank': 'sectionFB' };
        document.getElementById(smap[type]).classList.add('active');
    }

    // Init on page load
    window.addEventListener('DOMContentLoaded', function() {
        setQType(currentType);
    });

    function setDiff(diff) {
        document.getElementById('<%= hdnDifficulty.ClientID %>').value = diff;
        var map = { 'Easy': 'btnDiffEasy', 'Medium': 'btnDiffMedium', 'Hard': 'btnDiffHard' };
        ['btnDiffEasy','btnDiffMedium','btnDiffHard'].forEach(function(id) {
            document.getElementById(id).classList.remove('active');
        });
        document.getElementById(map[diff]).classList.add('active');
    }
    window.addEventListener('DOMContentLoaded', function() {
        setDiff('<%= hdnDifficulty.Value %>');
    });
</script>
</asp:Content>
