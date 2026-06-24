namespace CyberLearnHub.Admin
{
    public partial class ManageUsers
    {
        protected global::System.Web.UI.WebControls.Panel pnlAlert;
        protected global::System.Web.UI.WebControls.Label lblAlert;
        protected global::System.Web.UI.WebControls.Panel pnlUserForm;
        protected global::System.Web.UI.WebControls.Literal litFormTitle;
        protected global::System.Web.UI.WebControls.HiddenField hdnUserId;
        protected global::System.Web.UI.WebControls.TextBox txtName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvName;
        protected global::System.Web.UI.WebControls.TextBox txtEmail;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEmail;
        protected global::System.Web.UI.WebControls.DropDownList ddlRole;
        protected global::System.Web.UI.WebControls.TextBox txtPassword;
        protected global::System.Web.UI.WebControls.Button btnSaveUser;
        protected global::System.Web.UI.WebControls.Button btnCancel;
        protected global::System.Web.UI.WebControls.Button btnShowAdd;
        protected global::System.Web.UI.WebControls.Repeater rptUsers;
    }
}
