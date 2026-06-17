using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Admin
{
    public partial class ManageUsers : AdminBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadUsers();
        }

        private void LoadUsers()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT UserID, FullName, Email, Role, IsActive FROM dbo.Users ORDER BY UserID", conn))
            {
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            rptUsers.DataSource = dt;
            rptUsers.DataBind();
        }

        protected void lbAction_Command(object sender, CommandEventArgs e)
        {
            string[] parts = e.CommandArgument.ToString().Split(',');
            if (!int.TryParse(parts[0], out int uid)) return;

            if (e.CommandName == "ToggleActive")
            {
                bool current = parts[1] == "True";
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE dbo.Users SET IsActive = @v WHERE UserID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@v",   current ? 0 : 1);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowAlert("&gt; User status updated.", true);
            }
            else if (e.CommandName == "ToggleRole")
            {
                string newRole = parts[1] == "Admin" ? "Member" : "Admin";
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE dbo.Users SET Role = @role WHERE UserID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@role", newRole);
                    cmd.Parameters.AddWithValue("@uid",  uid);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowAlert("&gt; User role updated.", true);
            }

            LoadUsers();
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }
    }
}
