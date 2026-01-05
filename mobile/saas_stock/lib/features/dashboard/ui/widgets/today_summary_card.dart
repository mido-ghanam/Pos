import 'package:flutter/material.dart';
import 'package:saas_stock/features/dashboard/data/models/dashboard_stats.dart';
import 'mini_stat_row.dart';

class TodaySummaryCard extends StatelessWidget {
  final DashboardStats stats;

  const TodaySummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ملخص اليوم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 14),

          MiniStatRow(
            icon: Icons.receipt_long,
            color: const Color(0xFF3B82F6),
            label: 'عدد الفواتير',
            value: '${stats.totalInvoicesToday}',
          ),
          const SizedBox(height: 10),

          MiniStatRow(
            icon: Icons.people,
            color: const Color(0xFF10B981),
            label: 'عملاء جدد',
            value: '${stats.newCustomersToday}',
          ),
          const SizedBox(height: 10),

          MiniStatRow(
            icon: Icons.keyboard_return,
            color: const Color(0xFFF97316),
            label: 'مرتجعات',
            value: '${stats.returnsToday}',
          ),
        ],
      ),
    );
  }
}
