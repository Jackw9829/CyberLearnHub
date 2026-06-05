using System;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserID"] != null)
                Response.Redirect("~/Dashboard.aspx");
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string username = txtUsername.Text.Trim();
            string email    = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            // Basic server-side length check (validators handle the rest)
            if (username.Length < 3)
            {
                ShowError("&gt; Username must be at least 3 characters.");
                return;
            }

            // TODO: Replace with real DB calls once the database is ready.
            // Example:
            //   if (UserManager.EmailExists(email))
            //   {
            //       ShowError("> That email address is already registered.");
            //       return;
            //   }
            //   string passwordHash = PasswordHelper.Hash(password);
            //   UserManager.Create(username, email, passwordHash, role: "User");
            //   ShowSuccess("> Account created! You can now log in.");

            // --- Temporary stub: show success message without touching DB ---
            ShowSuccess("&gt; Account created successfully! <a href='Login.aspx'>Log in here</a>.");
            ClearForm();
        }

        private void ShowError(string message)
        {
            lblError.Text    = message;
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }

        private void ShowSuccess(string message)
        {
            lblSuccess.Text    = message;
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ClearForm()
        {
            txtUsername.Text        = string.Empty;
            txtEmail.Text           = string.Empty;
            txtPassword.Text        = string.Empty;
            txtConfirmPassword.Text = string.Empty;
        }
    }
}
