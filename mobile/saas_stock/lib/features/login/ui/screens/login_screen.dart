// features/login/ui/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/login/logic/login_cubit.dart';
import 'package:saas_stock/features/login/ui/screens/desktop_login.dart';
import 'package:saas_stock/features/login/ui/screens/mobile_login.dart';
import 'package:saas_stock/features/login/ui/screens/tablet_login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (ResponsiveHelper.isDesktop(context)) {
            return const DesktopLogin();
          } else if (ResponsiveHelper.isTablet(context)) {
            return const TabletLogin();
          } else {
            return const MobileLogin();
          }
        },
      ),
    );
  }
}
