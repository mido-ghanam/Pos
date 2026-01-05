import 'package:saas_stock/features/purchases/data/models/purchase_invoice_model.dart';
import 'package:saas_stock/features/purchases/data/models/purchases_list_response.dart';

abstract class PurchasesState {}

class PurchasesInitial extends PurchasesState {}

class PurchasesLoading extends PurchasesState {}

class PurchasesLoaded extends PurchasesState {
  final PurchasesListResponse data;
  PurchasesLoaded(this.data);
}

class PurchasesError extends PurchasesState {
  final String message;
  PurchasesError(this.message);
}

// Create
class CreatePurchaseLoading extends PurchasesState {}

// ✅ تفاصيل فاتورة واحدة
class PurchaseDetailsLoading extends PurchasesState {}

class PurchaseDetailsLoaded extends PurchasesState {
  final PurchaseInvoiceModel invoice;
  PurchaseDetailsLoaded(this.invoice);
}

class PurchaseDetailsError extends PurchasesState {
  final String message;
  PurchaseDetailsError(this.message);
}

class CreatePurchaseSuccess extends PurchasesState {
  final PurchaseInvoiceModel invoice;
  CreatePurchaseSuccess(this.invoice);
}

class CreatePurchaseError extends PurchasesState {
  final String message;
  CreatePurchaseError(this.message);
}

class PurchaseDetailsSuccess extends PurchasesState {
  final PurchaseInvoiceModel invoice;
  PurchaseDetailsSuccess(this.invoice);
}
