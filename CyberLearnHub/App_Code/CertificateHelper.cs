using System;
using System.IO;
using iTextSharp.text;
using iTextSharp.text.pdf;

public static class CertificateHelper
{
    public static string Generate(string userName, string courseName,
                                   int percentage, DateTime issuedDate,
                                   string certificatesPhysicalDir)
    {
        Directory.CreateDirectory(certificatesPhysicalDir);

        string guid     = Guid.NewGuid().ToString("N").Substring(0, 12).ToUpper();
        string fileName = guid + ".pdf";
        string fullPath = Path.Combine(certificatesPhysicalDir, fileName);

        var pageSize = PageSize.A4.Rotate();
        using (var doc = new Document(pageSize, 50, 50, 50, 50))
        using (var fs  = new FileStream(fullPath, FileMode.Create, FileAccess.Write))
        {
            var writer = PdfWriter.GetInstance(doc, fs);
            doc.Open();

            var cb = writer.DirectContent;

            // Dark background
            cb.SetColorFill(new BaseColor(8, 13, 20));
            cb.Rectangle(0, 0, pageSize.Width, pageSize.Height);
            cb.Fill();

            // Cyan border
            cb.SetColorStroke(new BaseColor(0, 212, 255));
            cb.SetLineWidth(2.5f);
            cb.Rectangle(20, 20, pageSize.Width - 40, pageSize.Height - 40);
            cb.Stroke();

            // Inner border
            cb.SetColorStroke(new BaseColor(0, 100, 130));
            cb.SetLineWidth(0.5f);
            cb.Rectangle(28, 28, pageSize.Width - 56, pageSize.Height - 56);
            cb.Stroke();

            // Corner accents
            DrawCornerAccent(cb, 20, 20, true,  true);
            DrawCornerAccent(cb, pageSize.Width - 20, 20, false, true);
            DrawCornerAccent(cb, 20, pageSize.Height - 20, true,  false);
            DrawCornerAccent(cb, pageSize.Width - 20, pageSize.Height - 20, false, false);

            // Header tag
            var monoSmall = FontFactory.GetFont(FontFactory.COURIER, 9, new BaseColor(0, 212, 255));
            AddCenteredText(doc, writer, "// CYBERLEARN HUB", monoSmall, pageSize.Height - 80);

            // Title
            var titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 36, new BaseColor(232, 244, 255));
            AddCenteredText(doc, writer, "Certificate of Achievement", titleFont, pageSize.Height - 120);

            // Divider line
            cb.SetColorStroke(new BaseColor(0, 212, 255));
            cb.SetLineWidth(1f);
            cb.MoveTo(pageSize.Width / 2 - 160, pageSize.Height - 142);
            cb.LineTo(pageSize.Width / 2 + 160, pageSize.Height - 142);
            cb.Stroke();

            // "This certifies that"
            var bodySmall = FontFactory.GetFont(FontFactory.HELVETICA, 12, new BaseColor(90, 122, 153));
            AddCenteredText(doc, writer, "This certifies that", bodySmall, pageSize.Height - 175);

            // Student name
            var nameFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 28, new BaseColor(0, 212, 255));
            AddCenteredText(doc, writer, userName, nameFont, pageSize.Height - 215);

            // "has successfully completed"
            AddCenteredText(doc, writer, "has successfully completed", bodySmall, pageSize.Height - 250);

            // Course name
            var courseFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 18, new BaseColor(0, 255, 157));
            AddCenteredText(doc, writer, courseName, courseFont, pageSize.Height - 285);

            // Score and date
            var scoreFont = FontFactory.GetFont(FontFactory.HELVETICA, 13, new BaseColor(200, 223, 240));
            AddCenteredText(doc, writer,
                string.Format("with a score of {0}%   |   Issued {1}",
                    percentage, issuedDate.ToString("dd MMMM yyyy")),
                scoreFont, pageSize.Height - 322);

            // Footer cert ID
            var footerFont = FontFactory.GetFont(FontFactory.COURIER, 8, new BaseColor(26, 48, 80));
            AddCenteredText(doc, writer, "Certificate ID: " + guid, footerFont, 42);

            doc.Close();
        }
        return "~/Uploads/Certificates/" + fileName;
    }

    private static void AddCenteredText(Document doc, PdfWriter writer,
        string text, Font font, float y)
    {
        var cb   = writer.DirectContent;
        var bf   = font.BaseFont;
        if (bf == null)
            bf = BaseFont.CreateFont(BaseFont.HELVETICA, BaseFont.CP1252, false);
        float size = font.Size > 0 ? font.Size : 12;
        cb.BeginText();
        cb.SetFontAndSize(bf, size);
        cb.SetColorFill(font.Color ?? BaseColor.WHITE);
        float w = bf.GetWidthPoint(text, size);
        cb.SetTextMatrix((doc.PageSize.Width - w) / 2, y);
        cb.ShowText(text);
        cb.EndText();
    }

    private static void DrawCornerAccent(PdfContentByte cb, float x, float y,
        bool left, bool bottom)
    {
        float len = 20f;
        cb.SetColorStroke(new BaseColor(0, 212, 255));
        cb.SetLineWidth(2f);
        float dx = left ? 1 : -1;
        float dy = bottom ? 1 : -1;
        cb.MoveTo(x, y + dy * len);
        cb.LineTo(x, y);
        cb.LineTo(x + dx * len, y);
        cb.Stroke();
    }
}
