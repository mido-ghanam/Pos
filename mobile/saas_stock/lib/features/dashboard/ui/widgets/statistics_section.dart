import 'package:flutter/material.dart';
import 'package:saas_stock/core/utils/responsive_helper.dart';
import 'package:saas_stock/features/dashboard/data/models/dashboard_stats.dart';
import 'stat_card.dart';

class StatisticsSection extends StatelessWidget {
  final DashboardStats stats;

  const StatisticsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        'title': 'مبيعات اليوم',
        'value': '${stats.todaySales.toStringAsFixed(2)} ج.م',
        'icon': Icons.trending_up,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'عدد الفواتير اليوم',
        'value': '${stats.totalInvoicesToday}',
        'icon': Icons.receipt_long,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'إجمالي المخزون',
        'value': '${stats.totalProducts} منتج',
        'icon': Icons.inventory_2,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'إجمالي العملاء',
        'value': '${stats.totalCustomers}',
        'icon': Icons.people,
        'color': const Color(0xFFEC4899),
      },
    ];

    final columns = Responsive.gridCount(context, mobile: 2, tablet: 3, desktop: 4);
    final ratio = Responsive.gridRatio(context, mobile: 1.35, tablet: 1.8, desktop: 2.3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: ratio,
      ),
      itemBuilder: (context, index) {
        final item = cards[index];
        return StatCard(
          title: item['title'] as String,
          value: item['value'] as String,
          icon: item['icon'] as IconData,
          color: item['color'] as Color,
        );
      },
    );
  }
}
