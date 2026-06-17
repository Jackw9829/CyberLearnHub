using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace CyberLearnHub.Admin
{
    public partial class ManageContent : AdminBasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadContent();
                if (Request.QueryString["saved"] == "1")
                    ShowAlert("&gt; Content block saved.", true);
            }
        }

        private void LoadContent()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ContentID, SectionKey, Title, Body, UpdatedBy, UpdatedDate FROM dbo.WebsiteContent ORDER BY SectionKey", conn))
            {
                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0) { pnlEmpty.Visible = true; return; }
            rptContent.DataSource = dt;
            rptContent.DataBind();
        }

        protected void lbDelete_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(((LinkButton)sender).CommandArgument, out int id)) return;

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.WebsiteContent WHERE ContentID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            pnlEmpty.Visible = false;
            LoadContent();
            ShowAlert("&gt; Content block deleted.", true);
        }

        private void ShowAlert(string msg, bool success)
        {
            lblAlert.Text     = msg;
            pnlAlert.CssClass = "admin-alert " + (success ? "success" : "error");
            pnlAlert.Visible  = true;
        }
    }
}
