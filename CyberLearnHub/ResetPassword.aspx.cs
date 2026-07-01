using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;

namespace CyberLearnHub
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect already-logged-in users away
            if (Session["UserID"] != null)
                Response.Redirect("~/Default.aspx");

            if (!IsPostBack)
            {
                string token = Request.QueryString["token"];

                if (string.IsNullOrWhiteSpace(token))
                {
                    ShowInvalidState("No reset token was provided.");
                    return;
                }

                // Store token in hidden field for the postback
                hfToken.Value = token;

                // Validate token exists and hasn't expired yet (pre-check only)
                if (!TokenIsValid(token))
                    ShowInvalidState("This reset link has expired or is invalid. Please request a new one.");
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            string newPassword    = txtNewPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;
            string token          = hfToken.Value;

            // ── Client-side validations ──────────────────────────────────────
            if (string.IsNullOrWhiteSpace(newPassword) || string.IsNullOrWhiteSpace(confirmPassword))
            {
                ShowMessage("Please fill in both password fields.", "error");
                return;
            }

            if (newPassword.Length < 8)
            {
                ShowMessage("Password must be at least 8 characters.", "error");
                return;
            }

            if (newPassword != confirmPassword)
            {
                ShowMessage("Passwords do not match.", "error");
                return;
            }

            if (string.IsNullOrWhiteSpace(token))
            {
                ShowMessage("Reset token is missing. Please use the link from your email.", "error");
                return;
            }

            // ── Database update ──────────────────────────────────────────────
            string connStr = ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;
            string hashedPassword = ComputeSha256Hash(newPassword);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Re-validate token and expiry atomically
                    string checkSql = @"SELECT UserID FROM Users
                                        WHERE ResetToken = @Token
                                          AND ResetTokenExpiry > @Now";

                    int userID = -1;
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Token", token);
                        cmd.Parameters.AddWithValue("@Now", DateTime.UtcNow);
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                            userID = Convert.ToInt32(result);
                    }

                    if (userID == -1)
                    {
                        ShowInvalidState("This reset link has expired or already been used. Please request a new one.");
                        return;
                    }

                    // Update password and clear the token so it can't be reused
                    string updateSql = @"UPDATE Users
                                         SET PasswordHash      = @PasswordHash,
                                             ResetToken        = NULL,
                                             ResetTokenExpiry  = NULL
                                         WHERE UserID = @UserID";

                    using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        cmd.ExecuteNonQuery();
                    }
                }

                // Hide form, show success
                pnlForm.Visible = false;
                ShowMessage("Your password has been reset. You can now <a href='Login.aspx' style='color:#58a6ff;'>log in</a> with your new password.", "success");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("ResetPassword error: " + ex.Message);
                ShowMessage("Something went wrong. Please try again later.", "error");
            }
        }

        // ------------------------------------------------------------------ //
        //  Helpers
        // ------------------------------------------------------------------ //

        private bool TokenIsValid(string token)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"SELECT COUNT(1) FROM Users
                               WHERE ResetToken = @Token
                                 AND ResetTokenExpiry > @Now";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Token", token);
                    cmd.Parameters.AddWithValue("@Now", DateTime.UtcNow);
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }

        private void ShowInvalidState(string message)
        {
            pnlForm.Visible = false;
            ShowMessage(message, "error");
        }

        private void ShowMessage(string text, string type)
        {
            lblMessage.Text = text;
            lblMessage.Attributes["data-type"] = type;
            lblMessage.Attributes["class"] = "message show " + type;
        }

        /// <summary>
        /// SHA-256 hash — must match the same method used at registration.
        /// </summary>
        public static string ComputeSha256Hash(string rawData)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(rawData));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }
    }
}
