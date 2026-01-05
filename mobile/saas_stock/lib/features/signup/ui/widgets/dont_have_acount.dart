import 'package:flutter/material.dart';
import 'package:saas_stock/core/routing/routers.dart';

class DontHaveAccountWidget extends StatelessWidget {
  const DontHaveAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, Routers.register);
          },
          child: const Text(
            'إنشاء حساب',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C3AED),
            ),
          ),
        ),
      ],
    );
  }
}
