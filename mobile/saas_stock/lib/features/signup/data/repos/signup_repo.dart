import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_services.dart';
import 'package:saas_stock/features/signup/data/models/register_request_body.dart';
import 'package:saas_stock/features/signup/data/models/register_response_body.dart';

class RegisterRepo {
  final ApiService _apiService;

  RegisterRepo(this._apiService);

  Future<ApiResult<RegisterResponseBody>> register(
    RegisterRequestBody registerRequestBody,
  ) async {
    try {
      final response = await _apiService.register(registerRequestBody);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
