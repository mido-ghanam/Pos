import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/networking/dio_factory.dart'; // ✅ import
import 'package:saas_stock/core/routing/app_router.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/purchases/logic/cubit.dart';
import 'package:saas_stock/features/returns/logic/cubit.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';

class StockApp extends StatelessWidget {
  final AppRouter appRouter;
  const StockApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CustomersCubit>()..fetchCustomers()),
        BlocProvider(create: (_) => getIt<SuppliersCubit>()..fetchSuppliers()),
        BlocProvider(create: (_) => getIt<SalesCubit>()..loadSales()),
        BlocProvider(create: (_) => getIt<PurchasesCubit>()..fetchPurchases()),
        BlocProvider(create: (_) => getIt<ReturnsCubit>()..loadRefunds()),
        BlocProvider(create: (_) => getIt<ProductsCubit>()..getAllProducts()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'نظام إدارة المخازن',

        // ✅ أضف الـ Navigator Key
        navigatorKey: DioFactory.navigatorKey,

        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7C3AED),
            brightness: Brightness.light,
          ),
          fontFamily: 'Cairo',
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF7C3AED),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: Routers.splashScreen,
        onGenerateRoute: (settings) => appRouter.generateRoute(settings),
      ),
    );
  }
}
