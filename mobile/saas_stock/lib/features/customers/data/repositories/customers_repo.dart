import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_services.dart';

import '../models/get_customers_response_body.dart';
import '../models/register_customer_request_body.dart';
import '../models/register_customer_response_body.dart';
import '../models/update_customer_request_body.dart';
import '../models/update_customer_response_body.dart';
import '../models/verify_customer_otp_request_body.dart';
import '../models/verify_customer_otp_response_body.dart';

class CustomersRepo {
  final ApiService api;
  CustomersRepo(this.api);

  Future<ApiResult<GetCustomersResponseBody>> getAllCustomers() async {
    try {
      final response = await api.getAllCustomers();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<RegisterCustomerResponseBody>> registerCustomer(
      RegisterCustomerRequestBody body) async {
    try {
      final response = await api.registerCustomer(body);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<VerifyCustomerOtpResponseBody>> verifyCustomerOtp(
      VerifyCustomerOtpRequestBody body) async {
    try {
      final response = await api.verifyCustomerOtp(body);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<UpdateCustomerResponseBody>> updateCustomer(
      String id, UpdateCustomerRequestBody body) async {
    try {
      final response = await api.updateCustomer(id, body);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
  
}
