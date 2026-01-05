import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:saas_stock/features/purchases/data/models/purchase_invoice_model.dart';

class PurchaseReceiptPrintService {
  static Future<void> printPurchaseReceipt(PurchaseInvoiceModel invoice) async {
    final pdf = pw.Document();

    final regularData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');

    final regularFont = pw.Font.ttf(regularData);
    final boldFont = pw.Font.ttf(boldData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  "POS SaaS Stock",
                  style: pw.TextStyle(font: boldFont, fontSize: 16),
                ),
              ),
              pw.SizedBox(height: 5),

              pw.Text(
                "فاتورة شراء #${invoice.id}",
                style: pw.TextStyle(font: boldFont, fontSize: 11),
              ),
              pw.Text(
                "التاريخ: ${invoice.createdAt.toString().split('.').first}",
                style: pw.TextStyle(font: regularFont, fontSize: 9),
              ),
              pw.Text(
                "المورد: ${invoice.supplier.displayName}",
                style: pw.TextStyle(font: regularFont, fontSize: 9),
              ),
              pw.Text(
                "الدفع: ${invoice.paymentMethod}",
                style: pw.TextStyle(font: regularFont, fontSize: 9),
              ),

              pw.Divider(thickness: 1),

              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      "الصنف",
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                    ),
                  ),
                  pw.Container(
                    width: 25,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      "ك",
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                    ),
                  ),
                  pw.Container(
                    width: 35,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      "سعر",
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                    ),
                  ),
                  pw.Container(
                    width: 45,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      "إجمالي",
                      style: pw.TextStyle(font: boldFont, fontSize: 10),
                    ),
                  ),
                ],
              ),

              pw.Divider(thickness: 1),

              ...invoice.items.map((item) {
                return pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        item.productName,
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ),
                    pw.Container(
                      width: 25,
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        item.quantity.toString(),
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ),
                    pw.Container(
                      width: 35,
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        item.unitPrice,
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ),
                    pw.Container(
                      width: 45,
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        item.subtotal,
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ),
                  ],
                );
              }).toList(),

              pw.Divider(thickness: 1.2),

              pw.Text(
                "الإجمالي: ${invoice.total} ج.م",
                style: pw.TextStyle(font: boldFont, fontSize: 13),
                textAlign: pw.TextAlign.right,
              ),

              pw.SizedBox(height: 10),

              pw.Center(
                child: pw.Text(
                  "شكرًا لتعاملكم معنا ❤️",
                  style: pw.TextStyle(font: regularFont, fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
}
