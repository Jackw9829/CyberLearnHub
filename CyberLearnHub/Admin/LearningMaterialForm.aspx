<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningMaterialForm.aspx.cs"
         Inherits="CyberLearnHub.Admin.LearningMaterialForm" MasterPageFile="~/Admin/Admin.Master" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server" Text="Add Material" />
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/admin-learning-material-form.css") %>" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="admin-card" style="max-width:700px;">

        <asp:Panel ID="pnlAlert" runat="server" Visible="false">
            <asp:Label ID="lblAlert" runat="server" />
        </asp:Panel>

        <!-- Hidden field to track type -->
        <asp:HiddenField ID="hdnMaterialType" runat="server" Value="Article" />

        <div class="form-group">
            <label class="form-label">Title *</label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200"
                placeholder="e.g. Introduction to Firewalls" />
            <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                ControlToValidate="txtTitle" CssClass="form-error"
                ErrorMessage="&gt; Title is required." Display="Dynamic" />
        </div>

        <!-- Material Type Selector -->
        <div class="form-group">
            <label class="form-label">Material Type</label>
            <div class="mtype-selector">
                <button type="button" class="mtype-btn active" id="btnTypeArticle" onclick="setMType('Article')">
                    <i class="ti ti-file-text"></i><span>Article</span>
                </button>
                <button type="button" class="mtype-btn" id="btnTypeVideo" onclick="setMType('Video')">
                    <i class="ti ti-brand-youtube"></i><span>Video</span>
                </button>
                <button type="button" class="mtype-btn" id="btnTypePDF" onclick="setMType('PDF')">
                    <i class="ti ti-file-type-pdf"></i><span>PDF</span>
                </button>
                <button type="button" class="mtype-btn" id="btnTypeImage" onclick="setMType('Image')">
                    <i class="ti ti-photo"></i><span>Image</span>
                </button>
                <button type="button" class="mtype-btn" id="btnTypeLink" onclick="setMType('Link')">
                    <i class="ti ti-link"></i><span>Link</span>
                </button>
            </div>
        </div>

        <!-- ===== ARTICLE ===== -->
        <div id="sectionArticle" class="mtype-section active">
            <div class="form-group">
                <label class="form-label">Article Content *</label>
                <asp:TextBox ID="txtContent" runat="server" CssClass="form-control"
                    TextMode="MultiLine" Rows="10" MaxLength="8000"
                    placeholder="Write the article content here..." />
            </div>
        </div>

        <!-- ===== VIDEO ===== -->
        <div id="sectionVideo" class="mtype-section">
            <div class="form-group">
                <label class="form-label">YouTube or Vimeo URL *</label>
                <asp:TextBox ID="txtVideoUrl" runat="server" CssClass="form-control"
                    placeholder="https://www.youtube.com/watch?v=... or https://vimeo.com/..."
                    MaxLength="500" oninput="previewVideo(this.value)" />
                <span class="form-hint">Paste a YouTube watch URL or Vimeo video URL</span>
            </div>
            <div class="video-no-preview" id="videoNoPrev">
                <i class="ti ti-player-play"></i>
                Paste a YouTube or Vimeo URL above to preview
            </div>
            <div class="video-preview-wrap" id="videoPreview">
                <iframe id="videoIframe" src="" allowfullscreen allow="autoplay"></iframe>
            </div>
            <div class="form-group" style="margin-top:16px;">
                <label class="form-label">Description (optional)</label>
                <asp:TextBox ID="txtVideoDesc" runat="server" CssClass="form-control"
                    TextMode="MultiLine" Rows="3" MaxLength="1000"
                    placeholder="Brief description of what this video covers..." />
            </div>
        </div>

        <!-- ===== PDF ===== -->
        <div id="sectionPDF" class="mtype-section">
            <div class="form-group">
                <label class="form-label">Upload PDF File</label>
                <div class="upload-zone" onclick="document.getElementById('<%= fuPdf.ClientID %>').click()">
                    <i class="ti ti-file-type-pdf"></i>
                    <p>Click to browse &mdash; PDF files only &mdash; max 20 MB</p>
                    <asp:FileUpload ID="fuPdf" runat="server" accept=".pdf,application/pdf"
                        onchange="showUploadInfo(this, 'pdfFileInfo')" />
                </div>
                <div id="pdfFileInfo" class="upload-file-info"></div>
            </div>
            <div class="form-group">
                <label class="form-label">— or paste a PDF URL</label>
                <asp:TextBox ID="txtPdfUrl" runat="server" CssClass="form-control"
                    placeholder="https://example.com/document.pdf"
                    MaxLength="500" oninput="previewPdf(this.value)" />
            </div>
            <div class="pdf-preview-wrap" id="pdfPreview">
                <iframe id="pdfIframe" src=""></iframe>
            </div>
            <div class="form-group" style="margin-top:16px;">
                <label class="form-label">Description (optional)</label>
                <asp:TextBox ID="txtPdfDesc" runat="server" CssClass="form-control"
                    TextMode="MultiLine" Rows="3" MaxLength="1000" />
            </div>
        </div>

        <!-- ===== IMAGE ===== -->
        <div id="sectionImage" class="mtype-section">
            <div class="form-group">
                <label class="form-label">Upload Image</label>
                <div class="upload-zone" onclick="document.getElementById('<%= fuImage.ClientID %>').click()">
                    <i class="ti ti-photo-up"></i>
                    <p>Click to browse &mdash; JPG, PNG, GIF, WebP &mdash; max 5 MB</p>
                    <asp:FileUpload ID="fuImage" runat="server" accept="image/*"
                        onchange="previewImageUpload(this)" />
                </div>
                <div id="imgFileInfo" class="upload-file-info"></div>
            </div>
            <div class="form-group">
                <label class="form-label">— or paste an Image URL</label>
                <asp:TextBox ID="txtImageUrl" runat="server" CssClass="form-control"
                    placeholder="https://example.com/diagram.png"
                    MaxLength="500" oninput="previewImageUrl(this.value)" />
            </div>
            <div class="img-preview-wrap" id="imgPreviewWrap">
                <div class="img-preview-placeholder" id="imgPlaceholder">
                    <i class="ti ti-photo" style="font-size:24px;display:block;margin-bottom:6px;opacity:0.3;"></i>
                    Preview
                </div>
                <img id="imgPreviewEl" src="" alt="Preview" />
            </div>
            <div class="form-group" style="margin-top:16px;">
                <label class="form-label">Caption (optional)</label>
                <asp:TextBox ID="txtImageCaption" runat="server" CssClass="form-control"
                    MaxLength="500" placeholder="Describe what this image shows..." />
            </div>
        </div>

        <!-- ===== LINK ===== -->
        <div id="sectionLink" class="mtype-section">
            <div class="form-group">
                <label class="form-label">URL *</label>
                <asp:TextBox ID="txtLinkUrl" runat="server" CssClass="form-control"
                    placeholder="https://..." MaxLength="500" />
            </div>
            <div class="form-group">
                <label class="form-label">Description</label>
                <asp:TextBox ID="txtLinkDesc" runat="server" CssClass="form-control"
                    TextMode="MultiLine" Rows="3" MaxLength="1000"
                    placeholder="What will students find at this link?" />
            </div>
        </div>

        <div class="form-group" style="max-width:90px;">
            <label class="form-label">Sort Order</label>
            <asp:TextBox ID="txtSortOrder" runat="server" CssClass="form-control" Text="0" MaxLength="4" />
        </div>

        <div style="display:flex;gap:12px;margin-top:8px;padding-top:16px;border-top:1px solid var(--cyber-border);">
            <asp:Button ID="btnSave" runat="server" Text="Save Material"
                CssClass="btn-admin-primary" OnClick="btnSave_Click" />
            <asp:HyperLink ID="hlBack" runat="server" CssClass="btn-secondary">Cancel</asp:HyperLink>
        </div>
    </div>

