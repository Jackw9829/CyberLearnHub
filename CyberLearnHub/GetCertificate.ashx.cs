using System;
using System.IO;
using System.Web;
using System.Web.SessionState;
using System.Data.SqlClient;

namespace CyberLearnHub
{
    public class GetCertificate : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext ctx)
        {
            if (ctx.Session["UserID"] == null)
            {
                ctx.Response.Redirect("~/Login.aspx");
                return;
            }

            int uid = (int)ctx.Session["UserID"];
            if (!int.TryParse(ctx.Request.QueryString["id"], out int certId) || certId <= 0)
            {
                ctx.Response.StatusCode = 400;
                return;
            }

            string filePath;
            using (var conn = new SqlConnection(DbHelper.ConnectionString))
            using (var cmd  = new SqlCommand(
                "SELECT FilePath FROM dbo.Certificates WHERE CertificateID=@id AND UserID=@uid", conn))
            {
                cmd.Parameters.AddWithValue("@id",  certId);
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result == null)
                {
                    ctx.Response.StatusCode = 403;
                    return;
                }
                filePath = result.ToString();
            }

            string physical = ctx.Server.MapPath(filePath);
            if (!File.Exists(physical))
            {
                ctx.Response.StatusCode = 404;
                return;
            }

            ctx.Response.ContentType = "application/pdf";
            ctx.Response.AddHeader("Content-Disposition", "attachment; filename=\"CyberLearnHub-Certificate.pdf\"");
            ctx.Response.TransmitFile(physical);
        }

        public bool IsReusable => false;
    }
}
