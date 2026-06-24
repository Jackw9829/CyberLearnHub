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

        // ---- Show the Add form ----
        protected void btnShowAdd_Click(object sender, EventArgs e)
        {
            hdnUserId.Value = "";
            litFormTitle.Text = "Add User";
            txtName.Text = "";
            txtEmail.Text = "";
            txtPassword.Text = "";
            ddlRole.SelectedValue = "Member";
            pnlUserForm.Visible = true;
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            pnlUserForm.Visible = false;
        }

        // ---- Save (Insert or Update) ----
        protected void btnSaveUser_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string role = ddlRole.SelectedValue;
            string pw = txtPassword.Text;

            bool isEdit = int.TryParse(hdnUserId.Value, out int editId) && editId > 0;

            // Email must be unique (ignore the user being edited)
            if (EmailExists(email, isEdit ? editId : 0))
            {
                pnlUserForm.Visible = true;
                ShowAlert("&gt; That email is already used by another account.", false);
                return;
            }

            if (!isEdit)
            {
                // New user — password required
                if (pw.Length < 6)
                {
                    pnlUserForm.Visible = true;
                    ShowAlert("&gt; Password is required for new users (min 6 characters).", false);
                    return;
                }

                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, IsActive)
                    VALUES (@name, @email, @hash, @role, 1)", conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@hash", AuthHelper.HashPassword(pw));
                    cmd.Parameters.AddWithValue("@role", role);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowAlert("&gt; User created successfully.", true);
            }
            else
            {
                // Edit existing user
                if (pw.Length > 0 && pw.Length < 6)
                {
                    pnlUserForm.Visible = true;
                    ShowAlert("&gt; New password must be at least 6 characters (or leave blank).", false);
                    return;
                }

                if (pw.Length >= 6)
                {
                    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE dbo.Users
                        SET FullName=@name, Email=@email, Role=@role, PasswordHash=@hash
                        WHERE UserID=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@name", name);
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@role", role);
                        cmd.Parameters.AddWithValue("@hash", AuthHelper.HashPassword(pw));
                        cmd.Parameters.AddWithValue("@id", editId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE dbo.Users
                        SET FullName=@name, Email=@email, Role=@role
                        WHERE UserID=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@name", name);
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@role", role);
                        cmd.Parameters.AddWithValue("@id", editId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                // Keep the logged-in admin's session name in sync if they edited themselves
                if (editId == (int)Session["UserID"])
                {
                    Session["Username"] = name;
                    Session["Role"] = role;
                }

                ShowAlert("&gt; User updated successfully.", true);
            }

            pnlUserForm.Visible = false;
            LoadUsers();
        }

        // ---- Row actions: Edit / Delete / ToggleActive ----
        protected void lbAction_Command(object sender, CommandEventArgs e)
        {
            string arg = e.CommandArgument.ToString();

            if (e.CommandName == "Edit")
            {
                if (int.TryParse(arg, out int uid)) LoadUserIntoForm(uid);
                return;
            }

            if (e.CommandName == "Delete")
            {
                if (int.TryParse(arg, out int uid))
                {
                    if (uid == (int)Session["UserID"])
                    {
                        ShowAlert("&gt; You cannot delete your own account.", false);
                        return;
                    }
                    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.Users WHERE UserID = @uid", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", uid);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                    ShowAlert("&gt; User deleted.", true);
                    LoadUsers();
                }
                return;
            }

            if (e.CommandName == "ToggleActive")
            {
                string[] parts = arg.Split(',');
                if (!int.TryParse(parts[0], out int uid)) return;
                bool current = parts.Length > 1 && parts[1] == "True";
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE dbo.Users SET IsActive = @v WHERE UserID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@v", current ? 0 : 1);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowAlert("&gt; User status updated.", true);
                LoadUsers();
            }
        }

        private void LoadUserIntoForm(int uid)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT FullName, Email, Role FROM dbo.Users WHERE UserID = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { ShowAlert("&gt; User not found.", false); return; }
                    hdnUserId.Value = uid.ToString();
                    litFormTitle.Text = "Edit User";
                    txtName.Text = r["FullName"] as string ?? "";
                    txtEmail.Text = r["Email"] as string ?? "";
                    txtPassword.Text = "";
                    ddlRole.SelectedValue = (r["Role"] as string == "Admin") ? "Admin" : "Member";
                }
            }
            pnlUserForm.Visible = true;
        }

        private static bool EmailExists(string email, int excludeUserId)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(1) FROM dbo.Users WHERE Email = @email AND UserID <> @id", conn))
            {
                cmd.Parameters.AddWithValue("@email", email);
                cmd.Parameters.AddWithValue("@id", excludeUserId);
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible = true;
        }
    }
}
