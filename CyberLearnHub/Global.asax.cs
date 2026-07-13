using System;
using System.Web;

namespace CyberLearnHub
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            DbHelper.EnsureSchema();
        }

        protected void Application_PreRequestHandlerExecute(object sender, EventArgs e)
        {
            var request = Context.Request;
            if (!DeviceHelper.IsMobileDevice(request)) return;

            string path = request.AppRelativeCurrentExecutionFilePath ?? "";

            string section = null;
            if (path.Equals("~/Labs.aspx",   StringComparison.OrdinalIgnoreCase)) section = "labs";
            else if (path.StartsWith("~/Admin/",   StringComparison.OrdinalIgnoreCase)) section = "admin";
            else if (path.StartsWith("~/Forum/",   StringComparison.OrdinalIgnoreCase)) section = "forum";
            else if (path.StartsWith("~/Quizzes/", StringComparison.OrdinalIgnoreCase)) section = "quizzes";

            if (section == null) return;

            // Avoid redirect loop
            if (path.StartsWith("~/AccessDenied", StringComparison.OrdinalIgnoreCase)) return;

            Context.Response.Redirect($"~/AccessDenied.aspx?section={section}", endResponse: true);
        }
    }
}
