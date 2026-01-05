import 'package:flutter/material.dart';
import 'package:saas_stock/core/utils/responsive_helper.dart';
import 'package:saas_stock/features/dashboard/data/models/dashboard_stats.dart';

import 'welcome_card.dart';
import 'today_summary_card.dart';

class WelcomeSummarySection extends StatelessWidget {
  final DashboardStats stats;

  const WelcomeSummarySection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    if (!isDesktop) {
      return Column(
        children: [
          WelcomeCard(stats: stats),
          const SizedBox(height: 12),
          TodaySummaryCard(stats: stats),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(flex: 3, child: WelcomeCard(stats: stats)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: TodaySummaryCard(stats: stats)),
        ],
      ),
    );
  }
}
