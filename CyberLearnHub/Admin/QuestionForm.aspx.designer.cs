namespace CyberLearnHub.Admin
{
    public partial class QuestionForm
    {
        protected global::System.Web.UI.WebControls.Literal litPageTitle;
        protected global::System.Web.UI.WebControls.Panel pnlAlert;
        protected global::System.Web.UI.WebControls.Label lblAlert;
        protected global::System.Web.UI.WebControls.HiddenField hdnQuestionType;
        protected global::System.Web.UI.WebControls.TextBox txtQuestion;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvQ;
        // Multiple Choice
        protected global::System.Web.UI.WebControls.TextBox txtA;
        protected global::System.Web.UI.WebControls.TextBox txtB;
        protected global::System.Web.UI.WebControls.TextBox txtC;
        protected global::System.Web.UI.WebControls.TextBox txtD;
        protected global::System.Web.UI.WebControls.DropDownList ddlCorrect;
        // True / False
        protected global::System.Web.UI.WebControls.DropDownList ddlTFCorrect;
        // Fill in the Blank
        protected global::System.Web.UI.WebControls.TextBox txtFillAnswer;
        // Actions
        protected global::System.Web.UI.WebControls.Button btnSave;
        protected global::System.Web.UI.WebControls.HyperLink hlBack;
    }
}
