<%@ WebHandler Language="C#" Class="ChatbotHandler" %>

using System;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

public class ChatbotHandler : IHttpHandler
{
    // *** PASTE YOUR GROQ API KEY HERE ***
    private const string API_KEY = "REMOVED";

    // Groq uses OpenAI-compatible API format
    private const string API_URL = "https://api.groq.com/openai/v1/chat/completions";

    private const string SYSTEM_PROMPT = "You are CyberBot, a friendly cybersecurity assistant for CyberLearn Hub, " +
        "an e-learning platform at Asia Pacific University (APU). Help users understand cybersecurity concepts " +
        "like threats, encryption, firewalls, ethical hacking, OWASP Top 10, and network security. " +
        "Keep answers clear, concise, and beginner-friendly. Use bullet points when listing. " +
        "If asked something unrelated to cybersecurity, politely redirect.";

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.AddHeader("Cache-Control", "no-cache");

        try
        {
            // Read user message
            string requestBody;
            using (var reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
                requestBody = reader.ReadToEnd();

            var serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = Int32.MaxValue;

            dynamic requestData = serializer.DeserializeObject(requestBody);
            string userMessage = requestData["message"].ToString();

            // Sanitize for JSON
            string safeMessage = userMessage
                .Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\r", "\\r").Replace("\n", "\\n").Replace("\t", "\\t");

            string safeSystem = SYSTEM_PROMPT
                .Replace("\\", "\\\\").Replace("\"", "\\\"");

            // Groq uses OpenAI chat format: messages array with roles
            string jsonPayload =
                "{" +
                  "\"model\": \"llama-3.1-8b-instant\"," +
                  "\"max_tokens\": 1024," +
                  "\"messages\": [" +
                    "{\"role\": \"system\", \"content\": \"" + safeSystem + "\"}," +
                    "{\"role\": \"user\",   \"content\": \"" + safeMessage + "\"}" +
                  "]" +
                "}";

            // Force TLS 1.2
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            var webRequest = (HttpWebRequest)WebRequest.Create(API_URL);
            webRequest.Method = "POST";
            webRequest.ContentType = "application/json";
            webRequest.Accept = "application/json";
            webRequest.Timeout = 30000;
            webRequest.Headers.Add("Authorization", "Bearer " + API_KEY);

            byte[] data = Encoding.UTF8.GetBytes(jsonPayload);
            webRequest.ContentLength = data.Length;

            using (var stream = webRequest.GetRequestStream())
                stream.Write(data, 0, data.Length);

            string responseBody;
            using (var webResponse = (HttpWebResponse)webRequest.GetResponse())
            using (var reader = new StreamReader(webResponse.GetResponseStream(), Encoding.UTF8))
                responseBody = reader.ReadToEnd();

            // Parse OpenAI-format response: choices[0].message.content
            dynamic groqResponse = serializer.DeserializeObject(responseBody);
            string botReply = groqResponse["choices"][0]["message"]["content"].ToString();

            context.Response.Write(serializer.Serialize(new { success = true, reply = botReply }));
        }
        catch (WebException ex)
        {
            string errorDetail = ex.Message;
            if (ex.Response != null)
            {
                try
                {
                    using (var reader = new StreamReader(ex.Response.GetResponseStream(), Encoding.UTF8))
                        errorDetail = reader.ReadToEnd();
                }
                catch { }
            }
            context.Response.Write(new JavaScriptSerializer().Serialize(
                new { success = false, reply = "API Error (see details)", error = errorDetail }
            ));
        }
        catch (Exception ex)
        {
            context.Response.Write(new JavaScriptSerializer().Serialize(
                new { success = false, reply = "Server Error: " + ex.Message, error = ex.StackTrace }
            ));
        }
    }

    public bool IsReusable { get { return false; } }
}
