import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/returns/data/models/create_refund_request.dart';
import 'package:saas_stock/features/returns/data/models/partner_invoices_model.dart';
import 'package:saas_stock/features/returns/data/models/refund_invoice_model.dart';
import 'package:saas_stock/features/returns/data/repositories/returns_repo.dart';
import 'package:saas_stock/features/returns/logic/states.dart';

class ReturnsCubit extends Cubit<ReturnsState> {
  final ReturnsRepo repo;
  ReturnsCubit(this.repo) : super(ReturnsInitial());

  RefundsListResponse? refunds;

  Future<void> loadRefunds() async {
    emit(ReturnsLoading());
    final res = await repo.getRefunds();
    res.when(
      success: (data) {
        refunds = data;
        emit(ReturnsLoaded(data));
      },
      failure: (err) => emit(ReturnsError(err.apiErrorModel.message ?? 'خطأ')),
    );
  }

  Future<void> createRefund(CreateRefundRequest req) async {
  emit(CreateRefundLoading());
  final res = await repo.createRefund(req);

  res.when(
    success: (invoice) async {
      emit(CreateRefundSuccess(invoice));

      // ✅ تحديث المخزون فوراً بعد المرتجع
      await getIt<ProductsCubit>().getAllProducts();

      // ✅ refresh list
      await loadRefunds();
    },
    failure: (err) =>
        emit(CreateRefundError(err.apiErrorModel.message ?? 'خطأ')),
  );
}


  PartnerInvoicesResponse? partnerInvoices;

  Future<void> loadPartnerInvoices({
    required String type, // "sale" or "purchase"
    required String partyId,
  }) async {
    emit(PartnerInvoicesLoading());

    final res = type == "sale"
        ? await repo.getInvoicesByCustomer(partyId)
        : await repo.getInvoicesBySupplier(partyId);

    res.when(
      success: (data) {
        partnerInvoices = data;
        emit(PartnerInvoicesLoaded(data));
      },
      failure: (err) =>
          emit(PartnerInvoicesError(err.apiErrorModel.message ?? "خطأ")),
    );
  }
}
