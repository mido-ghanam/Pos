import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/auth_otp/logic/otp_cubit.dart';
import 'package:saas_stock/features/auth_otp/logic/otp_states.dart';
import '../widgets/otp_form.dart';
import '../widgets/otp_header.dart';

enum OtpMode { login, register }

class OtpArgs {
  final String username;
  final OtpMode mode;
  const OtpArgs({required this.username, required this.mode});
}

class OtpScreen extends StatelessWidget {
  final OtpArgs? args;
  const OtpScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final username = args?.username ?? '';
    final mode = args?.mode ?? OtpMode.login;

    return BlocProvider(
      create: (_) => getIt<OtpCubit>(),
      child: BlocConsumer<OtpCubit, OtpState>(
        listener: (context, state) {
          if (state is OtpError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
          if (state is OtpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is OtpLoading;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                  mode == OtpMode.login ? 'تأكيد تسجيل الدخول' : 'تأكيد الحساب'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.pagePadding(context),
                child: Center(
                  child: Container(
                    width: 420,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          OtpHeader(username: username, mode: mode),
                          SizedBox(height: ResponsiveHelper.spacing(context, 28)),
                          OtpForm(
                            username: username,
                            mode: mode,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
