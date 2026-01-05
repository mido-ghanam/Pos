import 'package:saas_stock/core/networking/api_services.dart';
import 'package:saas_stock/core/networking/api_result.dart';
import 'package:saas_stock/core/networking/api_error_handler.dart';
import 'package:saas_stock/features/returns/data/models/create_refund_request.dart';
import 'package:saas_stock/features/returns/data/models/partner_invoices_model.dart';
import 'package:saas_stock/features/returns/data/models/refund_invoice_model.dart';

class ReturnsRepo {
  final ApiService api;
  ReturnsRepo(this.api);

  Future<ApiResult<RefundsListResponse>> getRefunds() async {
    try {
      final res = await api.getRefunds();
      return ApiResult.success(RefundsListResponse.fromJson(res));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<RefundInvoiceModel>> createRefund(CreateRefundRequest req) async {
    try {
      final res = await api.createRefund(req.toJson());
      return ApiResult.success(RefundInvoiceModel.fromJson(res));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
  
Future<ApiResult<PartnerInvoicesResponse>> getInvoicesByCustomer(String customerId) async {
  try {
    final res = await api.getSalesByCustomer(customerId);
    return ApiResult.success(PartnerInvoicesResponse.fromJson(res));
  } catch (e) {
    return ApiResult.failure(ErrorHandler.handle(e));
  }
}

Future<ApiResult<PartnerInvoicesResponse>> getInvoicesBySupplier(String supplierId) async {
  try {
    final res = await api.getPurchasesBySupplier(supplierId);
    return ApiResult.success(PartnerInvoicesResponse.fromJson(res));
  } catch (e) {
    return ApiResult.failure(ErrorHandler.handle(e));
  }
}
}