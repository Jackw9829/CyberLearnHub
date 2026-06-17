<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageQuizzes.aspx.cs"
         Inherits="CyberLearnHub.Admin.ManageQuizzes" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Manage Quizzes</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <div style="margin-bottom:16px;">
        <a href="ManageCourses.aspx" class="btn-secondary"><i class="ti ti-arrow-left"></i> Back to Courses</a>
    </div>

    <div class="admin-card">
        <div class="admin-card-title" style="justify-content:space-between;">
            <span><i class="ti ti-help-circle"></i> Quizzes for: <asp:Literal ID="litCourseName" runat="server" /></span>
            <a href='<%= "QuizForm.aspx?courseId=" + Request.QueryString["courseId"] %>' class="btn-admin-primary">
                <i class="ti ti-plus"></i> Add Quiz
            </a>
        </div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div style="text-align:center;padding:40px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:12px;letter-spacing:1px;">
                <i class="ti ti-help-circle-off" style="font-size:36px;display:block;margin-bottom:12px;color:var(--cyber-border);"></i>
                &gt; No quizzes yet.
            </div>
        </asp:Panel>

        <asp:Repeater ID="rptQuizzes" runat="server">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>Title</th>
                    <th>Description</th>
                    <th>Passing Score</th>
                    <th>Questions</th>
                    <th>Actions</th>
                </tr></thead>
                <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="color:var(--cyber-heading);font-weight:500;"><%# Server.HtmlEncode(Eval("Title") as string) %></td>
                    <td style="color:var(--cyber-muted);font-size:12px;max-width:260px;"><%# Server.HtmlEncode(Eval("Description") as string ?? "—") %></td>
                    <td><span class="badge badge-pub"><%# Eval("PassingScore") %>%</span></td>
                    <td style="color:var(--cyber-muted);"><%# Eval("QuestionCount") %></td>
                    <td>
                        <div style="display:flex;gap:6px;flex-wrap:wrap;">
                            <a href='QuizForm.aspx?id=<%# Eval("QuizID") %>&courseId=<%# Eval("CourseID") %>' class="btn-admin-sm btn-edit"><i class="ti ti-pencil"></i> Edit</a>
                            <a href='ManageQuestions.aspx?courseId=<%# Eval("CourseID") %>&quizId=<%# Eval("QuizID") %>' class="btn-admin-sm btn-view"><i class="ti ti-list"></i> Questions</a>
                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandArgument='<%# Eval("QuizID") %>'
                                OnClick="lbDelete_Click"
                                CssClass="btn-admin-sm btn-delete"
                                OnClientClick="return confirm('Delete this quiz and all its questions?');">
                                <i class="ti ti-trash"></i> Delete
                            </asp:LinkButton>
                        </div>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
    </div>

</asp:Content>
