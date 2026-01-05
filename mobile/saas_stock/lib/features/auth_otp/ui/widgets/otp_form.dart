import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/auth_otp/logic/otp_cubit.dart';
import 'package:saas_stock/features/auth_otp/ui/screens/otp_screen.dart';
import 'otp_timer_resend.dart';
import 'otp_verify_button.dart';

class OtpForm extends StatelessWidget {
  final String username;
  final OtpMode mode;
  final bool isLoading;

  const OtpForm({
    super.key,
    required this.username,
    required this.mode,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OtpCubit>();

    return Column(
      children: [
        TextFormField(
          controller: cubit.otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
          decoration: const InputDecoration(
            hintText: 'ــــــ',
            counterText: '',
            prefixIcon: Icon(Icons.lock_clock_outlined),
            contentPadding: EdgeInsets.symmetric(vertical: 18),
          ),
        ),

        SizedBox(height: ResponsiveHelper.spacing(context, 20)),

        OtpVerifyButton(
          isLoading: isLoading,
          onPressed: () {
            cubit.verifyOtp(
              context: context,
              username: username,
              mode: mode,
            );
          },
        ),

        SizedBox(height: ResponsiveHelper.spacing(context, 18)),

        OtpTimerResend(
          onResend: () {
            cubit.resendOtp(username: username, mode: mode);
          },
        ),

        SizedBox(height: ResponsiveHelper.spacing(context, 12)),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "تغيير المستخدم",
            style: TextStyle(
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
