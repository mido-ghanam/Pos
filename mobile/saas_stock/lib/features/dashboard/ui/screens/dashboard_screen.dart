import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/utils/responsive_helper.dart';
import 'package:saas_stock/features/dashboard/logic/cubit.dart';
import 'package:saas_stock/features/dashboard/logic/dashboard_stats.dart/dasg_cubit.dart';
import 'package:saas_stock/features/dashboard/logic/dashboard_stats.dart/dash_stats.dart';

import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/features/dashboard/logic/states.dart';

import '../widgets/dashboard_app_bar.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/welcome_summary_section.dart';
import '../widgets/statistics_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<DashboardCubit>()..loadDashboard()),
        BlocProvider(create: (_) => getIt<LogoutCubit>()),
      ],
      child: BlocListener<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess || state is LogoutError) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routers.login,
              (_) => false,
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: const DashboardAppBar(),
          body: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DashboardError) {
                return Center(child: Text(state.message));
              }

              if (state is DashboardLoaded) {
                final stats = state.stats;

                return SingleChildScrollView(
                  padding: padding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          QuickActionsSection(stats: stats),
                          const SizedBox(height: 16),
                          WelcomeSummarySection(stats: stats),
                          const SizedBox(height: 16),
                          StatisticsSection(stats: stats),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