<script>
var currentMType = '<%= hdnMaterialType.Value %>';
var typeMap = { Article:'Article', Video:'Video', PDF:'PDF', Image:'Image', Link:'Link' };

function setMType(type) {
    currentMType = type;
    document.getElementById('<%= hdnMaterialType.ClientID %>').value = type;
    document.querySelectorAll('.mtype-btn').forEach(function(b) { b.classList.remove('active'); });
    document.getElementById('btnType' + type).classList.add('active');
    document.querySelectorAll('.mtype-section').forEach(function(s) { s.classList.remove('active'); });
    document.getElementById('section' + type).classList.add('active');
}

// ---- VIDEO ----
var _vidTimer;
function previewVideo(url) {
    clearTimeout(_vidTimer);
    _vidTimer = setTimeout(function() { _showVideoPreview(url.trim()); }, 600);
}
function _showVideoPreview(url) {
    var embedUrl = getEmbedUrl(url);
    var prev  = document.getElementById('videoPreview');
    var noPrev = document.getElementById('videoNoPrev');
    if (embedUrl) {
        document.getElementById('videoIframe').src = embedUrl;
        prev.style.display = 'block'; noPrev.style.display = 'none';
    } else {
        document.getElementById('videoIframe').src = '';
        prev.style.display = 'none'; noPrev.style.display = 'block';
    }
}
function getEmbedUrl(url) {
    // YouTube
    var ytMatch = url.match(/(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([A-Za-z0-9_-]{11})/);
    if (ytMatch) return 'https://www.youtube.com/embed/' + ytMatch[1] + '?rel=0';
    // Vimeo
    var vmMatch = url.match(/vimeo\.com\/(\d+)/);
    if (vmMatch) return 'https://player.vimeo.com/video/' + vmMatch[1];
    return null;
}

// ---- PDF ----
var _pdfTimer;
function previewPdf(url) {
    clearTimeout(_pdfTimer);
    _pdfTimer = setTimeout(function() {
        var prev = document.getElementById('pdfPreview');
        if (url.trim()) {
            document.getElementById('pdfIframe').src = url.trim();
            prev.style.display = 'block';
        } else {
            prev.style.display = 'none';
        }
    }, 800);
}

// ---- IMAGE ----
function previewImageUpload(input) {
    if (input.files && input.files[0]) {
        var f = input.files[0];
        showUploadInfo(input, 'imgFileInfo');
        var reader = new FileReader();
        reader.onload = function(e) { _showImgPreview(e.target.result); };
        reader.readAsDataURL(f);
    }
}
var _imgTimer;
function previewImageUrl(url) {
    clearTimeout(_imgTimer);
    _imgTimer = setTimeout(function() {
        if (url.trim()) _showImgPreview(url.trim()); else _clearImgPreview();
    }, 600);
}
function _showImgPreview(src) {
    var img = document.getElementById('imgPreviewEl');
    var ph  = document.getElementById('imgPlaceholder');
    img.onload  = function() { img.style.display='block'; ph.style.display='none'; };
    img.onerror = function() { img.style.display='none';  ph.style.display='block'; };
    img.src = src;
}
function _clearImgPreview() {
    document.getElementById('imgPreviewEl').style.display = 'none';
    document.getElementById('imgPlaceholder').style.display = 'block';
}

// ---- Shared upload info ----
function showUploadInfo(input, infoId) {
    if (input.files && input.files[0]) {
        var f = input.files[0];
        document.getElementById(infoId).textContent = f.name + ' (' + (f.size/1024).toFixed(0) + ' KB)';
    }
}

// ---- Init on load ----
window.addEventListener('DOMContentLoaded', function() {
    setMType(currentMType);
    // If editing a video, show preview
    if (currentMType === 'Video') {
        var v = document.getElementById('<%= txtVideoUrl.ClientID %>').value;
        if (v) _showVideoPreview(v);
    }
    if (currentMType === 'Image') {
        var u = document.getElementById('<%= txtImageUrl.ClientID %>').value;
        if (u) _showImgPreview(u);
    }
});
</script>
</asp:Content>
