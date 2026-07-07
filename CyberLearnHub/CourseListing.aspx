<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseListing.aspx.cs"
         Inherits="CyberLearnHub.CourseListing" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Courses — CyberLearn Hub</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/course-listing.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container" style="max-width:1200px;margin:0 auto;padding:0 24px;">

        <div class="page-hero">
            <div class="page-hero-tag">// e-learning platform</div>
            <div class="page-hero-title">Course <span>Catalogue</span></div>
        </div>

        <!-- Filter bar -->
        <asp:Panel ID="pnlFilter" runat="server" CssClass="filter-bar" DefaultButton="btnFilter">
            <div class="filter-group">
                <label>Category</label>
                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control" />
            </div>
            <div class="filter-group">
                <label>Difficulty</label>
                <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="form-control">
                    <asp:ListItem Value="">All Levels</asp:ListItem>
                    <asp:ListItem Value="Beginner">Beginner</asp:ListItem>
                    <asp:ListItem Value="Intermediate">Intermediate</asp:ListItem>
                    <asp:ListItem Value="Advanced">Advanced</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group" style="flex:2;min-width:200px;">
                <label>Search</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search courses..." MaxLength="100" />
            </div>
            <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn-filter" OnClick="btnFilter_Click" />
            <asp:Button ID="btnReset"  runat="server" Text="Reset"  CssClass="btn-reset"  OnClick="btnReset_Click" CausesValidation="false" />
        </asp:Panel>

        <!-- Results meta -->
        <div class="results-meta">
            <asp:Label ID="lblCount" runat="server" />
        </div>

        <!-- Empty state -->
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <i class="ti ti-folder-off"></i>
                <p>&gt; No courses match your filters.</p>
            </div>
        </asp:Panel>

        <!-- Course grid -->
        <div class="course-grid">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <div class="course-card">
                        <div class="course-thumb">
                            <%# !string.IsNullOrEmpty(Eval("ImageUrl") as string)
                                ? "<img src=\"" + ResolveUrl(Eval("ImageUrl") as string) + "\" alt=\"course\" />"
                                : "<i class=\"ti ti-shield-lock\"></i>" %>
                        </div>
                        <div class="course-body">
                            <div class="course-badges">
                                <%# GetCategoryBadge(Eval("Category") as string) %>
                                <%# GetDifficultyBadge(Eval("Difficulty") as string) %>
                                <%# IsEnrolled(Convert.ToInt32(Eval("CourseID"))) ? "<span class=\"badge badge-enrolled\">&#10003; Enrolled</span>" : "" %>
                            </div>
                            <div class="course-title"><%# Eval("Title") %></div>
                            <div class="course-desc"><%# Eval("Description") %></div>
                            <%# IsEnrolled(Convert.ToInt32(Eval("CourseID")))
                                ? "<a href=\"CourseDetail.aspx?id=" + Eval("CourseID") + "\" class=\"btn-enrolled\"><i class=\"ti ti-arrow-right\"></i> Continue</a>"
                                : "<a href=\"CourseDetail.aspx?id=" + Eval("CourseID") + "\" class=\"btn-view\">View Course</a>" %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

    </div>
</asp:Content>
