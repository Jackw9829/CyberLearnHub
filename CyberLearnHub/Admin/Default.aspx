<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs"
         Inherits="CyberLearnHub.Admin.AdminDefault" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">Dashboard</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Stats grid -->
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;margin-bottom:32px;">

        <div class="admin-card" style="margin-bottom:0;display:flex;align-items:center;gap:16px;">
            <div style="width:44px;height:44px;border-radius:10px;background:rgba(0,212,255,0.1);color:var(--cyber-accent);display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;">
                <i class="ti ti-users"></i>
            </div>
            <div>
                <div style="font-family:'Rajdhani',sans-serif;font-size:28px;font-weight:700;color:var(--cyber-heading);line-height:1;">
                    <asp:Label ID="lblUsers" runat="server" Text="0" />
                </div>
                <div style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1px;text-transform:uppercase;margin-top:2px;">Total Users</div>
            </div>
        </div>

        <div class="admin-card" style="margin-bottom:0;display:flex;align-items:center;gap:16px;">
            <div style="width:44px;height:44px;border-radius:10px;background:rgba(0,255,157,0.1);color:var(--cyber-accent2);display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;">
                <i class="ti ti-book"></i>
            </div>
            <div>
                <div style="font-family:'Rajdhani',sans-serif;font-size:28px;font-weight:700;color:var(--cyber-heading);line-height:1;">
                    <asp:Label ID="lblCourses" runat="server" Text="0" />
                </div>
                <div style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1px;text-transform:uppercase;margin-top:2px;">Courses</div>
            </div>
        </div>

        <div class="admin-card" style="margin-bottom:0;display:flex;align-items:center;gap:16px;">
            <div style="width:44px;height:44px;border-radius:10px;background:rgba(250,199,117,0.1);color:var(--cyber-amber);display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;">
                <i class="ti ti-certificate"></i>
            </div>
            <div>
                <div style="font-family:'Rajdhani',sans-serif;font-size:28px;font-weight:700;color:var(--cyber-heading);line-height:1;">
                    <asp:Label ID="lblEnrolments" runat="server" Text="0" />
                </div>
                <div style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1px;text-transform:uppercase;margin-top:2px;">Enrolments</div>
            </div>
        </div>

        <div class="admin-card" style="margin-bottom:0;display:flex;align-items:center;gap:16px;">
            <div style="width:44px;height:44px;border-radius:10px;background:rgba(255,59,92,0.1);color:var(--cyber-danger);display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;">
                <i class="ti ti-help-circle"></i>
            </div>
            <div>
                <div style="font-family:'Rajdhani',sans-serif;font-size:28px;font-weight:700;color:var(--cyber-heading);line-height:1;">
                    <asp:Label ID="lblAttempts" runat="server" Text="0" />
                </div>
                <div style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1px;text-transform:uppercase;margin-top:2px;">Quiz Attempts</div>
            </div>
        </div>

    </div>

    <!-- Quick links -->
    <div class="admin-card">
        <div class="admin-card-title"><i class="ti ti-bolt"></i> Quick Actions</div>
        <div style="display:flex;gap:12px;flex-wrap:wrap;">
            <a href="CourseForm.aspx" class="btn-admin-primary"><i class="ti ti-plus"></i> Add Course</a>
            <a href="ManageCourses.aspx" class="btn-secondary"><i class="ti ti-book"></i> Manage Courses</a>
            <a href="ManageUsers.aspx" class="btn-secondary"><i class="ti ti-users"></i> Manage Users</a>
        </div>
    </div>

</asp:Content>
