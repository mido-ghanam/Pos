import '../data/models/stats_models.dart';

abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}

class ReportsLoaded extends ReportsState {
  final SalesStatsResponse sales;
  final PurchasesStatsResponse purchases;
  final String period;

  ReportsLoaded({
    required this.sales,
    required this.purchases,
    required this.period,
  });
}
