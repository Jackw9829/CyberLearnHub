using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["UserID"] != null)
                Response.Redirect("~/cyberlearnhub_homepage.aspx");
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            try
            {
                UserAccount user = GetUserByEmail(email);

                if (user == null || !string.Equals(user.PasswordHash, HashPassword(password), StringComparison.OrdinalIgnoreCase))
                {
                    ShowAlert("&gt; Invalid email or password.");
                    return;
                }

                Session["UserID"] = user.UserID;
                Session["Username"] = user.FullName;
                Session["Role"] = user.Role;

                RedirectAfterLogin();
            }
            catch (Exception ex)
            {
                ShowAlert("&gt; Login failed: " + Server.HtmlEncode(ex.Message));
            }
        }

        private static string ConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;
            }
        }

        private static UserAccount GetUserByEmail(string email)
        {
            string sql = @"
                SELECT UserID, FullName, Email, PasswordHash, Role
                FROM dbo.Users
                WHERE Email = @Email AND IsActive = 1";

            using (SqlConnection conn = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                        return null;

                    return new UserAccount
                    {
                        UserID = reader.GetInt32(0),
                        FullName = reader.GetString(1),
                        Email = reader.GetString(2),
                        PasswordHash = reader.GetString(3),
                        Role = reader.GetString(4)
                    };
                }
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

        private void ShowAlert(string message)
        {
            lblAlert.Text = message;
            pnlAlert.Visible = true;
        }

        private void RedirectAfterLogin()
        {
            string returnUrl = Request.QueryString["returnUrl"];

            if (!string.IsNullOrEmpty(returnUrl))
                Response.Redirect(returnUrl);
            else
                Response.Redirect("~/cyberlearnhub_homepage.aspx");
        }

        private sealed class UserAccount
        {
            public int UserID { get; set; }
            public string FullName { get; set; }
            public string Email { get; set; }
            public string PasswordHash { get; set; }
            public string Role { get; set; }
        }
    }
}