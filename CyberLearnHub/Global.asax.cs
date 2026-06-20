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
    }
}
