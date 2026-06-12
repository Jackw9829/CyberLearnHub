<%@ WebHandler Language="C#" Class="ChatbotHandler" %>

using System;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Configuration;
using System.Text.RegularExpressions;

public class ChatbotHandler : IHttpHandler
{
    // API key stored safely in Web.config <appSettings>
    string apiKey = ConfigurationManager.AppSettings["GroqApiKey"];

    private const string API_URL = "https://api.groq.com/openai/v1/chat/completions";

    // Strict system prompt — orders the model to refuse off-topic questions
    private const string SYSTEM_PROMPT =
        "You are CyberBot, a strict cybersecurity-only assistant for CyberLearn Hub, " +
        "an e-learning platform at Asia Pacific University (APU). " +
        "You ONLY answer questions related to cybersecurity topics such as: " +
        "network security, ethical hacking, penetration testing, malware, encryption, " +
        "firewalls, OWASP Top 10, CTF challenges, phishing, social engineering, " +
        "vulnerability assessment, digital forensics, cryptography, secure coding, " +
        "authentication, authorization, and cybersecurity tools. " +
        "If the user asks about ANYTHING outside cybersecurity, you MUST reply with exactly: " +
        "\"I can only answer cybersecurity-related questions. Please ask me something about cybersecurity!\" " +
        "Do NOT answer general knowledge, entertainment, food, sports, math, translations, " +
        "or any other off-topic subject under any circumstances. " +
        "Keep answers clear, concise, and beginner-friendly. Use bullet points when listing.";

    // ── LAYER 1a: Cybersecurity keyword whitelist ─────────────────────────────
    private static readonly string[] CyberKeywords = new string[]
    {
        "cyber", "security", "hack", "hacking", "hacker", "pentest", "penetration",
        "exploit", "vulnerability", "vuln", "malware", "ransomware", "virus", "trojan",
        "phishing", "social engineer", "firewall", "encryption", "decrypt", "cryptograph",
        "password", "authentication", "authoriz", "2fa", "mfa", "otp", "token",
        "owasp", "xss", "sql injection", "sqli", "csrf", "rce", "lfi", "rfi",
        "buffer overflow", "privilege escalation", "reverse shell", "payload",
        "nmap", "metasploit", "burp", "wireshark", "kali", "ctf", "capture the flag",
        "forensic", "incident response", "threat", "attack", "ddos", "dos",
        "brute force", "dictionary attack", "zero day", "0day", "patch", "cve",
        "vpn", "proxy", "tor", "anonymi", "network", "packet", "sniff", "spoof",
        "mitm", "man in the middle", "arp", "dns", "ssl", "tls", "https", "certificate",
        "sandbox", "antivirus", "edr", "siem", "soc", "ids", "ips", "waf",
        "secure coding", "devsecops", "nist", "iso 27001", "gdpr",
        "data breach", "leak", "dark web", "osint", "recon", "reconnaissance",
        "port scan", "enumeration", "footprint", "steganograph", "keylogger",
        "rootkit", "botnet", "command and control", "c2", "lateral movement",
        "persistence", "exfiltration", "blue team", "red team", "purple team",
        "cyber hygiene", "security awareness", "risk", "compliance",
        "idor", "ssti", "jwt", "oauth", "saml", "ldap", "ssrf", "xxe"
    };

    // ── LAYER 1b: Obvious off-topic blacklist (blocked before API is called) ──
    private static readonly string[] OffTopicKeywords = new string[]
    {
        "recipe", "cook", "food", "restaurant", "movie", "film", "actor", "actress",
        "sport", "football", "soccer", "basketball", "cricket", "tennis",
        "music", "song", "singer", "celebrity", "weather", "forecast",
        "stock market", "share price", "bitcoin price", "crypto price",
        "joke", "funny", "meme", "love", "relationship", "dating",
        "write my essay", "do my assignment", "do my homework",
        "translate this", "grammar check", "spell check",
        "travel", "hotel", "flight booking", "visa application",
        "who is the president", "prime minister", "politician",
        "math problem", "solve equation", "calculate for me"
    };

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.AddHeader("Cache-Control", "no-cache");

