import 'package:saas_stock/features/returns/data/models/partner_invoices_model.dart';
import 'package:saas_stock/features/returns/data/models/refund_invoice_model.dart';

abstract class ReturnsState {}

class ReturnsInitial extends ReturnsState {}

class ReturnsLoading extends ReturnsState {}

class ReturnsLoaded extends ReturnsState {
  final RefundsListResponse data;
  ReturnsLoaded(this.data);
}

class ReturnsError extends ReturnsState {
  final String message;
  ReturnsError(this.message);
}

// Create Refund
class CreateRefundLoading extends ReturnsState {}

class CreateRefundSuccess extends ReturnsState {
  final RefundInvoiceModel invoice;
  CreateRefundSuccess(this.invoice);
}

class CreateRefundError extends ReturnsState {
  final String message;
  CreateRefundError(this.message);
}


class PartnerInvoicesLoading extends ReturnsState {}
class PartnerInvoicesLoaded extends ReturnsState {
  final PartnerInvoicesResponse data;
  PartnerInvoicesLoaded(this.data);
}
class PartnerInvoicesError extends ReturnsState {
  final String message;
  PartnerInvoicesError(this.message);
}
