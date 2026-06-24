<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseListing.aspx.cs"
         Inherits="CyberLearnHub.CourseListing" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Courses — CyberLearn Hub</title>
    <style>
        .page-hero {
            padding: 48px 0 32px;
            text-align: center;
        }
        .page-hero-tag {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-accent);
            letter-spacing: 3px;
            text-transform: uppercase;
            margin-bottom: 12px;
        }
        .page-hero-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 36px;
            font-weight: 700;
            color: var(--cyber-heading);
            letter-spacing: 1px;
        }
        .page-hero-title span { color: var(--cyber-accent); }

        /* Filter bar */
        .filter-bar {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 8px;
            padding: 18px 24px;
            margin-bottom: 32px;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: flex-end;
        }
        .filter-group { display: flex; flex-direction: column; gap: 5px; flex: 1; min-width: 160px; }
        .filter-group label {
            font-family: 'Share Tech Mono', monospace;
            font-size: 10px;
            color: var(--cyber-muted);
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }
        .filter-bar .btn-filter {
            background: var(--cyber-accent);
            color: #080d14;
            border: none;
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            padding: 9px 20px;
            border-radius: 5px;
            cursor: pointer;
            text-transform: uppercase;
            transition: background 0.2s;
            align-self: flex-end;
        }
        .filter-bar .btn-filter:hover { background: #33ddff; }
        .filter-bar .btn-reset {
            background: transparent;
            color: var(--cyber-muted);
            border: 1px solid var(--cyber-border);
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            transition: color 0.2s, border-color 0.2s;
            align-self: flex-end;
        }
        .filter-bar .btn-reset:hover { color: var(--cyber-text); border-color: var(--cyber-text); }

        /* Count badge */
        .results-meta {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px;
            color: var(--cyber-muted);
            margin-bottom: 20px;
            letter-spacing: 1px;
        }
        .results-meta span { color: var(--cyber-accent); }

        /* Course grid */
        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 48px;
        }
        .course-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px;
            overflow: hidden;
            transition: border-color 0.25s, transform 0.25s;
            position: relative;
        }
        .course-card:hover {
            border-color: var(--cyber-accent);
            transform: translateY(-3px);
        }
        .course-thumb {
            height: 140px;
            background: linear-gradient(135deg, #0d1a2e 0%, #111c2b 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            color: rgba(0,212,255,0.25);
            border-bottom: 1px solid var(--cyber-border);
            position: relative;
            overflow: hidden;
        }
        .course-thumb::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(0,212,255,0.05), rgba(0,255,157,0.03));
        }
        .course-thumb img { width: 100%; height: 100%; object-fit: cover; }
        .course-body { padding: 18px; }
        .course-badges { display: flex; gap: 6px; margin-bottom: 10px; flex-wrap: wrap; }
        .badge {
            font-family: 'Share Tech Mono', monospace;
            font-size: 9px;
            letter-spacing: 1px;
            padding: 3px 8px;
            border-radius: 20px;
            text-transform: uppercase;
        }
        .badge-cat  { background: rgba(0,212,255,0.1);  color: var(--cyber-accent);  border: 1px solid rgba(0,212,255,0.25); }
        .badge-beg  { background: rgba(0,255,157,0.1);  color: var(--cyber-accent2); border: 1px solid rgba(0,255,157,0.25); }
        .badge-int  { background: rgba(250,199,117,0.1); color: var(--cyber-amber);  border: 1px solid rgba(250,199,117,0.25); }
        .badge-adv  { background: rgba(255,59,92,0.1);  color: var(--cyber-danger);  border: 1px solid rgba(255,59,92,0.25); }
        .badge-enrolled { background: rgba(0,255,157,0.12); color: var(--cyber-accent2); border: 1px solid rgba(0,255,157,0.3); }
        .course-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 17px;
            font-weight: 700;
            color: var(--cyber-heading);
            margin-bottom: 8px;
            line-height: 1.3;
        }
        .course-desc {
            font-size: 12px;
            color: var(--cyber-muted);
            line-height: 1.6;
            margin-bottom: 16px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .btn-view {
            display: inline-block;
            background: transparent;
            border: 1px solid var(--cyber-accent);
            color: var(--cyber-accent);
            font-family: 'Rajdhani', sans-serif;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1px;
            padding: 7px 16px;
            border-radius: 5px;
            cursor: pointer;
            text-transform: uppercase;
            transition: background 0.2s, color 0.2s;
            text-decoration: none;
        }
        .btn-view:hover { background: rgba(0,212,255,0.1); color: var(--cyber-accent); }
        .btn-enrolled {
            display: inline-block;
            background: rgba(0,255,157,0.1);
            border: 1px solid var(--cyber-accent2);
            color: var(--cyber-accent2);
            font-family: 'Rajdhani', sans-serif;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1px;
            padding: 7px 16px;
            border-radius: 5px;
            text-decoration: none;
            text-transform: uppercase;
        }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: var(--cyber-muted);
        }
        .empty-state i { font-size: 48px; margin-bottom: 16px; display: block; color: var(--cyber-border); }
        .empty-state p { font-family: 'Share Tech Mono', monospace; font-size: 13px; letter-spacing: 1px; }
    </style>
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
