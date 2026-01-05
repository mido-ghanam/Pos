// form_panel.dart ✅ محدث
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/features/auth_otp/ui/screens/otp_screen.dart';
import 'package:saas_stock/features/login/logic/login_cubit.dart';
import 'package:saas_stock/features/login/logic/login_states.dart';
import 'package:saas_stock/features/login/ui/widgets/divider_widget.dart';
import 'package:saas_stock/features/login/ui/widgets/footer_widget.dart';
import 'package:saas_stock/features/login/ui/widgets/login_form.dart';
import 'package:saas_stock/features/login/ui/widgets/social_login_button.dart';

class FormPanel extends StatelessWidget {
  const FormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
  if (state is LoginOtpSent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: Colors.green,
      ),
    );

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
      SnackBar(
        content: Text(state.error),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }
},
  builder: (context, state) {
        return Container(
          color: const Color(0xFFF9FAFB),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(48),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'مرحباً بعودتك! يرجى إدخال بياناتك',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),
                    const LoginForm(),
                    const SizedBox(height: 32),
                    const DividerWidget(),
                    const SizedBox(height: 24),
                    const SocialLoginButton(),
                    const SizedBox(height: 24),
                    const FooterWidget(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
