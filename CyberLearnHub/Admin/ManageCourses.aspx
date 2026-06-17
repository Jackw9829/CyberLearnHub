<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageCourses.aspx.cs"
         Inherits="CyberLearnHub.Admin.ManageCourses" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Manage Courses</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Label ID="lblAlert" runat="server" />
    </asp:Panel>

    <div class="admin-card">
        <div class="admin-card-title" style="justify-content:space-between;">
            <span><i class="ti ti-book"></i> All Courses</span>
            <a href="CourseForm.aspx" class="btn-admin-primary"><i class="ti ti-plus"></i> Add Course</a>
        </div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div style="text-align:center;padding:40px;color:var(--cyber-muted);font-family:'Share Tech Mono',monospace;font-size:12px;letter-spacing:1px;">
                <i class="ti ti-book-off" style="font-size:36px;display:block;margin-bottom:12px;color:var(--cyber-border);"></i>
                &gt; No courses yet. <a href="CourseForm.aspx" style="color:var(--cyber-accent);">Add one &rarr;</a>
            </div>
        </asp:Panel>

        <asp:Repeater ID="rptCourses" runat="server">
            <HeaderTemplate>
                <table class="admin-table">
                <thead><tr>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Difficulty</th>
                    <th>Status</th>
                    <th>Enrolled</th>
                    <th>Actions</th>
                </tr></thead>
                <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td style="color:var(--cyber-heading);font-weight:500;"><%# Server.HtmlEncode(Eval("Title") as string) %></td>
                    <td style="color:var(--cyber-muted);font-size:12px;"><%# Server.HtmlEncode(Eval("Category") as string ?? "—") %></td>
                    <td style="font-size:12px;"><%# Server.HtmlEncode(Eval("Difficulty") as string ?? "—") %></td>
                    <td>
                        <%# Convert.ToBoolean(Eval("IsPublished"))
                            ? "<span class=\"badge badge-pub\">Published</span>"
                            : "<span class=\"badge badge-draft\">Draft</span>" %>
                    </td>
                    <td style="color:var(--cyber-muted);font-size:12px;"><%# Eval("EnrollCount") %></td>
                    <td>
                        <div style="display:flex;gap:6px;flex-wrap:wrap;">
                            <a href='CourseForm.aspx?id=<%# Eval("CourseID") %>' class="btn-admin-sm btn-edit"><i class="ti ti-pencil"></i> Edit</a>
                            <a href='ManageQuizzes.aspx?courseId=<%# Eval("CourseID") %>' class="btn-admin-sm btn-view"><i class="ti ti-help-circle"></i> Quizzes</a>
                            <a href='ManageLearningMaterials.aspx?courseId=<%# Eval("CourseID") %>' class="btn-admin-sm btn-view" style="color:var(--cyber-amber);border-color:rgba(250,199,117,0.4);background:rgba(250,199,117,0.06);"><i class="ti ti-file-text"></i> Materials</a>
                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandArgument='<%# Eval("CourseID") %>'
                                OnClick="lbDelete_Click"
                                CssClass="btn-admin-sm btn-delete"
                                OnClientClick="return confirm('Delete this course? This cannot be undone.');">
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
