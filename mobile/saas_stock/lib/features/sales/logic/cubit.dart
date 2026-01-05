import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/sales/data/models/create_sale_request.dart';
import 'package:saas_stock/features/sales/data/models/sale_models.dart';
import 'package:saas_stock/features/sales/data/repositories/sales_repo.dart';
import 'package:saas_stock/features/sales/logic/states.dart';

class SalesCubit extends Cubit<SalesState> {
  final SalesRepo salesRepo;

  SalesCubit(this.salesRepo) : super(SalesInitial());

  SalesListResponse? salesList;


  Future<void> loadSales() async {
    emit(SalesLoading());
    final response = await salesRepo.getSales();

    response.when(
      success: (data) {
        salesList = data;
        emit(SalesLoaded(data));
      },
      failure: (error) {
        emit(SalesError(error.apiErrorModel.message ?? 'فشل تحميل المبيعات'));
      },
    );
  }

  Future<void> createSale(CreateSaleRequest request) async {
  emit(CreateSaleLoading());
  final response = await salesRepo.createSale(request);

  response.when(
    success: (sale) async {
      emit(CreateSaleSuccess(sale));

      // ✅ 1) تحديث المنتجات فورًا
      await getIt<ProductsCubit>().getAllProducts();

      // ✅ 2) تحديث فواتير المبيعات
      await loadSales();
    },
    failure: (error) {
      emit(CreateSaleError(
          error.apiErrorModel.message ?? 'فشل إنشاء عملية البيع'));
    },
  );
}

  Future<void> loadSaleDetails(int id) async {
    emit(SaleDetailsLoading());
    final response = await salesRepo.getSaleDetails(id);

    response.when(
      success: (sale) {
        emit(SaleDetailsLoaded(sale));
      },
      failure: (error) {
        emit(SaleDetailsError(
            error.apiErrorModel.message ?? 'فشل تحميل تفاصيل الفاتورة'));
      },
    );
  }
  Future<void> loadSalesByCustomer(String customerId) async {
  emit(CustomerInvoicesLoading());

  final response = await salesRepo.getSalesByCustomer(customerId);

  response.when(
    success: (data) {
      emit(CustomerInvoicesLoaded(data));
    },
    failure: (error) {
      emit(CustomerInvoicesError(
          error.apiErrorModel.message ?? "فشل تحميل فواتير العميل"));
    },
  );
}

}
