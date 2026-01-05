import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:barcode/barcode.dart';
import 'package:printing/printing.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';

class BarcodePrintService {
  /// ✅ طباعة باركود لمنتج واحد
  static Future<void> printSingleBarcode(ProductModel product) async {
    await printMultipleBarcodes([product]);
  }

  /// ✅ طباعة باركود لمجموعة منتجات
  static Future<void> printMultipleBarcodes(List<ProductModel> products) async {
    final pdf = pw.Document();

    // ✅ تحميل خط عربي
    final regularFontData =
        await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');

    final regularFont = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    // ✅ مقاس Sticker صغير (مثال 50x30 mm)
    final labelFormat = PdfPageFormat(
      50 * PdfPageFormat.mm,
      30 * PdfPageFormat.mm,
      marginAll: 2 * PdfPageFormat.mm,
    );

    for (final product in products) {
      final barcodeValue = product.barcode?.toString() ?? product.id ?? "";

      final bc = Barcode.code128();
      final svgBarcode =
          bc.toSvg(barcodeValue, width: 160, height: 50, fontHeight: 0);

      pdf.addPage(
        pw.Page(
          pageFormat: labelFormat,
          textDirection: pw.TextDirection.rtl,
          build: (_) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  product.name ?? "-",
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 9,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.SvgImage(svg: svgBarcode),
                pw.SizedBox(height: 1),
                pw.Text(
                  barcodeValue,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // ✅ الطباعة
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
}
