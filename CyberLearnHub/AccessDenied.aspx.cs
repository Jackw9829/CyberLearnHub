using System;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class AccessDenied : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string section = Request.QueryString["section"]?.ToLower();

            if (section == "labs" || section == "admin" || section == "forum" || section == "quizzes")
            {
                pnlDesktopRequired.Visible = true;
                pnlAccessDenied.Visible    = false;
                pnlLoginLink.Visible       = false;

                string what;
                if      (section == "labs")    what = "the Cyber Labs";
                else if (section == "admin")   what = "the Admin Panel";
                else if (section == "forum")   what = "the Forum";
                else if (section == "quizzes") what = "Quizzes";
                else                           what = "this section";

                lblDesktopMsg.Text =
                    $"{what} requires a desktop or laptop browser.<br />" +
                    "Please switch to a larger device to continue.";
            }
            else
            {
                pnlDesktopRequired.Visible = false;
                pnlAccessDenied.Visible    = true;
                pnlLoginLink.Visible       = true;
            }
        }
    }
}
