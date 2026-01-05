import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/features/reports/logic/cubit.dart';
import 'package:saas_stock/features/reports/logic/states.dart';
import 'package:saas_stock/features/purchases/ui/screens/purchase_invoice_details_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final periods = const [
    ("today", "اليوم"),
    ("week", "أسبوع"),
    ("month", "شهر"),
    ("year", "سنة"),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportsCubit>()..loadReports(period: "today"),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("التقارير"),
          backgroundColor: const Color(0xFF7C3AED),
          bottom: TabBar(
            controller: _tab,
            tabs: const [
              Tab(text: "المبيعات"),
              Tab(text: "المشتريات"),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF3F4F6),
        body: BlocBuilder<ReportsCubit, ReportsState>(
          builder: (context, state) {
            if (state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReportsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ReportsCubit>().loadReports(),
                      child: const Text("إعادة المحاولة"),
                    )
                  ],
                ),
              );
            }

            if (state is ReportsLoaded) {
              return Column(
                children: [
                  const SizedBox(height: 10),

                  // ✅ Period selector
                  _PeriodSelector(
                    periods: periods,
                    selected: state.period,
                    onChanged: (p) =>
                        context.read<ReportsCubit>().loadReports(period: p),
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        _SalesTab(data: state.sales),
                        _PurchasesTab(data: state.purchases),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ====================== Period selector ======================

class _PeriodSelector extends StatelessWidget {
  final List<(String, String)> periods;
  final String selected;
  final Function(String period) onChanged;

  const _PeriodSelector({
    required this.periods,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final p = periods[i].$1;
          final label = periods[i].$2;
          final active = p == selected;

          return ChoiceChip(
            selected: active,
            label: Text(label),
            onSelected: (_) => onChanged(p),
            selectedColor: const Color(0xFF7C3AED),
            labelStyle:
                TextStyle(color: active ? Colors.white : Colors.black87),
          );
        },
      ),
    );
  }
}

// ====================== Sales tab ======================

class _SalesTab extends StatelessWidget {
  final dynamic data;
  const _SalesTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final dateFrom = DateFormat("dd/MM/yyyy").format(data.from.toLocal());
    final dateTo = DateFormat("dd/MM/yyyy").format(data.to.toLocal());

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SummaryCard(
          title: "ملخص المبيعات",
          totalInvoices: data.totalInvoices,
          totalAmount: data.totalSales,
          from: dateFrom,
          to: dateTo,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 10),
        ...data.invoices.map<Widget>((inv) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              title: Text("فاتورة #${inv.id}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  Text("العميل: ${inv.customer.name} • ${inv.paymentMethod}"),
              trailing: Text(inv.total,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("افتح تفاصيل فاتورة المبيعات #${inv.id}")),
                );

                // ✅ لو عندك شاشة تفاصيل المبيعات غير السطر ده:
                // Navigator.push(context,
                //   MaterialPageRoute(builder: (_) => SaleDetailsScreen(id: inv.id)),
                // );
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}

// ====================== Purchases tab ======================

class _PurchasesTab extends StatelessWidget {
  final dynamic data;
  const _PurchasesTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final dateFrom = DateFormat("dd/MM/yyyy").format(data.from.toLocal());
    final dateTo = DateFormat("dd/MM/yyyy").format(data.to.toLocal());

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SummaryCard(
          title: "ملخص المشتريات",
          totalInvoices: data.totalInvoices,
          totalAmount: data.totalPurchases,
          from: dateFrom,
          to: dateTo,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 10),
        ...data.invoices.map<Widget>((inv) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              title: Text("فاتورة #${inv.id}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "المورد: ${inv.supplier.displayName} • ${inv.paymentMethod}"),
              trailing: Text(inv.total,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PurchaseInvoiceDetailsScreen(id: inv.id),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}

// ====================== Summary Card ======================

class _SummaryCard extends StatelessWidget {
  final String title;
  final int totalInvoices;
  final double totalAmount;
  final String from;
  final String to;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.totalInvoices,
    required this.totalAmount,
    required this.from,
    required this.to,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _tile("عدد الفواتير", "$totalInvoices")),
              Expanded(
                child: _tile(
                  "الإجمالي",
                  "${totalAmount.toStringAsFixed(2)} ج.م",
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text("من: $from"),
          Text("إلى: $to"),
        ],
      ),
    );
  }

  Widget _tile(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
