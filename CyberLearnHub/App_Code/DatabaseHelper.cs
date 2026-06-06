using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace CyberLearnHub
{
    /// <summary>
    /// Shared database utilities: connection factory + password hashing.
    /// The hash algorithm matches the SQL seed:
    ///   CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'password'), 2)
    /// which produces an UPPERCASE hex string with no '0x' prefix.
    /// </summary>
    public static class DatabaseHelper
    {
        // Read connection string from Web.config <connectionStrings>
        private static readonly string _connStr =
            ConfigurationManager.ConnectionStrings["CyberLearnHub"].ConnectionString;

        /// <summary>Returns an open-ready SqlConnection to CyberLearnHub.mdf.</summary>
        public static SqlConnection GetConnection()
        {
            return new SqlConnection(_connStr);
        }

        /// <summary>
        /// SHA-256 hash — returns uppercase hex to match SQL HASHBYTES output.
        /// Example: HashPassword("Admin@123") == the PasswordHash stored by the seed script.
        /// </summary>
        public static string HashPassword(string password)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder(bytes.Length * 2);
                foreach (byte b in bytes)
                    sb.Append(b.ToString("X2")); // uppercase hex, no 0x prefix
                return sb.ToString();
            }
        }
    }
}
