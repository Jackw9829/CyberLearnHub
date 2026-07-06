using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace CyberLearnHub.Admin
{
    public partial class ContactMessages : AdminBasePage
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["CyberLearnConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadMessages();
        }

        private void LoadMessages()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT MessageID, SenderName, SenderEmail, Subject, Message, SentDate, IsRead " +
                "FROM dbo.ContactMessages ORDER BY SentDate DESC", conn))
            {
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            int unread = 0;
            foreach (DataRow r in dt.Rows)
                if (!(bool)r["IsRead"]) unread++;

            lblUnreadBadge.Text    = unread > 0 ? unread + " unread" : "";
            lblUnreadBadge.Visible = unread > 0;

            if (dt.Rows.Count == 0)
            {
                pnlEmpty.Visible    = true;
                rptMessages.Visible = false;
            }
            else
            {
                pnlEmpty.Visible      = false;
                rptMessages.Visible   = true;
                rptMessages.DataSource = dt;
                rptMessages.DataBind();
            }
        }

        protected void rptMessages_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "View")
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM dbo.ContactMessages WHERE MessageID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            litDetailSubject.Text = Server.HtmlEncode(r["Subject"].ToString());
                            litDetailName.Text    = Server.HtmlEncode(r["SenderName"].ToString());
                            litDetailEmail.Text   = Server.HtmlEncode(r["SenderEmail"].ToString());
                            litDetailDate.Text    = Convert.ToDateTime(r["SentDate"]).ToString("dd MMM yyyy HH:mm");
                            litDetailMessage.Text = Server.HtmlEncode(r["Message"].ToString());
                            aReply.HRef           = "mailto:" + r["SenderEmail"] + "?subject=Re: " +
                                                    Uri.EscapeDataString(r["Subject"].ToString());
                        }
                    }
                }

                // Mark as read
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE dbo.ContactMessages SET IsRead=1 WHERE MessageID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                pnlDetail.Visible = true;
            }
            else if (e.CommandName == "Delete")
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM dbo.ContactMessages WHERE MessageID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowAlert("Message deleted.", "success");
            }

            LoadMessages();
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE dbo.ContactMessages SET IsRead=1", conn))
            {
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            LoadMessages();
        }

        protected void btnCloseDetail_Click(object sender, EventArgs e)
        {
            pnlDetail.Visible = false;
            LoadMessages();
        }

        private void ShowAlert(string text, string type)
        {
            pnlAlert.Visible = true;
            lblAlert.Text    = text;
            lblAlert.Attributes["class"] = type == "success"
                ? "alert alert-success show"
                : "alert alert-error show";
        }
    }
}
