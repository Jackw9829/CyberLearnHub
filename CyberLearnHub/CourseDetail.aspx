<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseDetail.aspx.cs"
         Inherits="CyberLearnHub.CourseDetail" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title><asp:Literal ID="litPageTitle" runat="server" /> — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/course-detail.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="detail-wrap">

        <div class="breadcrumb">
            <a href="CourseListing.aspx">Courses</a>
            <span>/</span>
            <asp:Label ID="lblBreadcrumb" runat="server" />
        </div>

        <div class="detail-grid">

            <!-- Main column -->
            <div>
                <div class="detail-thumb">
                    <asp:Literal ID="litThumb" runat="server" />
                </div>
                <div class="detail-badges">
                    <asp:Literal ID="litBadges" runat="server" />
                </div>
                <div class="detail-title">
                    <asp:Label ID="lblTitle" runat="server" />
                </div>
                <div class="detail-desc">
                    <asp:Label ID="lblDescription" runat="server" />
                </div>

                <!-- ===== LEARNING MATERIALS (enrolled users only) ===== -->
                <asp:Panel ID="pnlMaterials" runat="server" Visible="false">
                    <div class="content-section">
                        <div class="content-section-title">
                            <i class="ti ti-books"></i> Course Content
                        </div>

                        <asp:Panel ID="pnlNoMaterials" runat="server" Visible="false">
                            <div class="no-materials">
                                <i class="ti ti-file-off" style="font-size:28px;display:block;margin-bottom:8px;opacity:0.3;"></i>
                                No learning materials added yet.
                            </div>
                        </asp:Panel>

                        <asp:Repeater ID="rptMaterials" runat="server">
                            <ItemTemplate>
                                <div class="material-card" id="mat_<%# Eval("MaterialID") %>">
                                    <div class="material-header" onclick="toggleMaterial('mat_<%# Eval("MaterialID") %>')">
                                        <div class="material-type-icon <%# GetTypeIconClass(Eval("MaterialType") as string) %>">
                                            <i class="<%# GetTypeIcon(Eval("MaterialType") as string) %>"></i>
                                        </div>
                                        <div class="material-meta">
                                            <div class="material-title"><%# Server.HtmlEncode(Eval("Title") as string) %></div>
                                            <div class="material-type-label"><%# Eval("MaterialType") %></div>
                                        </div>
                                        <i class="ti ti-chevron-right material-chevron"></i>
                                    </div>
                                    <div class="material-body">
                                        <%# RenderMaterialBody(
                                                Eval("MaterialType") as string,
                                                Eval("FilePath") as string,
                                                Eval("Content") as string,
                                                Eval("Title") as string) %>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
            </div>

            <!-- Sidebar -->
            <div>
                <div class="sidebar-card">

                    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
                        <asp:Label ID="lblAlert" runat="server" />
                    </asp:Panel>

                    <div class="sidebar-stat">
                        <span class="sidebar-stat-label">Category</span>
                        <span class="sidebar-stat-val"><asp:Label ID="lblCategory" runat="server" Text="N/A" /></span>
                    </div>
                    <div class="sidebar-stat">
                        <span class="sidebar-stat-label">Difficulty</span>
                        <span class="sidebar-stat-val"><asp:Label ID="lblDifficulty" runat="server" Text="N/A" /></span>
                    </div>
                    <div class="sidebar-stat">
                        <span class="sidebar-stat-label">Enrolled</span>
                        <span class="sidebar-stat-val"><asp:Label ID="lblEnrolCount" runat="server" Text="0" /> students</span>
                    </div>
                    <div class="sidebar-stat">
                        <span class="sidebar-stat-label">Materials</span>
                        <span class="sidebar-stat-val"><asp:Label ID="lblMatCount" runat="server" Text="0" /></span>
                    </div>

                    <div class="enrol-section">

                        <%-- Guest --%>
                        <asp:Panel ID="pnlGuest" runat="server" Visible="false">
                            <a href='<%= ResolveUrl("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl)) %>'
                               class="btn-enrol">
                                <i class="ti ti-lock"></i> Login to Enrol
                            </a>
                            <div class="enrol-note">
                                <a href="Register.aspx">Don't have an account? Register free</a>
                            </div>
                        </asp:Panel>

                        <%-- Not enrolled --%>
                        <asp:Panel ID="pnlEnrolBtn" runat="server" Visible="false">
                            <asp:Button ID="btnEnrol" runat="server" Text="Enrol Now"
                                CssClass="btn-enrol" OnClick="btnEnrol_Click" />
                        </asp:Panel>

                        <%-- Enrolled --%>
                        <asp:Panel ID="pnlEnrolled" runat="server" Visible="false">
                            <a href='<%= "Quiz.aspx?courseId=" + Request.QueryString["id"] %>'
                               class="btn-enrolled-cta">
                                <i class="ti ti-help-circle"></i> Take Quiz
                            </a>
                            <div class="enrol-note" style="color:var(--cyber-accent2);">
                                &#10003; You are enrolled &mdash; scroll down for course content
                            </div>
                        </asp:Panel>

                    </div>
                </div>
            </div>

        </div>
    </div>

<script>
    function toggleMaterial(id) {
        var card = document.getElementById(id);
        card.classList.toggle('expanded');
    }
</script>
</asp:Content>
