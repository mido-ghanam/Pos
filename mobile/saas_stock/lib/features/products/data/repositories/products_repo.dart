import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_services.dart';
import 'package:saas_stock/features/products/data/models/add_product_request_body.dart';
import 'package:saas_stock/features/products/data/models/add_product_response_body.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';

class ProductsRepo {
  final ApiService _apiService;

  ProductsRepo(this._apiService);

  // ✅ إضافة منتج
  Future<ApiResult<AddProductResponseBody>> addProduct(
    AddProductRequestBody request,
  ) async {
    try {
      final response = await _apiService.addProduct(request);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  // ✅ عرض كل المنتجات
  Future<ApiResult<ProductsResponseBody>> getAllProducts() async {
    try {
      final response = await _apiService.getAllProducts();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  // ✅ عرض تفاصيل منتج واحد
  Future<ApiResult<ProductsResponseBody>> getProductDetails(
    String productId,
  ) async {
    try {
      final response = await _apiService.getProductDetails(productId);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  // ✅ حذف منتج
  Future<ApiResult<Map<String, dynamic>>> deleteProduct(
    String productId,
  ) async {
    try {
      final response = await _apiService.deleteProduct(productId);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  // ✅ تعديل منتج
  Future<ApiResult<Map<String, dynamic>>> editProduct(
    String productId,
    AddProductRequestBody request,
  ) async {
    try {
      final response = await _apiService.editProduct(productId, request);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  // ✅ Request delete OTP
 // ✅ request delete otp
Future<ApiResult<Map<String, dynamic>>> requestDeleteOtp(String productId) async {
  try {
    final res = await _apiService.requestDeleteProductOtp(productId);
    return ApiResult.success(res);
  } catch (e) {
    return ApiResult.failure(ErrorHandler.handle(e));
  }
}

// ✅ confirm delete
Future<ApiResult<Map<String, dynamic>>> confirmDeleteOtp({
  required String productId,
  required String otp,
}) async {
  try {
    final res = await _apiService.confirmDeleteProductOtp(
      productId: productId,
      otp: otp,
    );
    return ApiResult.success(res);
  } catch (e) {
    return ApiResult.failure(ErrorHandler.handle(e));
  }
}

}
