using System;
using System.Web.UI;

namespace CyberLearnHub.Admin
{
    public partial class AdminMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected string CurrentPage(string name)
        {
            string path = Request.AppRelativeCurrentExecutionFilePath ?? "";
            return path.IndexOf(name, StringComparison.OrdinalIgnoreCase) >= 0 ? "active" : "";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }
    }
}
