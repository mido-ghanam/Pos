import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/features/auth_otp/ui/screens/otp_screen.dart';
import 'package:saas_stock/features/login/logic/login_cubit.dart';
import 'package:saas_stock/features/login/logic/login_states.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/login/ui/widgets/divider_widget.dart';
import 'package:saas_stock/features/login/ui/widgets/footer_widget.dart';
import 'package:saas_stock/features/login/ui/widgets/login_form.dart';
import 'package:saas_stock/features/login/ui/widgets/login_header.dart';
import 'package:saas_stock/features/login/ui/widgets/social_login_button.dart';

class MobileLogin extends StatelessWidget {
  const MobileLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: BlocConsumer<LoginCubit, LoginState>(

        listener: (context, state) {
          if (state is LoginOtpSent) {
            Navigator.pushNamed(
              context,
              Routers.otp,
              arguments: OtpArgs(
                username: state.username,
                mode: OtpMode.login,
              ),
            );
          }

          if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) => Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.pagePadding(context),
              child: Center(
                child: Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: ResponsiveHelper.spacing(context, 32)),
                        const LoginHeader(),
                        SizedBox(height: ResponsiveHelper.spacing(context, 48)),
                        const LoginForm(),
                        SizedBox(height: ResponsiveHelper.spacing(context, 32)),
                        const DividerWidget(),
                        SizedBox(height: ResponsiveHelper.spacing(context, 16)),
                        const SocialLoginButton(),
                        SizedBox(height: ResponsiveHelper.spacing(context, 32)),
                        const FooterWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
