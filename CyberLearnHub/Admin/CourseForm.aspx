<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseForm.aspx.cs"
         Inherits="CyberLearnHub.Admin.CourseForm" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Add Course" />
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/admin-course-form.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-card" style="max-width:660px;">

        <asp:Panel ID="pnlAlert" runat="server" Visible="false">
            <asp:Label ID="lblAlert" runat="server" />
        </asp:Panel>

        <div class="form-group">
            <label class="form-label">Course Title *</label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200"
                placeholder="e.g. Introduction to Cybersecurity" />
            <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                ControlToValidate="txtTitle" CssClass="form-error"
                ErrorMessage="&gt; Title is required." Display="Dynamic" />
        </div>

        <div class="form-group">
            <label class="form-label">Description</label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="5" MaxLength="4000"
                placeholder="Describe what students will learn..." />
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Category</label>
                <asp:TextBox ID="txtCategory" runat="server" CssClass="form-control"
                    placeholder="e.g. Network Security" MaxLength="100" />
            </div>
            <div class="form-group">
                <label class="form-label">Difficulty Level</label>
                <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="form-control">
                    <asp:ListItem Value="">-- Select --</asp:ListItem>
                    <asp:ListItem Value="Beginner">Beginner</asp:ListItem>
                    <asp:ListItem Value="Intermediate">Intermediate</asp:ListItem>
                    <asp:ListItem Value="Advanced">Advanced</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <!-- Course Image -->
        <div class="form-group">
            <label class="form-label">Course Image (Thumbnail)</label>

            <div class="img-tabs">
                <button type="button" class="img-tab active" onclick="switchImgTab('upload', this)">
                    <i class="ti ti-upload" style="font-size:12px;margin-right:4px;"></i> Upload File
                </button>
                <button type="button" class="img-tab" onclick="switchImgTab('url', this)">
                    <i class="ti ti-link" style="font-size:12px;margin-right:4px;"></i> Image URL
                </button>
            </div>

            <!-- Upload tab -->
            <div id="panelUpload" class="img-panel active">
                <div class="upload-drop-zone" onclick="document.getElementById('<%= fuImage.ClientID %>').click()">
                    <i class="ti ti-photo-up"></i>
                    <div class="upload-drop-zone-text">Click to browse &mdash; JPG, PNG, GIF, WebP &mdash; max 5 MB</div>
                    <asp:FileUpload ID="fuImage" runat="server" accept="image/*" onchange="previewUpload(this)" />
                </div>
                <div id="uploadFileName" class="upload-file-name"></div>
            </div>

            <!-- URL tab -->
            <div id="panelUrl" class="img-panel">
                <asp:TextBox ID="txtThumbnail" runat="server" CssClass="form-control"
                    placeholder="https://example.com/image.gif"
                    MaxLength="500" oninput="previewUrl(this.value)" />
                <span class="form-hint">Supports direct image links including animated GIFs</span>
            </div>

            <!-- Live preview -->
            <div class="img-preview-wrap" id="previewWrap">
                <div class="img-preview-placeholder" id="previewPlaceholder">
                    <i class="ti ti-photo" style="font-size:24px;display:block;margin-bottom:6px;opacity:0.4;"></i>
                    Image preview will appear here
                </div>
                <img id="previewImg" src="" alt="Preview" />
            </div>

            <asp:Label ID="lblImgError" runat="server" CssClass="form-error" Visible="false" />
        </div>

        <div class="form-group">
            <label style="display:flex;align-items:center;gap:10px;cursor:pointer;">
                <asp:CheckBox ID="chkPublished" runat="server" />
                <span class="form-label" style="margin:0;">Published (visible to students)</span>
            </label>
        </div>

        <div style="display:flex;gap:12px;margin-top:8px;padding-top:16px;border-top:1px solid var(--cyber-border);">
            <asp:Button ID="btnSave" runat="server" Text="Save Course"
                CssClass="btn-admin-primary" OnClick="btnSave_Click" />
            <a href="ManageCourses.aspx" class="btn-secondary">Cancel</a>
        </div>
    </div>

<script>
    // Switch between upload / URL tabs
    function switchImgTab(tab, btn) {
        document.querySelectorAll('.img-tab').forEach(function(t) { t.classList.remove('active'); });
        document.querySelectorAll('.img-panel').forEach(function(p) { p.classList.remove('active'); });
        btn.classList.add('active');
        document.getElementById('panel' + tab.charAt(0).toUpperCase() + tab.slice(1)).classList.add('active');

        // Clear the other input so only one is used
        if (tab === 'upload') {
            document.getElementById('<%= txtThumbnail.ClientID %>').value = '';
            clearPreview();
        } else {
            var fileInput = document.getElementById('<%= fuImage.ClientID %>');
            // Can't clear file input value, but server-side checks HasFile
            document.getElementById('uploadFileName').textContent = '';
            clearPreview();
        }
    }

    // Preview from file upload
    function previewUpload(input) {
        if (input.files && input.files[0]) {
            var file = input.files[0];
            // Validate type
            if (!file.type.startsWith('image/')) {
                document.getElementById('uploadFileName').textContent = '> Not an image file.';
                clearPreview(); return;
            }
            // Validate size (5 MB)
            if (file.size > 5 * 1024 * 1024) {
                document.getElementById('uploadFileName').textContent = '> File too large (max 5 MB).';
                clearPreview(); return;
            }
            document.getElementById('uploadFileName').textContent = file.name + ' (' + (file.size / 1024).toFixed(0) + ' KB)';
            var reader = new FileReader();
            reader.onload = function(e) { showPreview(e.target.result); };
            reader.readAsDataURL(file);
        }
    }

    // Preview from URL input (debounced)
    var _urlTimer;
    function previewUrl(val) {
        clearTimeout(_urlTimer);
        _urlTimer = setTimeout(function() {
            if (val.trim()) showPreview(val.trim());
            else clearPreview();
        }, 500);
    }

    function showPreview(src) {
        var img = document.getElementById('previewImg');
        var ph  = document.getElementById('previewPlaceholder');
        img.onload  = function() { img.style.display = 'block'; ph.style.display = 'none'; };
        img.onerror = function() { img.style.display = 'none';  ph.style.display = 'block'; ph.innerHTML = '<i class="ti ti-photo-x" style="font-size:24px;display:block;margin-bottom:6px;opacity:0.4;"></i>Could not load image'; };
        img.src = src;
    }

    function clearPreview() {
        var img = document.getElementById('previewImg');
        img.src = ''; img.style.display = 'none';
        var ph = document.getElementById('previewPlaceholder');
        ph.style.display = 'block';
        ph.innerHTML = '<i class="ti ti-photo" style="font-size:24px;display:block;margin-bottom:6px;opacity:0.4;"></i>Image preview will appear here';
    }

    // On page load, if there's an existing URL, show it in URL tab and preview
    window.addEventListener('DOMContentLoaded', function() {
        var existingUrl = document.getElementById('<%= txtThumbnail.ClientID %>').value;
        if (existingUrl) {
            // Switch to URL tab
            var tabs = document.querySelectorAll('.img-tab');
            tabs[0].classList.remove('active'); tabs[1].classList.add('active');
            document.getElementById('panelUpload').classList.remove('active');
            document.getElementById('panelUrl').classList.add('active');
            showPreview(existingUrl);
        }
    });
</script>
</asp:Content>
