using System;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class cyberlearnhub_homepage : Page
    {
        // =============================================
        // PAGE LOAD
        // =============================================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                ApplyNavState();
        }

        private void ApplyNavState()
        {
            bool loggedIn = Session["UserID"] != null;
            string role   = Session["Role"] as string ?? "";

            pnlGuestButtons.Visible = !loggedIn;
            pnlUserButtons.Visible  = loggedIn;
            pnlAdminNav.Visible     = loggedIn && role == "Admin";

            if (loggedIn)
                lblNavUsername.Text = Session["Username"] as string ?? "user";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/cyberlearnhub_homepage.aspx");
        }

        // =============================================s
        // NAVIGATION BUTTONS
        // =============================================
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("Login.aspx");
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            Response.Redirect("Register.aspx");
        }

        // =============================================
        // HERO CTA
        // =============================================
        protected void btnBrowseCourses_Click(object sender, EventArgs e)
        {
            Response.Redirect("CourseListing.aspx");
        }

        // =============================================
        // SEARCH
        // =============================================
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string query = txtSearch.Text.Trim();

            if (string.IsNullOrEmpty(query))
            {
                lblSearchMsg.Text = "> Please enter a search term.";
                return;
            }

            // Pass the search query to CourseListing via query string
            Response.Redirect("CourseListing.aspx?search=" + Server.UrlEncode(query));
        }

        // =============================================
        // ENROLL BUTTONS
        // Each button redirects to the course detail page.
        // If the user is not logged in, redirect to Login first.
        // =============================================
        protected void btnEnroll1_Click(object sender, EventArgs e)
        {
            EnrollOrRedirect(courseId: 1);
        }

        protected void btnEnroll2_Click(object sender, EventArgs e)
        {
            EnrollOrRedirect(courseId: 2);
        }

        protected void btnEnroll3_Click(object sender, EventArgs e)
        {
            EnrollOrRedirect(courseId: 3);
        }

        // =============================================
        // HELPER — check session before enrolling
        // =============================================
        private void EnrollOrRedirect(int courseId)
        {
            if (Session["UserID"] == null)
            {
                // Not logged in — send to login page, return to course after
                Response.Redirect("Login.aspx?returnUrl=CourseDetail.aspx?id=" + courseId);
            }
            else
            {
                // Logged in — go straight to the course detail page
                Response.Redirect("CourseDetail.aspx?id=" + courseId);
            }
        }
    }
}
