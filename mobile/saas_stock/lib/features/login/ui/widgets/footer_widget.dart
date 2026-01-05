import 'package:flutter/material.dart';
import 'package:saas_stock/core/routing/routers.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        SizedBox(width: 4),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, Routers.register);
          },
          child: Text(
            'Contact Admin',
            style: TextStyle(color: Color(0xFF2563EB), fontSize: 14),
          ),
        ),
      ],
    );
  }
}
