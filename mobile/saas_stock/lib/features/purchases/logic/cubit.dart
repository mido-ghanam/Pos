import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/purchases/data/models/create_purchase_request.dart';
import 'package:saas_stock/features/purchases/data/repositories/purchases_repo.dart';
import 'states.dart';

class PurchasesCubit extends Cubit<PurchasesState> {
  final PurchasesRepo repo;

  PurchasesCubit(this.repo) : super(PurchasesInitial());

  Future<void> fetchPurchases() async {
    emit(PurchasesLoading());
    try {
      final data = await repo.getPurchases();
      emit(PurchasesLoaded(data));
    } catch (e) {
      emit(PurchasesError(e.toString()));
    }
  }

 Future<void> createPurchase(CreatePurchaseRequest request) async {
  emit(CreatePurchaseLoading());
  try {
    final invoice = await repo.createPurchase(request);
    emit(CreatePurchaseSuccess(invoice));

    // ✅ 1) تحديث المنتجات فورًا
    await getIt<ProductsCubit>().getAllProducts();

    // ✅ 2) تحديث فواتير المشتريات
    await fetchPurchases();
  } catch (e) {
    emit(CreatePurchaseError(e.toString()));
  }
}


  Future<void> fetchPurchaseDetails(int id) async {
    emit(PurchaseDetailsLoading());
    try {
      final invoice = await repo.getPurchaseDetails(id);
      emit(PurchaseDetailsSuccess(invoice));
    } catch (e) {
      emit(PurchaseDetailsError(e.toString()));
    }
  }
}
