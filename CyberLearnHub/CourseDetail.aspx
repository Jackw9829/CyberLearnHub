<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseDetail.aspx.cs"
         Inherits="CyberLearnHub.CourseDetail" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title><asp:Literal ID="litPageTitle" runat="server" /> — CyberLearn Hub</title>
    <style>
        .detail-wrap { max-width:1100px; margin:0 auto; padding:40px 24px 60px; }

        .breadcrumb {
            font-family:'Share Tech Mono',monospace; font-size:11px;
            color:var(--cyber-muted); letter-spacing:1px; margin-bottom:28px;
        }
        .breadcrumb a { color:var(--cyber-accent); text-decoration:none; }
        .breadcrumb a:hover { color:#33ddff; }
        .breadcrumb span { margin:0 8px; }

        .detail-grid {
            display:grid; grid-template-columns:1fr 320px;
            gap:28px; align-items:start;
        }
        @media (max-width:768px) { .detail-grid { grid-template-columns:1fr; } }

        .detail-thumb {
            width:100%; height:260px;
            background:linear-gradient(135deg, #0d1a2e 0%, #111c2b 100%);
            border:1px solid var(--cyber-border); border-radius:10px;
            display:flex; align-items:center; justify-content:center;
            font-size:72px; color:rgba(0,212,255,0.18);
            margin-bottom:24px; overflow:hidden;
        }
        .detail-thumb img { width:100%; height:100%; object-fit:cover; border-radius:9px; }
        .detail-badges { display:flex; gap:8px; margin-bottom:14px; flex-wrap:wrap; }
        .badge {
            font-family:'Share Tech Mono',monospace; font-size:9px;
            letter-spacing:1px; padding:4px 10px; border-radius:20px; text-transform:uppercase;
        }
        .badge-cat  { background:rgba(0,212,255,0.1);  color:var(--cyber-accent);  border:1px solid rgba(0,212,255,0.25); }
        .badge-beg  { background:rgba(0,255,157,0.1);  color:var(--cyber-accent2); border:1px solid rgba(0,255,157,0.25); }
        .badge-int  { background:rgba(250,199,117,0.1);color:var(--cyber-amber);   border:1px solid rgba(250,199,117,0.25);}
        .badge-adv  { background:rgba(255,59,92,0.1);  color:var(--cyber-danger);  border:1px solid rgba(255,59,92,0.25); }

        .detail-title {
            font-family:'Rajdhani',sans-serif; font-size:32px; font-weight:700;
            color:var(--cyber-heading); margin-bottom:16px; line-height:1.2;
        }
        .detail-desc { font-size:14px; color:var(--cyber-text); line-height:1.8; }

        /* ============ COURSE CONTENT ============ */
        .content-section { margin-top:36px; }
        .content-section-title {
            font-family:'Rajdhani',sans-serif; font-size:20px; font-weight:700;
            color:var(--cyber-heading); margin-bottom:16px;
            display:flex; align-items:center; gap:10px;
            padding-bottom:12px; border-bottom:1px solid var(--cyber-border);
        }
        .content-section-title i { color:var(--cyber-accent); }

        .material-card {
            background:var(--cyber-card); border:1px solid var(--cyber-border);
            border-radius:10px; margin-bottom:14px; overflow:hidden;
            transition:border-color 0.2s;
        }
        .material-card:hover { border-color:rgba(0,212,255,0.3); }

        .material-header {
            display:flex; align-items:center; gap:12px;
            padding:14px 18px; cursor:pointer;
            user-select:none;
        }
        .material-type-icon {
            width:36px; height:36px; border-radius:8px;
            display:flex; align-items:center; justify-content:center;
            font-size:17px; flex-shrink:0;
        }
        .icon-video   { background:rgba(255,59,92,0.12);  color:#ff3b5c; }
        .icon-pdf     { background:rgba(255,99,59,0.12);  color:#ff633b; }
        .icon-image   { background:rgba(0,212,255,0.12);  color:var(--cyber-accent); }
        .icon-article { background:rgba(0,255,157,0.12);  color:var(--cyber-accent2); }
        .icon-link    { background:rgba(250,199,117,0.12);color:var(--cyber-amber); }

        .material-meta { flex:1; min-width:0; }
        .material-title {
            font-family:'Rajdhani',sans-serif; font-size:15px; font-weight:700;
            color:var(--cyber-heading); white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
        }
        .material-type-label {
            font-family:'Share Tech Mono',monospace; font-size:9px;
            color:var(--cyber-muted); letter-spacing:1px; text-transform:uppercase; margin-top:2px;
        }
        .material-chevron {
            color:var(--cyber-muted); font-size:16px;
            transition:transform 0.2s; flex-shrink:0;
        }
        .material-card.expanded .material-chevron { transform:rotate(90deg); }

        .material-body { display:none; padding:0 18px 18px; }
        .material-card.expanded .material-body { display:block; }

        /* Video embed */
        .video-embed-wrap {
            position:relative; padding-top:56.25%;
            border-radius:8px; overflow:hidden; background:#000;
        }
        .video-embed-wrap iframe {
            position:absolute; top:0; left:0; width:100%; height:100%; border:none;
        }

        /* PDF viewer */
        .pdf-viewer-wrap {
            border:1px solid var(--cyber-border); border-radius:8px; overflow:hidden;
        }
        .pdf-viewer-wrap iframe { width:100%; height:480px; border:none; display:block; }
        .pdf-download-bar {
            display:flex; align-items:center; justify-content:space-between;
            padding:10px 14px; background:rgba(8,13,20,0.6);
            border-top:1px solid var(--cyber-border);
        }
        .pdf-download-bar span {
            font-family:'Share Tech Mono',monospace; font-size:11px;
            color:var(--cyber-muted); letter-spacing:0.5px;
        }

        /* Article content */
        .article-content {
            font-size:14px; color:var(--cyber-text); line-height:1.85;
            white-space:pre-wrap; word-break:break-word;
        }

        /* Image */
        .material-image { max-width:100%; border-radius:8px; display:block; }
        .material-caption {
            font-family:'Share Tech Mono',monospace; font-size:11px;
            color:var(--cyber-muted); margin-top:8px; letter-spacing:0.5px;
        }

        /* External link */
        .material-link-btn {
            display:inline-flex; align-items:center; gap:8px;
            padding:10px 20px;
            background:rgba(250,199,117,0.08);
            border:1px solid rgba(250,199,117,0.3);
            color:var(--cyber-amber);
            border-radius:6px; font-family:'Rajdhani',sans-serif;
            font-size:13px; font-weight:700; letter-spacing:1px;
            text-transform:uppercase; text-decoration:none;
            transition:background 0.2s;
        }
        .material-link-btn:hover { background:rgba(250,199,117,0.15); color:var(--cyber-amber); }
        .link-desc { font-size:13px; color:var(--cyber-text); line-height:1.7; margin-bottom:12px; }

        /* Download button */
        .btn-download {
            display:inline-flex; align-items:center; gap:6px;
            padding:7px 14px;
            background:rgba(0,255,157,0.08);
            border:1px solid rgba(0,255,157,0.3);
            color:var(--cyber-accent2);
            border-radius:6px; font-family:'Rajdhani',sans-serif;
            font-size:12px; font-weight:700; letter-spacing:1px;
            text-transform:uppercase; text-decoration:none;
            transition:background 0.2s;
        }
        .btn-download:hover { background:rgba(0,255,157,0.15); color:var(--cyber-accent2); }

        .no-materials {
            padding:32px; text-align:center;
            font-family:'Share Tech Mono',monospace; font-size:12px;
            color:var(--cyber-muted); letter-spacing:1px;
        }

        /* ============ SIDEBAR ============ */
        .sidebar-card {
            background:var(--cyber-card); border:1px solid var(--cyber-border);
            border-radius:10px; padding:24px; position:sticky; top:20px;
        }
        .sidebar-card::before {
            content:''; display:block; height:2px;
            background:linear-gradient(90deg, var(--cyber-accent), var(--cyber-accent2));
            margin:-24px -24px 20px; border-radius:10px 10px 0 0;
        }
        .sidebar-stat {
            display:flex; justify-content:space-between; align-items:center;
            padding:10px 0; border-bottom:1px solid var(--cyber-border); font-size:13px;
        }
        .sidebar-stat:last-of-type { border-bottom:none; }
        .sidebar-stat-label { color:var(--cyber-muted); font-family:'Share Tech Mono',monospace; font-size:11px; letter-spacing:1px; }
        .sidebar-stat-val { color:var(--cyber-heading); font-weight:600; }

        .enrol-section { margin-top:20px; }
        .btn-enrol {
            width:100%; padding:13px; background:var(--cyber-accent);
            color:#080d14; border:none; font-family:'Rajdhani',sans-serif;
            font-size:15px; font-weight:700; letter-spacing:1.5px;
            border-radius:6px; cursor:pointer; text-transform:uppercase;
            transition:background 0.2s; display:block; text-align:center; text-decoration:none;
        }
        .btn-enrol:hover { background:#33ddff; color:#080d14; }
        .btn-enrolled-cta {
            width:100%; padding:13px;
            background:rgba(0,255,157,0.1); color:var(--cyber-accent2);
            border:1px solid var(--cyber-accent2);
            font-family:'Rajdhani',sans-serif; font-size:15px; font-weight:700;
            letter-spacing:1.5px; border-radius:6px; cursor:pointer; text-transform:uppercase;
            transition:background 0.2s; display:block; text-align:center; text-decoration:none;
        }
        .btn-enrolled-cta:hover { background:rgba(0,255,157,0.18); color:var(--cyber-accent2); }
        .enrol-note {
            margin-top:10px; font-size:11px; color:var(--cyber-muted);
            text-align:center; font-family:'Share Tech Mono',monospace; letter-spacing:0.5px;
        }
        .enrol-note a { color:var(--cyber-accent); text-decoration:none; }

        .detail-alert { padding:12px 16px; border-radius:6px; font-size:13px; margin-bottom:16px; }
        .detail-alert.success { background:rgba(0,255,157,0.08); border:1px solid rgba(0,255,157,0.3); color:var(--cyber-accent2); }
        .detail-alert.error   { background:rgba(255,59,92,0.08);  border:1px solid rgba(255,59,92,0.3);  color:var(--cyber-danger); }
    </style>
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
