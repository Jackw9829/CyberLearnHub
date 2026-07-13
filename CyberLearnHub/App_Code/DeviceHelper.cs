using System.Text.RegularExpressions;
using System.Web;

namespace CyberLearnHub
{
    public static class DeviceHelper
    {
        private static readonly Regex MobileRegex = new Regex(
            @"Mobile|Android|iPhone|iPad|iPod|BlackBerry|Windows Phone",
            RegexOptions.IgnoreCase | RegexOptions.Compiled);

        public static bool IsMobileDevice(HttpRequest request)
        {
            string ua = request.UserAgent;
            return !string.IsNullOrEmpty(ua) && MobileRegex.IsMatch(ua);
        }
    }
}
