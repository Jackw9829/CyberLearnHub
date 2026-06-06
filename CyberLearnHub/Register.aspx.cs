using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserID"] != null)
                Response.Redirect("~/cyberlearnhub_homepage.aspx");
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            if (username.Length < 3)
            {
                ShowError("&gt; Username must be at least 3 characters.");
                return;
            }

            try
            {
                if (EmailExists(email))
                {
                    ShowError("&gt; That email address is already registered.");
                    return;
                }

                CreateUser(username, email, HashPassword(password));

                ShowSuccess("&gt; Account created successfully! <a href='Login.aspx'>Log in here</a>.");
                ClearForm();
            }
            catch (Exception ex)
            {
                ShowError("&gt; Registration failed: " + Server.HtmlEncode(ex.Message));
            }
        }

        private static string ConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;
            }
        }

        private static bool EmailExists(string email)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(1) FROM dbo.Users WHERE Email = @Email", conn))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                conn.Open();

                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private static void CreateUser(string fullName, string email, string passwordHash)
        {
            string sql = @"
                INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, IsActive)
                VALUES (@FullName, @Email, @PasswordHash, @Role, 1)";

            using (SqlConnection conn = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@FullName", fullName);
                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@PasswordHash", passwordHash);
                cmd.Parameters.AddWithValue("@Role", "Member");

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();

                foreach (byte b in bytes)
                    builder.Append(b.ToString("X2"));

                return builder.ToString();
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }

        private void ShowSuccess(string message)
        {
            lblSuccess.Text = message;
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }

        private void ClearForm()
        {
            txtUsername.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtPassword.Text = string.Empty;
            txtConfirmPassword.Text = string.Empty;
        }
    }
}