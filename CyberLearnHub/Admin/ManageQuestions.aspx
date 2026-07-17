<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageQuestions.aspx.cs"
         Inherits="CyberLearnHub.Admin.ManageQuestions" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Questions -
    <asp:Literal ID="litCourseName" runat="server" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <div class="admin-card">
        <div class="admin-card-title" style="justify-content:space-between;">
            <span><i class="ti ti-help-circle"></i> Questions</span>
            <div style="display:flex;gap:8px;">
                <a href='<%= "QuestionForm.aspx?courseId=" + Request.QueryString["courseId"] + "&quizId=" + Request.QueryString["quizId"] %>' class="btn-admin-primary">
                    <i class="ti ti-plus"></i> Add Question
                </a>
                <a href="ManageCourses.aspx" class="btn-secondary"><i class="ti ti-arrow-left"></i> Back</a>
            </div>
        </div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div style="text-align:center;padding:40px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:12px;letter-spacing:1px;">
                <i class="ti ti-question-mark" style="font-size:36px;display:block;margin-bottom:12px;color:var(--cyber-border);"></i>
                &gt; No questions yet for this course.
            </div>
        </asp:Panel>

        <asp:Repeater ID="rptQuestions" runat="server">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>#</th>
                    <th>Type</th>
                    <th>Difficulty</th>
                    <th>Topic</th>
                    <th>Question</th>
                    <th>Answer</th>
                    <th>Actions</th>
                </tr></thead>
                <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:11px;"><%# Container.ItemIndex + 1 %></td>
                    <td>
                        <%# GetTypeBadge(Eval("QuestionType") as string) %>
                    </td>
                    <td><%# GetDiffBadge(Eval("Difficulty") as string) %></td>
                    <td style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);">
                        <%# Server.HtmlEncode(Eval("Topic") as string ?? "") %>
                    </td>
                    <td style="max-width:360px;color:var(--cyber-text);"><%# Server.HtmlEncode(Eval("QuestionText") as string) %></td>
                    <td>
                        <span style="font-family:'Share Tech Mono',monospace;font-size:12px;color:var(--cyber-accent2);">
                            <%# GetAnswerDisplay(Eval("QuestionType") as string, Eval("CorrectOption") as string, Eval("OptionA") as string) %>
                        </span>
                    </td>
                    <td>
                        <div style="display:flex;gap:6px;">
                            <a href='QuestionForm.aspx?id=<%# Eval("QuestionID") %>&courseId=<%# Eval("CourseID") %>&quizId=<%= Request.QueryString["quizId"] %>' class="btn-admin-sm btn-edit">
                                <i class="ti ti-pencil"></i> Edit
                            </a>
                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandArgument='<%# Eval("QuestionID") %>'
                                OnClick="lbDelete_Click"
                                CssClass="btn-admin-sm btn-delete"
                                OnClientClick="return confirm('Delete this question?');">
                                <i class="ti ti-trash"></i>
                            </asp:LinkButton>
                        </div>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
    </div>

</asp:Content>
