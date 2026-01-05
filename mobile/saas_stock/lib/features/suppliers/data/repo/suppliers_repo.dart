import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_services.dart';

import '../models/get_suppliers_response_body.dart';
import '../models/register_supplier_request_body.dart';
import '../models/register_supplier_response_body.dart';
import '../models/update_supplier_request_body.dart';
import '../models/update_supplier_response_body.dart';
import '../models/verify_supplier_otp_request_body.dart';
import '../models/verify_supplier_otp_response_body.dart';

class SuppliersRepo {
  final ApiService api;
  SuppliersRepo(this.api);

  Future<ApiResult<GetSuppliersResponseBody>> getAllSuppliers() async {
    try {
      final response = await api.getAllSuppliers();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<RegisterSupplierResponseBody>> registerSupplier(
      RegisterSupplierRequestBody body) async {
    try {
      final response = await api.registerSupplier(body);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<VerifySupplierOtpResponseBody>> verifySupplierOtp(
      VerifySupplierOtpRequestBody body) async {
    try {
      final response = await api.verifySupplierOtp(body);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<UpdateSupplierResponseBody>> updateSupplier(
      String id, UpdateSupplierRequestBody body) async {
    try {
      final response = await api.updateSupplier(id, body);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
