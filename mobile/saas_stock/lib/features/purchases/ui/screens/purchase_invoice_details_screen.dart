import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/features/purchases/data/models/purchase_invoice_model.dart';
import 'package:saas_stock/features/purchases/logic/cubit.dart';
import 'package:saas_stock/features/purchases/logic/states.dart';
import 'package:saas_stock/core/services/purchase_receipt_print_service.dart';

class PurchaseInvoiceDetailsScreen extends StatefulWidget {
  final int id;

  const PurchaseInvoiceDetailsScreen({super.key, required this.id});

  @override
  State<PurchaseInvoiceDetailsScreen> createState() =>
      _PurchaseInvoiceDetailsScreenState();
}

class _PurchaseInvoiceDetailsScreenState
    extends State<PurchaseInvoiceDetailsScreen> {
  late PurchasesCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<PurchasesCubit>();
    cubit.fetchPurchaseDetails(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text("تفاصيل فاتورة #${widget.id}"),
          backgroundColor: const Color(0xFF7C3AED),
          actions: [
            IconButton(
              tooltip: "تحديث",
              icon: const Icon(Icons.refresh),
              onPressed: () => cubit.fetchPurchaseDetails(widget.id),
            ),

            /// ✅ زر طباعة في الـ AppBar
            BlocBuilder<PurchasesCubit, PurchasesState>(
              builder: (context, state) {
                PurchaseInvoiceModel? invoice;

                if (state is PurchaseDetailsLoaded) invoice = state.invoice;
                if (state is PurchaseDetailsSuccess) invoice = state.invoice;

                return IconButton(
                  tooltip: "طباعة",
                  icon: const Icon(Icons.print),
                  onPressed: invoice == null
                      ? null
                      : () async {
                          await PurchaseReceiptPrintService
                              .printPurchaseReceipt(invoice!);
                        },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<PurchasesCubit, PurchasesState>(
          builder: (context, state) {
            if (state is PurchaseDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              );
            }

            if (state is PurchaseDetailsError) {
              return _ErrorDetailsView(
                message: state.message,
                onRetry: () => cubit.fetchPurchaseDetails(widget.id),
              );
            }

            PurchaseInvoiceModel? inv;

            // ✅ يدعم اسمين للـ state عندك
            if (state is PurchaseDetailsLoaded) inv = state.invoice;
            if (state is PurchaseDetailsSuccess) inv = state.invoice;

            if (inv == null) return const SizedBox.shrink();

            final date = DateFormat('dd/MM/yyyy  hh:mm a').format(inv.createdAt);

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _HeaderSummary(inv: inv, date: date),
                const SizedBox(height: 12),
                _ItemsCard(inv: inv),
                const SizedBox(height: 14),

                /// ✅ زر طباعة تحت
                _ActionsBar(
                  onBack: () => Navigator.pop(context),
                  onPrint: () async {
                    await PurchaseReceiptPrintService.printPurchaseReceipt(inv!);
                  },
                ),

                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ================= UI =================

class _HeaderSummary extends StatelessWidget {
  final PurchaseInvoiceModel inv;
  final String date;

  const _HeaderSummary({required this.inv, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.inventory_2,
                      color: Color(0xFF7C3AED)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("فاتورة مشتريات #${inv.id}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(date,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  "${inv.total} ج.م",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
            const Divider(height: 26),
            _row("المورد", inv.supplier.displayName),
            _row("طريقة الدفع", inv.paymentMethod),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? const Color(0xFF7C3AED) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final PurchaseInvoiceModel inv;

  const _ItemsCard({required this.inv});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("بنود الفاتورة",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            if (inv.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("لا يوجد بنود في هذه الفاتورة"),
              )
            else
              ...inv.items.map((i) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_bag,
                            color: Color(0xFF7C3AED)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(i.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "Qty: ${i.quantity} • Unit: ${i.unitPrice}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${i.subtotal} ج.م",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onPrint;

  const _ActionsBar({required this.onBack, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text("رجوع"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPrint,
            icon: const Icon(Icons.print),
            label: const Text("طباعة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorDetailsView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorDetailsView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة المحاولة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
