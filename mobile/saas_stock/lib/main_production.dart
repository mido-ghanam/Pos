import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/helpers/constants.dart';
import 'package:saas_stock/core/helpers/shared_pref_helper.dart';
import 'package:saas_stock/core/routing/app_router.dart';
import 'package:saas_stock/firebase_options.dart';
import 'package:saas_stock/stock_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  setUpGetIt();
  await ScreenUtil.ensureScreenSize();
  
  // ✅ تحقق من حالة تسجيل الدخول
  await checkLoggedInUser();
  
  runApp(StockApp(appRouter: AppRouter()));
}

// ✅ فحص صحيح للـ tokens
Future<void> checkLoggedInUser() async {
  String? userToken = await SharedPrefHelper.getSecuredString(
    SharedPrefKeys.userToken,
  );
  
  String? refreshToken = await SharedPrefHelper.getSecuredString(
    SharedPrefKeys.refreshToken,
  );

  // ✅ لو في أي token موجود، اعتبر اليوزر مسجل
  if (userToken != null && userToken.isNotEmpty) {
    isLoggedInUser = true;
    print('✅ User is logged in - Token found');
  } else if (refreshToken != null && refreshToken.isNotEmpty) {
    isLoggedInUser = true;
    print('✅ User is logged in - Refresh token found');
  } else {
    isLoggedInUser = false;
    print('❌ User is NOT logged in - No tokens found');
  }
}
