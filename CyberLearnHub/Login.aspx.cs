using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Already logged in — skip the login page
            if (!IsPostBack && Session["UserID"] != null)
                Response.Redirect("~/Dashboard.aspx");
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email    = txtEmail.Text.Trim().ToLower();
            string passHash = DatabaseHelper.HashPassword(txtPassword.Text);

            try
            {
                using (SqlConnection conn = DatabaseHelper.GetConnection())
                {
                    conn.Open();

                    SqlCommand cmd = new SqlCommand(
                        @"SELECT UserID, FullName, Role
                          FROM   dbo.Users
                          WHERE  Email        = @Email
                            AND  PasswordHash = @Hash
                            AND  IsActive     = 1",
                        conn);

                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Hash",  passHash);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            Session["UserID"]   = dr["UserID"].ToString();
                            Session["Username"] = dr["FullName"].ToString();
                            Session["Role"]     = dr["Role"].ToString();  // "Member" or "Admin"
                            RedirectAfterLogin();
                        }
                        else
                        {
                            ShowAlert("&gt; Invalid email or password.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("&gt; Database error: " + ex.Message);
            }
        }

        // =============================================
        // HELPERS
        // =============================================
        private void ShowAlert(string message)
        {
            lblAlert.Text    = message;
            pnlAlert.Visible = true;
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
