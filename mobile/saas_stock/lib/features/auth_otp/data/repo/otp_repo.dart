import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_services.dart';
import 'package:saas_stock/features/auth_otp/data/models/otp_verify_request_body.dart';
import 'package:saas_stock/features/auth_otp/data/models/otp_simple_response.dart';
import 'package:saas_stock/features/auth_otp/data/models/otp_login_verify_response.dart';

class OtpRepo {
  final ApiService _apiService;

  OtpRepo(this._apiService);

  Future<ApiResult<OtpSimpleResponse>> registerVerify(
      OtpVerifyRequestBody body) async {
    try {
      final res = await _apiService.registerVerify(body);
      return ApiResult.success(res);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<OtpLoginVerifyResponse>> loginVerify(
      OtpVerifyRequestBody body) async {
    try {
      final res = await _apiService.loginVerify(body);
      return ApiResult.success(res);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<OtpSimpleResponse>> resendLoginOtp(String username) async {
    try {
      final res = await _apiService.resendLoginOtp(username);
      return ApiResult.success(res);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<OtpSimpleResponse>> resendRegisterOtp(String username) async {
    try {
      final res = await _apiService.resendRegisterOtp(username);
      return ApiResult.success(res);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
