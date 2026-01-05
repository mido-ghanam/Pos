import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_services.dart';
import 'package:saas_stock/features/sales/data/models/create_sale_request.dart';
import 'package:saas_stock/features/sales/data/models/sale_models.dart';

class SalesRepo {
  final ApiService _apiService;

  SalesRepo(this._apiService);

  Future<ApiResult<SaleResponse>> createSale(CreateSaleRequest request) async {
    try {
      final res = await _apiService.createSale(request.toJson());
      return ApiResult.success(SaleResponse.fromJson(res));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<SalesListResponse>> getSales() async {
    try {
      final res = await _apiService.getSales();
      return ApiResult.success(SalesListResponse.fromJson(res));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<SaleResponse>> getSaleDetails(int id) async {
    try {
      final res = await _apiService.getSaleDetails(id);
      return ApiResult.success(SaleResponse.fromJson(res));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<SalesListResponse>> getSalesByCustomer(String customerId) async {
  try {
    final response = await _apiService.getSalesByCustomer(customerId);
    return ApiResult.success(SalesListResponse.fromJson(response));
  } catch (e) {
    return ApiResult.failure(ErrorHandler.handle(e));
  }
}

}
