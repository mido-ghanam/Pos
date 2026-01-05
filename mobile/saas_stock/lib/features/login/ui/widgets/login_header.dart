import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: ResponsiveHelper.value(
            context: context,
            mobile: 80.0,
            tablet: 100.0,
          ),
          height: ResponsiveHelper.value(
            context: context,
            mobile: 80.0,
            tablet: 100.0,
          ),
          decoration: BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.school,
            size: ResponsiveHelper.iconSize(context, 40),
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(context, 24)),
        Text(
          'Welcome Back 👋',
          style: TextStyle(
            fontSize: ResponsiveHelper.heading2(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(context, 8)),
        Text(
          'Sign in to continue',
          style: TextStyle(
            fontSize: ResponsiveHelper.bodyLarge(context),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
