import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/features/purchases/logic/cubit.dart';
import 'package:saas_stock/features/purchases/logic/states.dart';
import 'purchase_invoice_details_screen.dart';

class PurchasesInvoicesScreen extends StatefulWidget {
  const PurchasesInvoicesScreen({super.key});

  @override
  State<PurchasesInvoicesScreen> createState() => _PurchasesInvoicesScreenState();
}

class _PurchasesInvoicesScreenState extends State<PurchasesInvoicesScreen> {
  late PurchasesCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<PurchasesCubit>();
    cubit.fetchPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('فواتير المشتريات'),
          backgroundColor: const Color(0xFF7C3AED),
          actions: [
            IconButton(
              tooltip: "تحديث",
              onPressed: () => cubit.fetchPurchases(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<PurchasesCubit, PurchasesState>(
          builder: (context, state) {
            if (state is PurchasesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              );
            }

            if (state is PurchasesError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => cubit.fetchPurchases(),
              );
            }

            if (state is PurchasesLoaded) {
              final data = state.data;

              if (data.invoices.isEmpty) {
                return const Center(child: Text("لا توجد فواتير مشتريات"));
              }

              return Column(
                children: [
                  _SummaryHeader(
                    totalInvoices: data.totalInvoices,
                    totalPurchases: data.totalPurchases,
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: data.invoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final inv = data.invoices[i];

                        return _InvoiceCard(
                          id: inv.id,
                          name: inv.supplier.displayName,
                          total: inv.total,
                          payment: inv.paymentMethod,
                          date: inv.createdAt,
                          itemsCount: inv.items.length,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PurchaseInvoiceDetailsScreen(id: inv.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int totalInvoices;
  final double totalPurchases;

  const _SummaryHeader({
    required this.totalInvoices,
    required this.totalPurchases,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryTile(
              title: "عدد الفواتير",
              value: totalInvoices.toString(),
              icon: Icons.receipt_long,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _summaryTile(
              title: "إجمالي المشتريات",
              value: "${totalPurchases.toStringAsFixed(2)} ج.م",
              icon: Icons.inventory_2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF7C3AED)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final int id;
  final String name;
  final String total;
  final String payment;
  final DateTime date;
  final int itemsCount;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.id,
    required this.name,
    required this.total,
    required this.payment,
    required this.date,
    required this.itemsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy  hh:mm a').format(date);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long,
                        color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "فاتورة #$id",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Text(
                    total,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("المورد: $name",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text("عدد البنود: $itemsCount",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 6),
              Text("طريقة الدفع: $payment",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 6),
              Text(formattedDate,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

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
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
              child: const Text("إعادة المحاولة"),
            )
          ],
        ),
      ),
    );
  }
}
