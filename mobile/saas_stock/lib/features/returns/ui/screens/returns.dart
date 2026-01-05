import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/returns/logic/cubit.dart';
import 'package:saas_stock/features/returns/logic/states.dart';
import 'return_create_screen.dart';

class ReturnsHomeScreen extends StatefulWidget {
  const ReturnsHomeScreen({super.key});

  @override
  State<ReturnsHomeScreen> createState() => _ReturnsHomeScreenState();
}

class _ReturnsHomeScreenState extends State<ReturnsHomeScreen> {
  late final ReturnsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<ReturnsCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.loadRefunds();
    });
  }
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final cubit = context.read<ReturnsCubit>();

    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المرتجعات'),
          backgroundColor: const Color(0xFFFB7185),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => cubit.loadRefunds(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFFB7185),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "إنشاء مرتجع",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            final ok = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReturnCreateScreen()),
            );
            if (ok == true) cubit.loadRefunds();
          },
        ),
        body: BlocBuilder<ReturnsCubit, ReturnsState>(
          builder: (context, state) {
            if (state is ReturnsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReturnsError) {
              return Center(child: Text(state.message));
            }

            final data = cubit.refunds;
            if (data == null || data.invoices.isEmpty) {
              return _empty();
            }

            return Column(
              children: [
                _summary(data.totalInvoices, data.totalReturns),
                Expanded(
                  child: isDesktop
                      ? _desktopList(data.invoices)
                      : _mobileList(data.invoices),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summary(int totalInvoices, double totalReturns) {
    return Container(
      padding: const EdgeInsets.all(14),
      color: const Color(0xFFFB7185).withOpacity(0.06),
      child: Row(
        children: [
          Expanded(
            child: _summaryBox("عدد المرتجعات", "$totalInvoices"),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryBox("إجمالي المرتجعات", "${totalReturns.toStringAsFixed(2)} ج.م"),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.undo, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text("لا توجد مرتجعات", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _desktopList(List invoices) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              itemCount: invoices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final inv = invoices[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFB7185).withOpacity(0.15),
                    child: const Icon(Icons.undo, color: Color(0xFFFB7185)),
                  ),
                  title: Text("مرتجع #${inv.id} - ${inv.partnerType == "sale" ? "مبيعات" : "مشتريات"}"),
                  subtitle: Text(inv.partyName),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${inv.total} ج.م",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFB7185))),
                      const SizedBox(height: 2),
                      Text(inv.createdAtFormatted,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileList(List invoices) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final inv = invoices[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFB7185).withOpacity(0.15),
              child: const Icon(Icons.undo, color: Color(0xFFFB7185)),
            ),
            title: Text("مرتجع #${inv.id}"),
            subtitle: Text("${inv.partnerType == "sale" ? "مبيعات" : "مشتريات"} - ${inv.partyName}"),
            trailing: Text("${inv.total} ج.م",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFFB7185))),
          ),
        );
      },
    );
  }
}
