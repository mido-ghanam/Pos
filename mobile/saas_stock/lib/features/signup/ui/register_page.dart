import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/auth_otp/ui/screens/otp_screen.dart';
import 'package:saas_stock/features/signup/logic/signup_cubit.dart';
import 'package:saas_stock/features/signup/logic/signup_states.dart';
import 'package:saas_stock/features/signup/ui/widgets/already_have_acount.dart';
import 'package:saas_stock/features/signup/ui/widgets/register_form.dart';
import 'package:saas_stock/features/signup/ui/widgets/register_header.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state is RegisterSuccess) {
            // ✅ اعرض رسالة
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // ✅ وبعدها روح OTP
            Future.microtask(() {
              Navigator.pushNamed(
                context,
                Routers.otp,
                arguments: OtpArgs(
                  username: context
                      .read<RegisterCubit>()
                      .usernameController
                      .text
                      .trim(),
                  mode: OtpMode.register,
                ),
              );
            });
          }
        },
        child: Scaffold(
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        SizedBox(height: ResponsiveHelper.spacing(context, 16)),

                        // ✅ Header
                        const RegisterHeader(),

                        SizedBox(height: ResponsiveHelper.spacing(context, 32)),

                        // ✅ Form
                        const RegisterForm(),

                        SizedBox(height: ResponsiveHelper.spacing(context, 24)),

                        // ✅ Already Have Account
                        const AlreadyHaveAccountWidget(),

                        SizedBox(height: ResponsiveHelper.spacing(context, 16)),
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
