
import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.value(
        context: context,
        mobile: 48.0,
        tablet: 52.0,
        desktop: 56.0,
      ),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.g_mobiledata, size: 24),
        label: Text(
          'Sign in with Google',
          style: TextStyle(fontSize: ResponsiveHelper.bodyLarge(context)),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(context, 12),
            ),
          ),
        ),
      ),
    );
  }
}
