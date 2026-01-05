import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/reports/data/models/stats_models.dart';
import 'package:saas_stock/features/reports/data/repositories/reports_repo.dart';
import 'states.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepo repo;
  ReportsCubit(this.repo) : super(ReportsInitial());

  String currentPeriod = "today";

  Future<void> loadReports({String? period}) async {
    emit(ReportsLoading());

    final p = period ?? currentPeriod;
    currentPeriod = p;

    final salesRes = await repo.getSalesStats(p);
    final purchasesRes = await repo.getPurchasesStats(p);

    SalesStatsResponse? salesData;
    PurchasesStatsResponse? purchasesData;
    String? errorMsg;

    salesRes.when(
      success: (data) => salesData = data,
      failure: (err) =>
          errorMsg = err.apiErrorModel.message ?? "فشل تحميل تقارير المبيعات",
    );

    purchasesRes.when(
      success: (data) => purchasesData = data,
      failure: (err) =>
          errorMsg = err.apiErrorModel.message ?? "فشل تحميل تقارير المشتريات",
    );

    if (salesData != null && purchasesData != null) {
      emit(
        ReportsLoaded(
          sales: salesData!,
          purchases: purchasesData!,
          period: p,
        ),
      );
    } else {
      emit(ReportsError(errorMsg ?? "فشل تحميل التقارير"));
    }
  }
}
