<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
         Inherits="CyberLearnHub.Profile" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Profile — CyberLearn Hub</title>
    <style>
        .profile-wrap { max-width: 680px; margin: 0 auto; padding: 40px 24px 60px; }
        .profile-header { margin-bottom: 32px; }
        .profile-tag {
            font-family: 'Share Tech Mono', monospace;
            font-size: 11px; color: var(--cyber-accent);
            letter-spacing: 3px; margin-bottom: 6px;
        }
        .profile-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 28px; font-weight: 700; color: var(--cyber-heading);
        }

        .profile-card {
            background: var(--cyber-card);
            border: 1px solid var(--cyber-border);
            border-radius: 10px;
            padding: 28px;
            margin-bottom: 20px;
            position: relative;
            overflow: hidden;
        }
        .profile-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: linear-gradient(90deg, var(--cyber-accent), var(--cyber-accent2));
        }
        .card-section-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 16px; font-weight: 700;
            color: var(--cyber-heading);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .card-section-title i { color: var(--cyber-accent); }

        .alert-box {
            padding: 11px 16px;
            border-radius: 6px;
            font-size: 13px;
            margin-bottom: 16px;
            font-family: 'Share Tech Mono', monospace;
            letter-spacing: 0.5px;
        }
        .alert-box.success { background: rgba(0,255,157,0.08); border: 1px solid rgba(0,255,157,0.3); color: var(--cyber-accent2); }
        .alert-box.error   { background: rgba(255,59,92,0.08);  border: 1px solid rgba(255,59,92,0.3);  color: var(--cyber-danger); }

        .btn-save {
            padding: 10px 24px;
            background: var(--cyber-accent);
            color: #080d14;
            border: none;
            font-family: 'Rajdhani', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            border-radius: 5px;
            cursor: pointer;
            text-transform: uppercase;
            transition: background 0.2s;
            margin-top: 8px;
        }
        .btn-save:hover { background: #33ddff; }

        .pw-wrap { position: relative; }
        .pw-wrap .form-control { padding-right: 42px; }
        .pw-toggle {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: var(--cyber-muted); font-size: 16px; line-height: 1; padding: 0;
            transition: color 0.2s;
        }
        .pw-toggle:hover { color: var(--cyber-accent); }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="profile-wrap">

        <div class="profile-header">
            <div class="profile-tag">// account settings</div>
            <div class="profile-title">My Profile</div>
        </div>

        <!-- Account info card -->
        <div class="profile-card">
            <div class="card-section-title"><i class="ti ti-user"></i> Account Information</div>

            <asp:Panel ID="pnlNameAlert" runat="server" Visible="false">
                <asp:Label ID="lblNameAlert" runat="server" />
            </asp:Panel>

            <div class="form-group">
                <label class="form-label">Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvFullName" runat="server"
                    ControlToValidate="txtFullName" ValidationGroup="vgName"
                    CssClass="form-error" ErrorMessage="&gt; Name is required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                    ReadOnly="true" style="opacity:0.6;cursor:not-allowed;" />
                <div style="font-size:11px;color:var(--cyber-muted);margin-top:4px;font-family:'Share Tech Mono',monospace;">
                    Email cannot be changed.
                </div>
            </div>

            <asp:Button ID="btnSaveName" runat="server" Text="Save Changes"
                CssClass="btn-save" ValidationGroup="vgName" OnClick="btnSaveName_Click" />
        </div>

        <!-- Change password card -->
        <div class="profile-card">
            <div class="card-section-title"><i class="ti ti-key"></i> Change Password</div>

            <asp:Panel ID="pnlPwAlert" runat="server" Visible="false">
                <asp:Label ID="lblPwAlert" runat="server" />
            </asp:Panel>

            <div class="form-group">
                <label class="form-label">Current Password</label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtCurrentPw" runat="server" CssClass="form-control"
                        TextMode="Password" MaxLength="100" />
                    <button type="button" class="pw-toggle" onclick="togglePw('<%= txtCurrentPw.ClientID %>', this)" tabindex="-1">
                        <i class="ti ti-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvCurrentPw" runat="server"
                    ControlToValidate="txtCurrentPw" ValidationGroup="vgPw"
                    CssClass="form-error" ErrorMessage="&gt; Current password required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label class="form-label">New Password</label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtNewPw" runat="server" CssClass="form-control"
                        TextMode="Password" MaxLength="100" />
                    <button type="button" class="pw-toggle" onclick="togglePw('<%= txtNewPw.ClientID %>', this)" tabindex="-1">
                        <i class="ti ti-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvNewPw" runat="server"
                    ControlToValidate="txtNewPw" ValidationGroup="vgPw"
                    CssClass="form-error" ErrorMessage="&gt; New password required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label class="form-label">Confirm New Password</label>
                <div class="pw-wrap">
                    <asp:TextBox ID="txtConfirmPw" runat="server" CssClass="form-control"
                        TextMode="Password" MaxLength="100" />
                    <button type="button" class="pw-toggle" onclick="togglePw('<%= txtConfirmPw.ClientID %>', this)" tabindex="-1">
                        <i class="ti ti-eye"></i>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvConfirmPw" runat="server"
                    ControlToValidate="txtConfirmPw" ValidationGroup="vgPw"
                    CssClass="form-error" ErrorMessage="&gt; Confirm password required." Display="Dynamic" />
                <asp:CompareValidator ID="cvPw" runat="server"
                    ControlToValidate="txtConfirmPw" ControlToCompare="txtNewPw"
                    ValidationGroup="vgPw" CssClass="form-error"
                    ErrorMessage="&gt; Passwords do not match." Display="Dynamic" />
            </div>

            <asp:Button ID="btnChangePw" runat="server" Text="Change Password"
                CssClass="btn-save" ValidationGroup="vgPw" OnClick="btnChangePw_Click" />
        </div>

    </div>

    <script type="text/javascript">
        function togglePw(clientId, btn) {
            var box = document.getElementById(clientId);
            if (!box) return;
            var showing = box.type === 'text';
            box.type = showing ? 'password' : 'text';
            btn.querySelector('i').className = showing ? 'ti ti-eye' : 'ti ti-eye-off';
        }
    </script>
</asp:Content>
