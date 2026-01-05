import 'package:dio/dio.dart';
import 'package:saas_stock/core/networking/api_constants.dart';
import 'package:saas_stock/features/auth_otp/data/models/otp_login_verify_response.dart';
import 'package:saas_stock/features/auth_otp/data/models/otp_simple_response.dart';
import 'package:saas_stock/features/auth_otp/data/models/otp_verify_request_body.dart';
import 'package:saas_stock/features/customers/data/models/get_customers_response_body.dart';
import 'package:saas_stock/features/customers/data/models/register_customer_request_body.dart';
import 'package:saas_stock/features/customers/data/models/register_customer_response_body.dart';
import 'package:saas_stock/features/customers/data/models/update_customer_request_body.dart';
import 'package:saas_stock/features/customers/data/models/update_customer_response_body.dart';
import 'package:saas_stock/features/customers/data/models/verify_customer_otp_request_body.dart';
import 'package:saas_stock/features/customers/data/models/verify_customer_otp_response_body.dart';
import 'package:saas_stock/features/login/data/model/login_request_body.dart';
import 'package:saas_stock/features/login/data/model/login_response_body.dart';
import 'package:saas_stock/features/signup/data/models/register_request_body.dart';
import 'package:saas_stock/features/signup/data/models/register_response_body.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';
import 'package:saas_stock/features/products/data/models/add_product_request_body.dart';
import 'package:saas_stock/features/products/data/models/add_product_response_body.dart';
import 'package:saas_stock/features/products/data/models/add_category_request_body.dart';
import 'package:saas_stock/features/products/data/models/add_category_response_body.dart';
import 'package:saas_stock/features/suppliers/data/models/get_suppliers_response_body.dart';
import 'package:saas_stock/features/suppliers/data/models/register_supplier_request_body.dart';
import 'package:saas_stock/features/suppliers/data/models/register_supplier_response_body.dart';
import 'package:saas_stock/features/suppliers/data/models/update_supplier_request_body.dart';
import 'package:saas_stock/features/suppliers/data/models/update_supplier_response_body.dart';
import 'package:saas_stock/features/suppliers/data/models/verify_supplier_otp_request_body.dart';
import 'package:saas_stock/features/suppliers/data/models/verify_supplier_otp_response_body.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // =================== Auth ===================

  Future<LoginResponseBody> login(LoginRequestBody loginRequestBody) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: loginRequestBody.toJson(),
    );
    return LoginResponseBody.fromJson(response.data);
  }

  Future<RegisterResponseBody> register(
      RegisterRequestBody registerRequestBody) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: registerRequestBody.toJson(),
    );
    return RegisterResponseBody.fromJson(response.data);
  }

  Future<Map<String, dynamic>> logout({String? refreshToken}) async {
    final response = await _dio.post(
      ApiConstants.logout,
      data: refreshToken != null && refreshToken.isNotEmpty
          ? {"refresh": refreshToken}
          : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(ApiConstants.me);
    return response.data;
  }

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> body) async {
    final response = await _dio.post(
      ApiConstants.changePassword,
      data: body,
    );
    return response.data;
  }

  // =================== OTP ===================

  Future<OtpSimpleResponse> registerVerify(OtpVerifyRequestBody body) async {
    final response = await _dio.post(
      ApiConstants.registerVerify,
      data: body.toJson(),
    );
    return OtpSimpleResponse.fromJson(response.data);
  }

  Future<OtpLoginVerifyResponse> loginVerify(OtpVerifyRequestBody body) async {
    final response = await _dio.post(
      ApiConstants.loginVerify,
      data: body.toJson(),
    );
    return OtpLoginVerifyResponse.fromJson(response.data);
  }

  Future<OtpSimpleResponse> resendLoginOtp(String username) async {
    final response = await _dio.post(
      ApiConstants.loginResendOtp,
      data: {"username": username},
    );
    return OtpSimpleResponse.fromJson(response.data);
  }

  Future<OtpSimpleResponse> resendRegisterOtp(String username) async {
    final response = await _dio.post(
      ApiConstants.registerResendOtp,
      data: {"username": username},
    );
    return OtpSimpleResponse.fromJson(response.data);
  }

  // =================== Categories ===================

  Future<Map<String, dynamic>> getAllCategories() async {
    final response = await _dio.get(ApiConstants.getAllCategories);
    return response.data;
  }

  Future<AddCategoryResponseBody> addCategory(
      AddCategoryRequestBody addCategoryRequestBody) async {
    final response = await _dio.post(
      ApiConstants.addCategory,
      data: addCategoryRequestBody.toJson(),
    );
    return AddCategoryResponseBody.fromJson(response.data);
  }

  Future<Map<String, dynamic>> deleteCategory(String categoryId) async {
    final response = await _dio.delete(
      ApiConstants.deleteCategory,
      queryParameters: {'categoryId': categoryId},
    );
    return response.data;
  }

  // =================== Products ===================

  Future<ProductsResponseBody> getAllProducts() async {
    final response = await _dio.get(ApiConstants.getAllProducts);
    return ProductsResponseBody.fromJson(response.data);
  }

  Future<ProductsResponseBody> getProductDetails(String productId) async {
    final response = await _dio.get(
      ApiConstants.getProductDetails,
      queryParameters: {'productId': productId},
    );
    return ProductsResponseBody.fromJson(response.data);
  }

  Future<AddProductResponseBody> addProduct(
      AddProductRequestBody addProductRequestBody) async {
    final response = await _dio.post(
      ApiConstants.addProduct,
      data: addProductRequestBody.toJson(),
    );
    return AddProductResponseBody.fromJson(response.data);
  }

  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    final response = await _dio.delete(
      ApiConstants.deleteProduct,
      queryParameters: {'productId': productId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> editProduct(
    String productId,
    AddProductRequestBody addProductRequestBody,
  ) async {
    final response = await _dio.patch(
      ApiConstants.editProduct,
      queryParameters: {'productId': productId},
      data: addProductRequestBody.toJson(),
    );
    return response.data;
  }

  // ✅ Request Delete OTP
 // =================== Products Delete With OTP ===================

Future<Map<String, dynamic>> requestDeleteProductOtp(String productId) async {
  final response = await _dio.delete(
    ApiConstants.deleteProduct,
    queryParameters: {'productId': productId},
  );
  return response.data;
}

Future<Map<String, dynamic>> confirmDeleteProductOtp({
  required String productId,
  required String otp,
}) async {
  final response = await _dio.post(
    ApiConstants.deleteProductConfirm,
    data: {
      "productId": productId,
      "otp": otp,
    },
  );
  return response.data;
}


  // داخل ApiService class

  Future<GetCustomersResponseBody> getAllCustomers() async {
    final response = await _dio.get(ApiConstants.customers);
    return GetCustomersResponseBody.fromJson(response.data);
  }

  Future<RegisterCustomerResponseBody> registerCustomer(
      RegisterCustomerRequestBody body) async {
    final response = await _dio.post(
      ApiConstants.registerCustomer,
      data: body.toJson(),
    );
    return RegisterCustomerResponseBody.fromJson(response.data);
  }

  Future<VerifyCustomerOtpResponseBody> verifyCustomerOtp(
      VerifyCustomerOtpRequestBody body) async {
    final response = await _dio.post(
      ApiConstants.verifyCustomerOtp,
      data: body.toJson(),
    );
    return VerifyCustomerOtpResponseBody.fromJson(response.data);
  }

  Future<UpdateCustomerResponseBody> updateCustomer(
      String id, UpdateCustomerRequestBody body) async {
    final response = await _dio.patch(
      ApiConstants.updateCustomer(id),
      data: body.toJson(),
    );
    return UpdateCustomerResponseBody.fromJson(response.data);
  }

// =================== Suppliers ===================

  Future<GetSuppliersResponseBody> getAllSuppliers() async {
    final response = await _dio.get(ApiConstants.getAllSuppliers);
    return GetSuppliersResponseBody.fromJson(response.data);
  }

  Future<RegisterSupplierResponseBody> registerSupplier(
      RegisterSupplierRequestBody body) async {
    final response = await _dio.post(
      ApiConstants.registerSupplier,
      data: body.toJson(),
    );
    return RegisterSupplierResponseBody.fromJson(response.data);
  }

  Future<VerifySupplierOtpResponseBody> verifySupplierOtp(
      VerifySupplierOtpRequestBody body) async {
    final response = await _dio.post(
      ApiConstants.registerSupplierVerify,
      data: body.toJson(),
    );
    return VerifySupplierOtpResponseBody.fromJson(response.data);
  }

  Future<UpdateSupplierResponseBody> updateSupplier(
      String id, UpdateSupplierRequestBody body) async {
    final response = await _dio.patch(
      "${ApiConstants.updateSupplier}$id/",
      data: body.toJson(),
    );
    return UpdateSupplierResponseBody.fromJson(response.data);
  }

  // =================== Sales ===================

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> body) async {
    final response = await _dio.post(
      ApiConstants.createSale,
      data: body,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSales() async {
    final response = await _dio.get(ApiConstants.getSales);
    return response.data;
  }

  Future<Map<String, dynamic>> getSaleDetails(int id) async {
    final response = await _dio.get(ApiConstants.getSaleDetails(id));
    return response.data;
  }

  // =================== Purchases ===================

  Future<Map<String, dynamic>> getPurchases() async {
    final response = await _dio.get(ApiConstants.purchasesList);
    return response.data;
  }

  Future<Map<String, dynamic>> getPurchaseDetails(int id) async {
    final response = await _dio.get(ApiConstants.purchaseDetails(id));
    return response.data;
  }

  Future<Map<String, dynamic>> createPurchase(Map<String, dynamic> body) async {
    final response = await _dio.post(
      ApiConstants.createPurchase,
      data: body,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getRefunds() async {
    final response = await _dio.get(ApiConstants.refundsList);
    return response.data;
  }

  Future<Map<String, dynamic>> createRefund(Map<String, dynamic> body) async {
    final response = await _dio.post(
      ApiConstants.createRefund,
      data: body,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSalesByCustomer(String customerId) async {
    final response = await _dio.get(ApiConstants.salesByCustomer(customerId));
    return response.data;
  }

  Future<Map<String, dynamic>> getPurchasesBySupplier(String supplierId) async {
    final response =
        await _dio.get(ApiConstants.purchasesBySupplier(supplierId));
    return response.data;
  }

  Future<Map<String, dynamic>> getBillingDashboard() async {
    final response = await _dio.get(ApiConstants.billingDashboard);
    return response.data;
  }

  Future<Map<String, dynamic>> getSalesStats(String period) async {
    final response = await _dio.get(
      ApiConstants.salesStats,
      queryParameters: {"period": period},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getPurchasesStats(String period) async {
    final response = await _dio.get(
      ApiConstants.purchasesStats,
      queryParameters: {"period": period},
    );
    return response.data;
  }
}
