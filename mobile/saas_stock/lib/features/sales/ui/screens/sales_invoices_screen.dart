import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/sales/logic/states.dart';
import 'package:saas_stock/features/sales/ui/screens/sale_details_screen.dart';

class SalesInvoicesScreen extends StatefulWidget {
  const SalesInvoicesScreen({super.key});

  @override
  State<SalesInvoicesScreen> createState() => _SalesInvoicesScreenState();
}

class _SalesInvoicesScreenState extends State<SalesInvoicesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final salesCubit = context.read<SalesCubit>();

    return BlocProvider.value(
      value: salesCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('فواتير المبيعات'),
          backgroundColor: const Color(0xFF7C3AED),
          actions: [
            IconButton(
              onPressed: () => salesCubit.loadSales(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, state) {
            if (state is SalesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              );
            }

            if (state is SalesError) {
              return Center(
                child: Text(state.error),
              );
            }

            final data = salesCubit.salesList;
            if (data == null) {
              return const SizedBox.shrink();
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
          },
        ),
      ),
    );
  }

  Widget _summaryBar({required int totalInvoices, required double totalSales}) {
    return Container(
      padding: const EdgeInsets.all(14),
      color: Colors.white,
      child: Row(
        children: [
          _summaryCard(
            title: 'عدد الفواتير',
            value: totalInvoices.toString(),
            icon: Icons.receipt_long,
          ),
          const SizedBox(width: 10),
          _summaryCard(
            title: 'إجمالي المبيعات',
            value: '${totalSales.toStringAsFixed(2)} ج.م',
            icon: Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      {required String title, required String value, required IconData icon}) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTable(invoices) {
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
                          final cubit = context.read<SalesCubit>();
                          cubit.loadSaleDetails(inv.id);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: SaleDetailsScreen(invoiceId: inv.id),
                              ),
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
                              Expanded(flex: 3, child: Text(inv.customer.name)),
                              Expanded(flex: 2, child: Text(inv.paymentMethod)),
                              Expanded(
                                  flex: 2,
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
              flex: 3,
              child: Text('العميل',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child:
                  Text('الدفع', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
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

  Widget _buildMobileList(invoices) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: ListView.separated(
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
              title: Text('فاتورة #${inv.id} - ${inv.customer.name}',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  '${inv.paymentMethod} • ${inv.createdAt.toString().split('.').first}'),
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
      ),
    );
  }
}
