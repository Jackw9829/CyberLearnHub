using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Profile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!IsPostBack)
                PopulateFields((int)Session["UserID"]);
        }

        private void PopulateFields(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT FullName, Email FROM dbo.Users WHERE UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        txtFullName.Text = r["FullName"] as string ?? "";
                        txtEmail.Text    = r["Email"] as string ?? "";
                    }
                }
            }
        }

        protected void btnSaveName_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int uid  = (int)Session["UserID"];
            string name = txtFullName.Text.Trim();

            if (name.Length < 2)
            {
                ShowNameAlert("&gt; Name must be at least 2 characters.", false);
                return;
            }

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE dbo.Users SET FullName = @name WHERE UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@name", name);
                cmd.Parameters.AddWithValue("@uid",  uid);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            Session["Username"] = name;
            ShowNameAlert("&gt; Name updated successfully.", true);
        }

        protected void btnChangePw_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int uid = (int)Session["UserID"];

            // Verify current password
            string storedHash = GetPasswordHash(uid);
            if (storedHash == null || !string.Equals(storedHash, AuthHelper.HashPassword(txtCurrentPw.Text),
                    StringComparison.OrdinalIgnoreCase))
            {
                ShowPwAlert("&gt; Current password is incorrect.", false);
                return;
            }

            string newHash = AuthHelper.HashPassword(txtNewPw.Text);

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE dbo.Users SET PasswordHash = @hash WHERE UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@hash", newHash);
                cmd.Parameters.AddWithValue("@uid",  uid);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            txtCurrentPw.Text = "";
            txtNewPw.Text     = "";
            txtConfirmPw.Text = "";
            ShowPwAlert("&gt; Password changed successfully.", true);
        }

        private static string GetPasswordHash(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT PasswordHash FROM dbo.Users WHERE UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                return cmd.ExecuteScalar() as string;
            }
        }

        private void ShowNameAlert(string msg, bool success)
        {
            lblNameAlert.Text   = msg;
            pnlNameAlert.CssClass = "alert-box " + (success ? "success" : "error");
            pnlNameAlert.Visible  = true;
        }

        private void ShowPwAlert(string msg, bool success)
        {
            lblPwAlert.Text   = msg;
            pnlPwAlert.CssClass = "alert-box " + (success ? "success" : "error");
            pnlPwAlert.Visible  = true;
        }
    }
}
