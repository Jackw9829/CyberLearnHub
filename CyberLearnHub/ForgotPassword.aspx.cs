using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;

namespace CyberLearnHub
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect already-logged-in users away
            if (Session["UserID"] != null)
                Response.Redirect("~/Default.aspx");
        }

        protected void btnSendReset_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(email))
            {
                ShowMessage("Please enter your email address.", "error");
                return;
            }

            // Generate a cryptographically random token
            string token = GenerateSecureToken();
            DateTime expiry = DateTime.UtcNow.AddMinutes(30);

            string connStr = ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;
            bool userFound = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string sql = @"UPDATE Users
                                   SET ResetToken = @Token, ResetTokenExpiry = @Expiry
                                   WHERE Email = @Email";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Token", token);
                        cmd.Parameters.AddWithValue("@Expiry", expiry);
                        cmd.Parameters.AddWithValue("@Email", email);
                        userFound = cmd.ExecuteNonQuery() > 0;
                    }
                }

                // Always show the same message to avoid leaking which emails are registered
                ShowMessage("If that email is registered, a reset link has been sent. Check your inbox (and spam folder).", "success");

                if (userFound)
                    System.Threading.Tasks.Task.Run(() => SendResetEmailAsync(email, token));
            }
            catch (Exception ex)
            {
                // Log to trace for debugging; never expose raw exception to user
                System.Diagnostics.Trace.TraceError("ForgotPassword error: " + ex.Message);
                ShowMessage("Something went wrong. Please try again later.", "error");
            }
        }

        // ------------------------------------------------------------------ //
        //  Helpers
        // ------------------------------------------------------------------ //

        private void ShowMessage(string text, string type)
        {
            lblMessage.Text = text;
            // data-type attribute is read by the inline JS to apply CSS class
            lblMessage.Attributes["data-type"] = type;
            lblMessage.Attributes["class"] = "message show " + type;
        }

        private static string GenerateSecureToken()
        {
            var bytes = new byte[32];
            using (var rng = new RNGCryptoServiceProvider())
                rng.GetBytes(bytes);
            return BitConverter.ToString(bytes).Replace("-", "").ToLower();
        }

        private async Task SendResetEmailAsync(string toEmail, string token)
        {
            string apiKey   = ConfigurationManager.AppSettings["ResendApiKey"];
            string fromEmail = ConfigurationManager.AppSettings["ResendFromEmail"];
            string baseUrl  = ConfigurationManager.AppSettings["SiteBaseUrl"];

            // Ensure TLS 1.2 is used (important on Windows Server 2022 + .NET 4.7.2)
            System.Net.ServicePointManager.SecurityProtocol =
                System.Net.SecurityProtocolType.Tls12;

            string resetLink = $"{baseUrl}/ResetPassword.aspx?token={token}";

            string htmlBody = $@"
<div style='font-family:Segoe UI,sans-serif;max-width:480px;margin:auto;background:#161b22;border:1px solid #30363d;border-radius:12px;padding:36px;color:#e6edf3;'>
  <h2 style='margin-top:0;color:#58a6ff;'>Reset your password</h2>
  <p style='color:#8b949e;line-height:1.6;'>
    We received a request to reset the password for your CyberLearnHub account.
    Click the button below to choose a new password. This link expires in <strong>30 minutes</strong>.
  </p>
  <a href='{resetLink}'
     style='display:inline-block;margin:24px 0;padding:12px 28px;
            background:linear-gradient(135deg,#00c6ff,#0072ff);
            color:#fff;border-radius:8px;text-decoration:none;font-weight:600;'>
    Reset password
  </a>
  <p style='color:#8b949e;font-size:0.8rem;'>
    If you didn't request this, you can safely ignore this email — your password won't change.
  </p>
  <hr style='border:none;border-top:1px solid #30363d;margin:20px 0;'/>
  <p style='color:#484f58;font-size:0.75rem;'>
    CyberLearnHub &nbsp;·&nbsp; Cybersecurity E-Learning Platform
  </p>
</div>";

            // Build JSON payload manually to avoid external Newtonsoft dependency
            string jsonBody = "{"
                + "\"from\":\"" + EscapeJson(fromEmail) + "\","
                + "\"to\":[\"" + EscapeJson(toEmail) + "\"],"
                + "\"subject\":\"Reset your CyberLearnHub password\","
                + "\"html\":\"" + EscapeJson(htmlBody) + "\""
                + "}";

            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization =
                    new AuthenticationHeaderValue("Bearer", apiKey);

                var content = new StringContent(jsonBody, Encoding.UTF8, "application/json");
                HttpResponseMessage response =
                    await client.PostAsync("https://api.resend.com/emails", content);

                if (!response.IsSuccessStatusCode)
                {
                    string body = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Trace.TraceError(
                        $"Resend API error {response.StatusCode}: {body}");
                }
            }
        }

        /// <summary>Escapes a string for safe embedding inside a JSON string literal.</summary>
        private static string EscapeJson(string s)
        {
            return s
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n")
                .Replace("\t", "\\t");
        }
    }
}
