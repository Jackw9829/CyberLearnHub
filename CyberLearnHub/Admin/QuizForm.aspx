<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizForm.aspx.cs"
         Inherits="CyberLearnHub.Admin.QuizForm" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Add Quiz" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-card" style="max-width:600px;">

        <asp:Panel ID="pnlAlert" runat="server" Visible="false">
            <asp:Label ID="lblAlert" runat="server" />
        </asp:Panel>

        <div class="form-group">
            <label class="form-label">Quiz Title *</label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200"
                placeholder="e.g. Introduction to Cybersecurity Quiz" />
            <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                ControlToValidate="txtTitle" CssClass="form-error"
                ErrorMessage="&gt; Title is required." Display="Dynamic" />
        </div>

        <div class="form-group">
            <label class="form-label">Description</label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="3" MaxLength="500"
                placeholder="Brief description of what this quiz covers..." />
        </div>

        <div class="form-group" style="max-width:180px;">
            <label class="form-label">Passing Score (%) *</label>
            <asp:TextBox ID="txtPassingScore" runat="server" CssClass="form-control" Text="70" MaxLength="3" />
            <asp:RequiredFieldValidator ID="rfvScore" runat="server"
                ControlToValidate="txtPassingScore" CssClass="form-error"
                ErrorMessage="&gt; Passing score is required." Display="Dynamic" />
            <asp:RangeValidator ID="rvScore" runat="server"
                ControlToValidate="txtPassingScore" Type="Integer" MinimumValue="1" MaximumValue="100"
                CssClass="form-error" ErrorMessage="&gt; Must be between 1 and 100." Display="Dynamic" />
            <span class="form-hint">Minimum percentage to pass (1&ndash;100)</span>
        </div>

        <div style="display:flex;gap:12px;margin-top:8px;padding-top:16px;border-top:1px solid var(--cyber-border);">
            <asp:Button ID="btnSave" runat="server" Text="Save Quiz"
                CssClass="btn-admin-primary" OnClick="btnSave_Click" />
            <asp:HyperLink ID="hlBack" runat="server" CssClass="btn-secondary">Cancel</asp:HyperLink>
        </div>

    </div>
</asp:Content>
