using System.Web.UI;

public class AdminBasePage : Page
{
    protected override void OnInit(System.EventArgs e)
    {
        base.OnInit(e);
        if (Session["Role"] as string != "Admin")
            Response.Redirect("~/AccessDenied.aspx");
        DbHelper.EnsureSchema();
    }
}
