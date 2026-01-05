import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/sales/logic/states.dart';
import 'package:saas_stock/features/sales/ui/screens/sale_details_screen.dart';

class CustomerSalesInvoicesScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerSalesInvoicesScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CustomerSalesInvoicesScreen> createState() =>
      _CustomerSalesInvoicesScreenState();
}

class _CustomerSalesInvoicesScreenState
    extends State<CustomerSalesInvoicesScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ load invoices for customer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesCubit>().loadSalesByCustomer(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("فواتير ${widget.customerName}"),
        backgroundColor: const Color(0xFF7C3AED),
        actions: [
          IconButton(
            tooltip: "تحديث",
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<SalesCubit>()
                .loadSalesByCustomer(widget.customerId),
          ),
        ],
      ),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is CustomerInvoicesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
            );
          }

          if (state is CustomerInvoicesError) {
            return _ErrorView(
              message: state.error,
              onRetry: () => context
                  .read<SalesCubit>()
                  .loadSalesByCustomer(widget.customerId),
            );
          }

          if (state is CustomerInvoicesLoaded) {
            final data = state.data;

            if (data.invoices.isEmpty) {
              return const Center(child: Text("لا توجد فواتير لهذا العميل"));
            }

            return Column(
              children: [
                _summaryBar(
                  totalInvoices: data.totalInvoices,
                  totalSales: data.totalSales,
                ),
                const Divider(height: 1),
                Expanded(
                  child: isDesktop
                      ? _buildDesktopTable(data.invoices)
                      : _buildMobileList(data.invoices),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ================= Summary =================

  Widget _summaryBar({required int totalInvoices, required double totalSales}) {
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
            child: _summaryCard(
              title: 'عدد الفواتير',
              value: totalInvoices.toString(),
              icon: Icons.receipt_long,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              title: 'إجمالي المبيعات',
              value: '${totalSales.toStringAsFixed(2)} ج.م',
              icon: Icons.attach_money,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF7C3AED)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= Desktop =================

  Widget _buildDesktopTable(List invoices) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Card(
            elevation: 1.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _desktopHeader(),
                Expanded(
                  child: ListView.separated(
                    itemCount: invoices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final inv = invoices[i];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SaleDetailsScreen(invoiceId: inv.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Text('#${inv.id}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(inv.paymentMethod)),
                              Expanded(
                                  flex: 3,
                                  child: Text(inv.createdAt
                                      .toString()
                                      .split('.')
                                      .first)),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${inv.total} ج.م',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7C3AED)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _desktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.07),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 1,
              child:
                  Text('رقم', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child:
                  Text('الدفع', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child: Text('التاريخ',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('الإجمالي',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 26),
        ],
      ),
    );
  }

  // ================= Mobile =================

  Widget _buildMobileList(List invoices) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final inv = invoices[i];
        return Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF7C3AED).withOpacity(0.12),
              child: const Icon(Icons.receipt_long, color: Color(0xFF7C3AED)),
            ),
            title: Text(
              'فاتورة #${inv.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
                '${inv.paymentMethod} • ${inv.createdAt.toString().split(".").first}'),
            trailing: Text(
              '${inv.total} ج.م',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SaleDetailsScreen(invoiceId: inv.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ================= Error Widget =================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
