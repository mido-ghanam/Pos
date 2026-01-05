import 'package:flutter/material.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/core/utils/responsive_helper.dart';
import 'package:saas_stock/features/dashboard/data/models/dashboard_stats.dart';
import 'quick_action_tile.dart';

class QuickActionsSection extends StatelessWidget {
  final DashboardStats stats;

  const QuickActionsSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    // ✅ هنا تقدر تعمل actions dynamic بالـ stats لو حابب
    // مثال: عنوان "تقرير اليوم" ممكن يظهر عدد الفواتير أو المرتجعات... إلخ

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إجراءات سريعة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        if (isMobile)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.6,
            children: [
              QuickActionTile(
                label: 'مرتجعات (${stats.returnsToday})',
                icon: Icons.receipt,
                color: const Color(0xFF7C3AED),
                onTap: () => Navigator.pushNamed(context, Routers.returns),
              ),
              QuickActionTile(
                label: 'الموردين',
                icon: Icons.person_2_outlined,
                color: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, Routers.suppliers),
              ),
              QuickActionTile(
                label: 'إدارة العملاء (${stats.totalCustomers})',
                icon: Icons.people_alt,
                color: const Color(0xFF3B82F6),
                onTap: () => Navigator.pushNamed(context, Routers.customers),
              ),
              QuickActionTile(
                label: 'تقرير اليوم (${stats.totalInvoicesToday})',
                icon: Icons.assessment,
                color: const Color(0xFFF97316),
                onTap: () => Navigator.pushNamed(context, Routers.reports),
              ),
            ],
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              QuickActionTile(
                label: 'فاتورة جديدة',
                icon: Icons.point_of_sale,
                color: const Color(0xFF7C3AED),
                onTap: () => Navigator.pushNamed(context, Routers.sales),
              ),
              QuickActionTile(
                label: 'إضافة منتج',
                icon: Icons.add_box,
                color: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, Routers.addProduct),
              ),
              QuickActionTile(
                label: 'إدارة العملاء (${stats.totalCustomers})',
                icon: Icons.people_alt,
                color: const Color(0xFF3B82F6),
                onTap: () => Navigator.pushNamed(context, Routers.customers),
              ),
              QuickActionTile(
                label: 'تقرير اليوم (${stats.totalInvoicesToday})',
                icon: Icons.assessment,
                color: const Color(0xFFF97316),
                onTap: () => Navigator.pushNamed(context, Routers.reports),
              ),
            ],
          ),
      ],
    );
  }
}
