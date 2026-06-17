namespace CyberLearnHub.Admin
{
    public partial class LearningMaterialForm
    {
        protected global::System.Web.UI.WebControls.Literal litPageTitle;
        protected global::System.Web.UI.WebControls.Panel pnlAlert;
        protected global::System.Web.UI.WebControls.Label lblAlert;
        protected global::System.Web.UI.WebControls.HiddenField hdnMaterialType;
        protected global::System.Web.UI.WebControls.TextBox txtTitle;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvTitle;
        // Article
        protected global::System.Web.UI.WebControls.TextBox txtContent;
        // Video
        protected global::System.Web.UI.WebControls.TextBox txtVideoUrl;
        protected global::System.Web.UI.WebControls.TextBox txtVideoDesc;
        // PDF
        protected global::System.Web.UI.WebControls.FileUpload fuPdf;
        protected global::System.Web.UI.WebControls.TextBox txtPdfUrl;
        protected global::System.Web.UI.WebControls.TextBox txtPdfDesc;
        // Image
        protected global::System.Web.UI.WebControls.FileUpload fuImage;
        protected global::System.Web.UI.WebControls.TextBox txtImageUrl;
        protected global::System.Web.UI.WebControls.TextBox txtImageCaption;
        // Link
        protected global::System.Web.UI.WebControls.TextBox txtLinkUrl;
        protected global::System.Web.UI.WebControls.TextBox txtLinkDesc;
        // Shared
        protected global::System.Web.UI.WebControls.TextBox txtSortOrder;
        protected global::System.Web.UI.WebControls.Button btnSave;
        protected global::System.Web.UI.WebControls.HyperLink hlBack;
    }
}
