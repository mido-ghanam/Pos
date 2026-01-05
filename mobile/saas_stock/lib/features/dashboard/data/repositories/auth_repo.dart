import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_services.dart';

class AuthRepo {
  final ApiService apiService;
  AuthRepo(this.apiService);

  Future<ApiResult<Map<String, dynamic>>> logout({String? refreshToken}) async {
    try {
      final res = await apiService.logout(refreshToken: refreshToken);
      return ApiResult.success(res);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
