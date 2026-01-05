// lib/features/auth_otp/ui/widgets/otp_header.dart
import 'package:flutter/material.dart';
import 'package:saas_stock/features/auth_otp/ui/screens/otp_screen.dart';

class OtpHeader extends StatelessWidget {
  final String username;
  final OtpMode mode;

  const OtpHeader({
    super.key,
    required this.username,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_outlined,
            size: 42,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          mode == OtpMode.login ? 'تحقق من تسجيل الدخول' : 'تحقق من إنشاء الحساب',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل كود التحقق المرسل إلى المستخدم: $username',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
