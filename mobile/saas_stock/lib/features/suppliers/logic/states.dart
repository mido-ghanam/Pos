import '../data/models/supplier_model.dart';

abstract class SuppliersState {}

class SuppliersInitial extends SuppliersState {}

class SuppliersLoading extends SuppliersState {
  final List<SupplierModel> oldSuppliers;
  SuppliersLoading(this.oldSuppliers);
}

class SuppliersLoaded extends SuppliersState {
  final List<SupplierModel> suppliers;
  SuppliersLoaded(this.suppliers);
}

class SupplierOtpSent extends SuppliersState {
  final String phone;
  final String message;
  SupplierOtpSent({required this.phone, required this.message});
}

class SupplierRegistered extends SuppliersState {
  final SupplierModel supplier;
  SupplierRegistered(this.supplier);
}

class SupplierUpdated extends SuppliersState {}

class SuppliersError extends SuppliersState {
  final String message;
  SuppliersError(this.message);
}
