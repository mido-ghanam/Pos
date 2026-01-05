import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  final double? borderRadius;
  final Color? backgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final TextStyle textStyle;
  final VoidCallback? onPressed;

  final IconData? icon;
  final bool isLoading;
  final Color? shadowColor;

  const AppTextButton({
    super.key,
    this.borderRadius,
    this.backgroundColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.buttonHeight,
    this.buttonWidth,
    required this.buttonText,
    required this.textStyle,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: buttonWidth, // ⭐ شيل double.infinity من هنا
      height: buttonHeight ?? 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: [
          BoxShadow(
            color: shadowColor?.withOpacity(0.2) ?? Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          child: Container(
            decoration: BoxDecoration(
              // في app_text_button.dart - سطر 67
              color: isLoading
                  ? const Color(0xFF7C3AED).withOpacity(0.7) // ⭐ عدلها
                  : backgroundColor ?? const Color(0xFF7C3AED), // ⭐ عدلها

              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 20,
              vertical: verticalPadding ?? 14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // ⭐ مهم جداً!
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textStyle.color ?? Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ] else if (icon != null) ...[
                  Icon(icon, color: textStyle.color ?? Colors.white, size: 20),
                  SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    isLoading ? 'يرجى الانتظار...' : buttonText, // ⭐ عربي
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center, // ⭐ مهم للعربي
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
