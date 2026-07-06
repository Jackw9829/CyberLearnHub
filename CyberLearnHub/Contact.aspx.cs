using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace CyberLearnHub
{
    public partial class Contact : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string name    = txtName.Text.Trim();
            string email   = txtEmail.Text.Trim();
            string subject = ddlSubject.SelectedValue;
            string message = txtMessage.Text.Trim();

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email) ||
                string.IsNullOrEmpty(subject) || string.IsNullOrEmpty(message))
            {
                ShowAlert("Please fill in all fields before sending.", "error");
                return;
            }

            if (message.Length < 10)
            {
                ShowAlert("Your message is too short. Please provide more detail.", "error");
                return;
            }

            try
            {
                SaveToDatabase(name, email, subject, message);
                System.Threading.Tasks.Task.Run(() => SendContactEmailAsync(name, email, subject, message));
                ShowAlert("Your message has been sent. We'll get back to you within 1–2 business days.", "success");
                txtName.Text = txtEmail.Text = txtMessage.Text = "";
                ddlSubject.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Contact form error: " + ex.Message);
                ShowAlert("Something went wrong. Please try again later.", "error");
            }
        }

        private void SaveToDatabase(string name, string email, string subject, string message)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.ContactMessages (SenderName, SenderEmail, Subject, Message, SentDate, IsRead)
                VALUES (@Name, @Email, @Subject, @Message, GETDATE(), 0)", conn))
            {
                cmd.Parameters.AddWithValue("@Name",    name);
                cmd.Parameters.AddWithValue("@Email",   email);
                cmd.Parameters.AddWithValue("@Subject", subject);
                cmd.Parameters.AddWithValue("@Message", message);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowAlert(string text, string type)
        {
            lblAlert.Text = text;
            lblAlert.Attributes["class"] = "alert show alert-" + type;
        }

        private async System.Threading.Tasks.Task SendContactEmailAsync(
            string name, string fromEmail, string subject, string message)
        {
            string apiKey      = ConfigurationManager.AppSettings["ResendApiKey"];
            string fromAddress = ConfigurationManager.AppSettings["ResendFromEmail"];
            string toAddress   = ConfigurationManager.AppSettings["ContactRecipientEmail"];

            System.Net.ServicePointManager.SecurityProtocol =
                System.Net.SecurityProtocolType.Tls12;

            string htmlBody = string.Format(@"
<div style='font-family:Segoe UI,sans-serif;max-width:540px;margin:auto;background:#161b22;
            border:1px solid #30363d;border-radius:12px;padding:36px;color:#e6edf3;'>
  <h2 style='margin-top:0;color:#58a6ff;'>New Contact Form Submission</h2>
  <table style='width:100%;border-collapse:collapse;font-size:13px;margin-bottom:24px;'>
    <tr><td style='padding:8px 0;color:#8b949e;width:110px;'>Name</td>
        <td style='padding:8px 0;color:#e6edf3;'>{0}</td></tr>
    <tr><td style='padding:8px 0;color:#8b949e;'>Email</td>
        <td style='padding:8px 0;color:#e6edf3;'>{1}</td></tr>
    <tr><td style='padding:8px 0;color:#8b949e;'>Subject</td>
        <td style='padding:8px 0;color:#e6edf3;'>{2}</td></tr>
  </table>
  <div style='background:#0d1117;border:1px solid #30363d;border-radius:8px;padding:18px 20px;'>
    <p style='margin:0;font-size:13px;line-height:1.7;color:#c9d1d9;white-space:pre-wrap;'>{3}</p>
  </div>
  <hr style='border:none;border-top:1px solid #30363d;margin:24px 0;'/>
  <p style='color:#484f58;font-size:0.75rem;margin:0;'>
    CyberLearnHub &nbsp;&middot;&nbsp; Contact Form
  </p>
</div>",
                EscapeHtml(name), EscapeHtml(fromEmail), EscapeHtml(subject), EscapeHtml(message));

            string replyTo = fromEmail;
            string jsonBody = "{"
                + "\"from\":\"" + EscapeJson(fromAddress) + "\","
                + "\"to\":[\"" + EscapeJson(toAddress) + "\"],"
                + "\"reply_to\":\"" + EscapeJson(replyTo) + "\","
                + "\"subject\":\"[CyberLearnHub Contact] " + EscapeJson(subject) + " from " + EscapeJson(name) + "\","
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
                        "Resend contact form error " + response.StatusCode + ": " + body);
                }
            }
        }

        private static string EscapeJson(string s)
        {
            return s
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n")
                .Replace("\t", "\\t");
        }

        private static string EscapeHtml(string s)
        {
            return System.Web.HttpUtility.HtmlEncode(s);
        }
    }
}
