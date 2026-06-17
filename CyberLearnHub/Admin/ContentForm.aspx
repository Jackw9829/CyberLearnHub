<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentForm.aspx.cs"
         Inherits="CyberLearnHub.Admin.ContentForm" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Add Content Block" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-card" style="max-width:700px;">

        <asp:Panel ID="pnlAlert" runat="server" Visible="false">
            <asp:Label ID="lblAlert" runat="server" />
        </asp:Panel>

        <div class="form-group">
            <label class="form-label">Section Key *
                <span style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);font-weight:400;"> — unique identifier (e.g. hero_title, about_body)</span>
            </label>
            <asp:TextBox ID="txtSectionKey" runat="server" CssClass="form-control" MaxLength="100"
                placeholder="e.g. hero_title" />
            <asp:RequiredFieldValidator ID="rfvKey" runat="server"
                ControlToValidate="txtSectionKey" CssClass="form-error"
                ErrorMessage="Section key is required." Display="Dynamic" />
        </div>

        <div class="form-group">
            <label class="form-label">Title</label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200" />
        </div>

        <div class="form-group">
            <label class="form-label">Body / Content</label>
            <asp:TextBox ID="txtBody" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="8" MaxLength="8000" />
        </div>

        <div style="display:flex;gap:12px;margin-top:8px;">
            <asp:Button ID="btnSave" runat="server" Text="Save Block"
                CssClass="btn-admin-primary" OnClick="btnSave_Click" />
            <a href="ManageContent.aspx" class="btn-secondary">Cancel</a>
        </div>

    </div>
</asp:Content>
