using System;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class cyberlearnhub_homepage : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnBrowseCourses_Click(object sender, EventArgs e)
        {
            Response.Redirect("CourseListing.aspx");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string query = txtSearch.Text.Trim();

            if (string.IsNullOrEmpty(query))
            {
                lblSearchMsg.Text = "> Please enter a search term.";
                return;
            }

            Response.Redirect("CourseListing.aspx?search=" + Server.UrlEncode(query));
        }

        protected void btnEnroll1_Click(object sender, EventArgs e) { EnrollOrRedirect(1); }
        protected void btnEnroll2_Click(object sender, EventArgs e) { EnrollOrRedirect(2); }
        protected void btnEnroll3_Click(object sender, EventArgs e) { EnrollOrRedirect(3); }

        private void EnrollOrRedirect(int courseId)
        {
            if (Session["UserID"] == null)
                Response.Redirect("Login.aspx?returnUrl=CourseDetail.aspx?id=" + courseId);
            else
                Response.Redirect("CourseDetail.aspx?id=" + courseId);
        }
    }
}
