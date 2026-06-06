using System;
using System.Data.SqlClient;
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

            string fullName = txtFullName.Text.Trim();
            string email    = txtEmail.Text.Trim().ToLower();
            string passHash = DatabaseHelper.HashPassword(txtPassword.Text);

            if (fullName.Length < 3)
            {
                ShowError("&gt; Full name must be at least 3 characters.");
                return;
            }

            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    conn.Open();

                    // Check if email is already registered
                    SqlCommand checkCmd = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.Users WHERE Email = @Email", conn);
                    checkCmd.Parameters.AddWithValue("@Email", email);
                    int exists = (int)checkCmd.ExecuteScalar();

                    if (exists > 0)
                    {
                        ShowError("&gt; That email address is already registered.");
                        return;
                    }

                    // Insert new member
                    SqlCommand insertCmd = new SqlCommand(
                        @"INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role)
                          VALUES (@FullName, @Email, @Hash, 'Member')",
                        conn);
                    insertCmd.Parameters.AddWithValue("@FullName", fullName);
                    insertCmd.Parameters.AddWithValue("@Email",    email);
                    insertCmd.Parameters.AddWithValue("@Hash",     passHash);
                    insertCmd.ExecuteNonQuery();
                }

                ShowSuccess("&gt; Account created successfully! <a href='Login.aspx'>Log in here</a>.");
                ClearForm();
            }
            catch (Exception ex)
            {
                ShowError("&gt; Database error: " + ex.Message);
            }
        }

        // =============================================
        // HELPERS
        // =============================================
        private void ShowError(string message)
        {
            lblError.Text      = message;
            pnlError.Visible   = true;
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
            txtFullName.Text        = string.Empty;
            txtEmail.Text           = string.Empty;
            txtPassword.Text        = string.Empty;
            txtConfirmPassword.Text = string.Empty;
        }
    }
}