        var serializer = new JavaScriptSerializer();
        serializer.MaxJsonLength = Int32.MaxValue;

        try
        {
            // ── Read user message ─────────────────────────────────────────────
            string requestBody;
            using (var reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
                requestBody = reader.ReadToEnd();

            dynamic requestData = serializer.DeserializeObject(requestBody);
            string userMessage = requestData["message"].ToString().Trim();

            if (string.IsNullOrEmpty(userMessage))
            {
                context.Response.Write(serializer.Serialize(new
                {
                    success = false,
                    reply = "Please type a question first."
                }));
                return;
            }

            // ── LAYER 1: Server-side keyword check (no API call needed) ───────
            string lowerMsg = userMessage.ToLower();

            bool hasCyberKeyword = false;
            foreach (var kw in CyberKeywords)
            {
                if (lowerMsg.Contains(kw)) { hasCyberKeyword = true; break; }
            }

            bool isObviouslyOffTopic = false;
            foreach (var kw in OffTopicKeywords)
            {
                if (lowerMsg.Contains(kw)) { isObviouslyOffTopic = true; break; }
            }

            // Block if obviously off-topic AND no cyber keyword redeems it
            if (isObviouslyOffTopic && !hasCyberKeyword)
            {
                context.Response.Write(serializer.Serialize(new
                {
                    success = true,
                    reply = "I can only answer cybersecurity-related questions. Please ask me something about cybersecurity!",
                    blocked = true
                }));
                return;
            }

            // Block very short messages with no cyber keyword (but allow greetings)
            bool isGreeting = Regex.IsMatch(lowerMsg,
                @"^(hi|hello|hey|help|what|how|why|who|is|are|can|tell|explain)");

            if (!hasCyberKeyword && userMessage.Split(' ').Length <= 3 && !isGreeting)
            {
                context.Response.Write(serializer.Serialize(new
                {
                    success = true,
                    reply = "I can only answer cybersecurity-related questions. Please ask me something about cybersecurity!",
                    blocked = true
                }));
                return;
            }

            // ── LAYER 2: Call Groq API (system prompt acts as second filter) ──
            // Sanitize for JSON (same as your original code)
            string safeMessage = userMessage
                .Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\r", "\\r").Replace("\n", "\\n").Replace("\t", "\\t");

            string safeSystem = SYSTEM_PROMPT
                .Replace("\\", "\\\\").Replace("\"", "\\\"");

            string jsonPayload =
                "{" +
                  "\"model\": \"llama-3.1-8b-instant\"," +
                  "\"max_tokens\": 1024," +
                  "\"temperature\": 0.4," +
                  "\"messages\": [" +
                    "{\"role\": \"system\", \"content\": \"" + safeSystem + "\"}," +
                    "{\"role\": \"user\",   \"content\": \"" + safeMessage + "\"}" +
                  "]" +
                "}";

            // Force TLS 1.2 (same as your original code)
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            var webRequest = (HttpWebRequest)WebRequest.Create(API_URL);
            webRequest.Method = "POST";
            webRequest.ContentType = "application/json";
            webRequest.Accept = "application/json";
            webRequest.Timeout = 30000;
            webRequest.Headers.Add("Authorization", "Bearer " + apiKey);

            byte[] data = Encoding.UTF8.GetBytes(jsonPayload);
            webRequest.ContentLength = data.Length;

            using (var stream = webRequest.GetRequestStream())
                stream.Write(data, 0, data.Length);

            string responseBody;
            using (var webResponse = (HttpWebResponse)webRequest.GetResponse())
            using (var reader = new StreamReader(webResponse.GetResponseStream(), Encoding.UTF8))
                responseBody = reader.ReadToEnd();

            dynamic groqResponse = serializer.DeserializeObject(responseBody);
            string botReply = groqResponse["choices"][0]["message"]["content"].ToString();

            // ── LAYER 3: Check if the model itself flagged it as off-topic ────
            bool apiBlocked = botReply.Contains("I can only answer cybersecurity-related questions");

            context.Response.Write(serializer.Serialize(new
            {
                success = true,
                reply = botReply,
                blocked = apiBlocked
            }));
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
