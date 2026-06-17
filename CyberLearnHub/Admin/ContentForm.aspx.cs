using System;
using System.Data.SqlClient;

namespace CyberLearnHub.Admin
{
    public partial class ContentForm : AdminBasePage
    {
        private int _id;

        protected void Page_Load(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"], out _id);

            if (!IsPostBack && _id > 0)
            {
                litPageTitle.Text = "Edit Content Block";
                LoadBlock(_id);
            }
        }

        private void LoadBlock(int id)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT SectionKey, Title, Body FROM dbo.WebsiteContent WHERE ContentID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("ManageContent.aspx"); return; }
                    txtSectionKey.Text = r["SectionKey"] as string ?? "";
                    txtTitle.Text      = r["Title"] as string ?? "";
                    txtBody.Text       = r["Body"] as string ?? "";
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            int.TryParse(Request.QueryString["id"], out _id);

            string key   = txtSectionKey.Text.Trim();
            string title = txtTitle.Text.Trim();
            string body  = txtBody.Text.Trim();
            string user  = Session["Username"] as string ?? "";

            if (_id > 0)
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.WebsiteContent
                    SET SectionKey=@k, Title=@t, Body=@b, UpdatedBy=@u, UpdatedDate=GETDATE()
                    WHERE ContentID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@k",  key);
                    cmd.Parameters.AddWithValue("@t",  title);
                    cmd.Parameters.AddWithValue("@b",  body);
                    cmd.Parameters.AddWithValue("@u",  user);
                    cmd.Parameters.AddWithValue("@id", _id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO dbo.WebsiteContent (SectionKey, Title, Body, UpdatedBy, UpdatedDate)
                    VALUES (@k, @t, @b, @u, GETDATE())", conn))
                {
                    cmd.Parameters.AddWithValue("@k", key);
                    cmd.Parameters.AddWithValue("@t", title);
                    cmd.Parameters.AddWithValue("@b", body);
                    cmd.Parameters.AddWithValue("@u", user);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            Response.Redirect("ManageContent.aspx?saved=1");
        }
    }
}
