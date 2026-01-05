import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_services.dart';
import '../models/stats_models.dart';

class ReportsRepo {
  final ApiService api;
  ReportsRepo(this.api);

  Future<ApiResult<SalesStatsResponse>> getSalesStats(String period) async {
    try {
      final res = await api.getSalesStats(period);
      return ApiResult.success(SalesStatsResponse.fromJson(res));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<PurchasesStatsResponse>> getPurchasesStats(String period) async {
    try {
      final res = await api.getPurchasesStats(period);
      return ApiResult.success(PurchasesStatsResponse.fromJson(res));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
