using System;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserID"] != null)
                Response.Redirect("~/Dashboard.aspx");
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email    = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // TODO: Replace with real DB lookup once the database is ready.
            // Example:
            //   var user = UserManager.GetByEmail(email);
            //   if (user == null || !PasswordHelper.Verify(password, user.PasswordHash))
            //   {
            //       ShowAlert("Invalid email or password.");
            //       return;
            //   }
            //   Session["UserID"]  = user.UserID;
            //   Session["Username"] = user.Username;
            //   Session["Role"]    = user.Role;   // "User" or "Admin"
            //   RedirectAfterLogin();

            // --- Temporary stub: always fail so the form is testable ---
            ShowAlert("&gt; Login is not yet connected to the database.");
        }

        private void ShowAlert(string message)
        {
            lblAlert.Text      = message;
            pnlAlert.Visible   = true;
        }

        private void RedirectAfterLogin()
        {
            string returnUrl = Request.QueryString["returnUrl"];
            if (!string.IsNullOrEmpty(returnUrl))
                Response.Redirect(returnUrl);
            else if (Session["Role"] as string == "Admin")
                Response.Redirect("~/Admin/AdminDashboard.aspx");
            else
                Response.Redirect("~/Dashboard.aspx");
        }
    }
}
