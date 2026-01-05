import 'package:saas_stock/core/networking/api_services.dart';
import 'package:saas_stock/features/purchases/data/models/create_purchase_request.dart';
import 'package:saas_stock/features/purchases/data/models/purchase_invoice_model.dart';
import 'package:saas_stock/features/purchases/data/models/purchases_list_response.dart';

class PurchasesRepo {
  final ApiService apiService;
  PurchasesRepo(this.apiService);

  Future<PurchasesListResponse> getPurchases() async {
    final data = await apiService.getPurchases();
    return PurchasesListResponse.fromJson(data);
  }

  Future<PurchaseInvoiceModel> getPurchaseDetails(int id) async {
    final data = await apiService.getPurchaseDetails(id);
    return PurchaseInvoiceModel.fromJson(data);
  }

  Future<PurchaseInvoiceModel> createPurchase(CreatePurchaseRequest request) async {
    final data = await apiService.createPurchase(request.toJson());
    return PurchaseInvoiceModel.fromJson(data);
  }
}
