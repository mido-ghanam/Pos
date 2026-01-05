import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:saas_stock/core/networking/api_services.dart';
import 'package:saas_stock/core/networking/dio_factory.dart';
import 'package:saas_stock/features/auth_otp/data/repo/otp_repo.dart';
import 'package:saas_stock/features/auth_otp/logic/otp_cubit.dart';
import 'package:saas_stock/features/customers/data/repositories/customers_repo.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/dashboard/data/repositories/auth_repo.dart';
import 'package:saas_stock/features/dashboard/logic/cubit.dart';
import 'package:saas_stock/features/dashboard/logic/dashboard_stats.dart/dasg_cubit.dart';
import 'package:saas_stock/features/login/data/repo/login_repo.dart';
import 'package:saas_stock/features/login/logic/login_cubit.dart';
import 'package:saas_stock/features/purchases/data/repositories/purchases_repo.dart';
import 'package:saas_stock/features/purchases/logic/cubit.dart';
import 'package:saas_stock/features/reports/data/repositories/reports_repo.dart';
import 'package:saas_stock/features/reports/logic/cubit.dart';
import 'package:saas_stock/features/returns/data/repositories/returns_repo.dart';
import 'package:saas_stock/features/returns/logic/cubit.dart';
import 'package:saas_stock/features/sales/data/repositories/sales_repo.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/signup/data/repos/signup_repo.dart';
import 'package:saas_stock/features/products/data/repositories/products_repo.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/products/data/repositories/category_repo.dart';
import 'package:saas_stock/features/products/logic/category/cubit.dart';
import 'package:saas_stock/features/signup/logic/signup_cubit.dart';
import 'package:saas_stock/features/suppliers/data/repo/suppliers_repo.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';

final getIt = GetIt.instance;

Future<void> setUpGetIt() async {
  // ✅ Dio
  Dio dio = DioFactory.getDio();
  getIt.registerLazySingleton<Dio>(() => dio);

  // ✅ ApiService
  getIt.registerLazySingleton<ApiService>(() => ApiService(dio));

  // =================== Login ===================
  getIt.registerLazySingleton<LoginRepo>(() => LoginRepo(getIt()));
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));

  // =================== Register ===================
  getIt.registerLazySingleton<RegisterRepo>(() => RegisterRepo(getIt()));
  getIt.registerFactory<RegisterCubit>(() => RegisterCubit(getIt()));

  // =================== OTP ===================
  getIt.registerLazySingleton<OtpRepo>(() => OtpRepo(getIt()));
  getIt.registerFactory<OtpCubit>(() => OtpCubit(getIt()));

  // =================== Products ===================
  getIt.registerLazySingleton<ProductsRepo>(() => ProductsRepo(getIt()));
  getIt.registerLazySingleton<ProductsCubit>(() => ProductsCubit(getIt()));

  // =================== Categories ===================
  getIt.registerLazySingleton<CategoryRepo>(() => CategoryRepo(getIt()));
  getIt.registerLazySingleton<CategoryCubit>(() => CategoryCubit(getIt()));

  // =================== Customers ===================
  getIt.registerLazySingleton<CustomersRepo>(() => CustomersRepo(getIt()));
  getIt.registerLazySingleton<CustomersCubit>(() => CustomersCubit(getIt()));

  // Suppliers
  getIt.registerLazySingleton<SuppliersRepo>(() => SuppliersRepo(getIt()));
  getIt.registerLazySingleton<SuppliersCubit>(() => SuppliersCubit(getIt()));

// =================== Sales ===================
  getIt.registerLazySingleton<SalesRepo>(() => SalesRepo(getIt()));
  getIt.registerFactory<SalesCubit>(() => SalesCubit(getIt()));

  getIt.registerLazySingleton<PurchasesRepo>(() => PurchasesRepo(getIt()));
  getIt.registerFactory<PurchasesCubit>(() => PurchasesCubit(getIt()));

  getIt.registerLazySingleton<ReturnsRepo>(() => ReturnsRepo(getIt()));
  getIt.registerFactory<ReturnsCubit>(() => ReturnsCubit(getIt()));

  // =================== Logout ===================
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo(getIt()));
  getIt.registerLazySingleton<LogoutCubit>(() => LogoutCubit(getIt()));
  getIt.registerFactory<DashboardCubit>(() => DashboardCubit());

  getIt.registerLazySingleton<ReportsRepo>(() => ReportsRepo(getIt()));
  getIt.registerFactory<ReportsCubit>(() => ReportsCubit(getIt()));
}
