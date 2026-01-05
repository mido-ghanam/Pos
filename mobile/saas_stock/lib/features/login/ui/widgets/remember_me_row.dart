import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';

class RememberMeRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;

  const RememberMeRow({super.key, 
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          onChanged: onRememberMeChanged,
          activeColor: Color(0xFF2563EB),
        ),
        Text(
          'Remember me',
          style: TextStyle(fontSize: ResponsiveHelper.bodyMedium(context)),
        ),
        Spacer(),
        TextButton(
          onPressed: () {},
          child: Text(
            'Forgot password?',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: ResponsiveHelper.bodyMedium(context),
            ),
          ),
        ),
      ],
    );
  }
}
