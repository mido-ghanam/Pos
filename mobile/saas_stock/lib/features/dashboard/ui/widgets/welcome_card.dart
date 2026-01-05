import 'package:flutter/material.dart';
import 'package:saas_stock/core/utils/responsive_helper.dart';
import 'package:saas_stock/features/dashboard/data/models/dashboard_stats.dart';
import 'chip_info.dart';
import 'welcome_illustration.dart';

class WelcomeCard extends StatelessWidget {
  final DashboardStats stats;
  const WelcomeCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final showIcon = Responsive.isTablet(context) || Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بعودتك 👋',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'تابع مبيعاتك، مخزونك، وعملاءك من مكان واحد.',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChipInfo(
                      icon: Icons.shopping_bag,
                      label: 'مبيعات اليوم',
                      value: '${stats.todaySales.toStringAsFixed(2)} ج.م',
                    ),
                    ChipInfo(
                      icon: Icons.inventory_2,
                      label: 'منتجات منخفضة',
                      value: '${stats.lowStockProducts}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 16),
            const WelcomeIllustration(),
          ]
        ],
      ),
    );
  }
}
