import 'package:saas_stock/features/sales/data/models/sale_models.dart';

abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final SalesListResponse data;
  SalesLoaded(this.data);
}

class SalesError extends SalesState {
  final String error;
  SalesError(this.error);
}

// Create Sale
class CreateSaleLoading extends SalesState {}

class CreateSaleSuccess extends SalesState {
  final SaleResponse sale;
  CreateSaleSuccess(this.sale);
}

class CreateSaleError extends SalesState {
  final String error;
  CreateSaleError(this.error);
}

// Sale Details
class SaleDetailsLoading extends SalesState {}

class SaleDetailsLoaded extends SalesState {
  final SaleResponse sale;
  SaleDetailsLoaded(this.sale);
}

class SaleDetailsError extends SalesState {
  final String error;
  SaleDetailsError(this.error);
}


class CustomerInvoicesLoading extends SalesState {}

class CustomerInvoicesLoaded extends SalesState {
  final SalesListResponse data;
  CustomerInvoicesLoaded(this.data);
}

class CustomerInvoicesError extends SalesState {
  final String error;
  CustomerInvoicesError(this.error);
}
