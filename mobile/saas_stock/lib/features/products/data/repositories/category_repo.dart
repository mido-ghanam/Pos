import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_services.dart';
import 'package:saas_stock/features/products/data/models/add_category_request_body.dart';
import 'package:saas_stock/features/products/data/models/add_category_response_body.dart';
import 'package:saas_stock/features/products/data/models/get_all_categories_response.dart';

class CategoryRepo {
  final ApiService _apiService;

  CategoryRepo(this._apiService);

  // ✅ جلب كل الفئات
  Future<ApiResult<List<CategoryModel>>> getAllCategories() async {
    try {
      final response = await _apiService.getAllCategories();
      
      if (response['status'] == true && response['data'] != null) {
        final List<dynamic> categoriesList = response['data'];
        final categories = categoriesList
            .map((json) => CategoryModel.fromJson(json))
            .toList();
        return ApiResult.success(categories);
      } else {
        return ApiResult.success([]);
      }
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  // ✅ إضافة فئة
  Future<ApiResult<AddCategoryResponseBody>> addCategory(
    AddCategoryRequestBody request,
  ) async {
    try {
      final response = await _apiService.addCategory(request);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  // ✅ حذف فئة
  Future<ApiResult<Map<String, dynamic>>> deleteCategory(
    String categoryId,
  ) async {
    try {
      final response = await _apiService.deleteCategory(categoryId);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
