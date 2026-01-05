// lib/features/auth_otp/ui/widgets/otp_timer_resend.dart
import 'dart:async';
import 'package:flutter/material.dart';

class OtpTimerResend extends StatefulWidget {
  final VoidCallback onResend;
  const OtpTimerResend({super.key, required this.onResend});

  @override
  State<OtpTimerResend> createState() => _OtpTimerResendState();
}

class _OtpTimerResendState extends State<OtpTimerResend> {
  int seconds = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    seconds = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canResend = seconds == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          canResend ? "لم يصلك الكود؟" : "إعادة الإرسال بعد",
          style: TextStyle(color: Colors.grey[700]),
        ),
        const SizedBox(width: 8),
        if (!canResend)
          Text(
            "$seconds ث",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C3AED),
            ),
          ),
        if (canResend)
          TextButton(
            onPressed: () {
              widget.onResend();
              startTimer();
            },
            child: const Text(
              "إعادة إرسال",
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
