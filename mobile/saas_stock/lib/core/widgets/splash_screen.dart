import 'package:flutter/material.dart';
import 'package:saas_stock/core/helpers/constants.dart';
import 'package:saas_stock/core/helpers/shared_pref_helper.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'dart:async';
import '../../../../core/routing/routers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // ✅ فحص حالة Login والانتقال
    _navigateToNextScreen();
  }

  // ✅ فحص الـ Tokens والانتقال
  Future<void> _navigateToNextScreen() async {
    // ✅ انتظر انتهاء الـ Animation (2 ثانية)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ✅ فحص الـ Tokens
    final accessToken = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );

    final refreshToken = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.refreshToken,
    );

    if (!mounted) return;

    // ✅ لو في Tokens، روح Home
    if ((accessToken != null && accessToken.isNotEmpty) ||
        (refreshToken != null && refreshToken.isNotEmpty)) {
      print('✅ User is logged in - Navigating to Home');
      isLoggedInUser = true;
      Navigator.pushReplacementNamed(context, Routers.home);
    } else {
      // ✅ لو مفيش Tokens، روح Login
      print('❌ No tokens found - Navigating to Login');
      isLoggedInUser = false;
      Navigator.pushReplacementNamed(context, Routers.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7C3AED),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: ResponsiveHelper.value(
                    context: context,
                    mobile: 120.0,
                    tablet: 160.0,
                    desktop: 180.0,
                  ),
                  height: ResponsiveHelper.value(
                    context: context,
                    mobile: 120.0,
                    tablet: 160.0,
                    desktop: 180.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.store,
                    size: ResponsiveHelper.iconSize(context, 70),
                    color: const Color(0xFF7C3AED),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(context, 32)),

                // App Name
                Text(
                  'نظام المخازن',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.heading1(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(context, 12)),

                // Subtitle
                Text(
                  'Inventory Management System',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.bodyLarge(context),
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: ResponsiveHelper.spacing(context, 60)),

                // Loading Indicator
                Container(
                  width: ResponsiveHelper.value(
                    context: context,
                    mobile: 50.0,
                    tablet: 60.0,
                    desktop: 70.0,
                  ),
                  height: ResponsiveHelper.value(
                    context: context,
                    mobile: 50.0,
                    tablet: 60.0,
                    desktop: 70.0,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 4,
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
