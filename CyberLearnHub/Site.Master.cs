using System;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Site : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                ApplyNavState();
        }

        // Shows/hides nav panels based on session role.
        private void ApplyNavState()
        {
            bool loggedIn = Session["UserID"] != null;
            string role   = Session["Role"] as string ?? "";

            pnlGuestButtons.Visible = !loggedIn;
            pnlUserButtons.Visible  = loggedIn;
            pnlUserNav.Visible      = loggedIn;
            pnlAdminNav.Visible   = loggedIn && role == "Admin";
            pnlAdminFloat.Visible = loggedIn && role == "Admin";

            if (loggedIn)
                lblNavUsername.Text = Session["Username"] as string ?? "user";
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Login.aspx");
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Register.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/cyberlearnhub_homepage.aspx");
        }
    }
}
