import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/suppliers/data/repo/suppliers_repo.dart';
import '../data/models/supplier_model.dart';
import 'states.dart';

import '../data/models/register_supplier_request_body.dart';
import '../data/models/update_supplier_request_body.dart';
import '../data/models/verify_supplier_otp_request_body.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final SuppliersRepo repo;
  SuppliersCubit(this.repo) : super(SuppliersInitial());

  List<SupplierModel> suppliers = [];

  Future<void> fetchSuppliers() async {
    emit(SuppliersLoading(suppliers));
    final res = await repo.getAllSuppliers();
    res.when(
      success: (data) {
        suppliers = data.data ?? [];
        emit(SuppliersLoaded(suppliers));
      },
      failure: (err) {
        emit(SuppliersError(err.apiErrorModel.message ?? "Error"));
      },
    );
  }

  Future<void> registerSupplier(RegisterSupplierRequestBody body) async {
    emit(SuppliersLoading(suppliers));
    final res = await repo.registerSupplier(body);

    res.when(
      success: (data) {
        if (data.status == true) {
          emit(SupplierOtpSent(
            phone: data.phone ?? body.phone,
            message: data.message ?? "OTP Sent",
          ));
        } else {
          emit(SuppliersError(data.message ?? "Failed"));
        }
      },
      failure: (err) {
        emit(SuppliersError(err.apiErrorModel.message ?? "Error"));
      },
    );
  }

  Future<void> verifySupplierOtp(VerifySupplierOtpRequestBody body) async {
    emit(SuppliersLoading(suppliers));
    final res = await repo.verifySupplierOtp(body);

    res.when(
      success: (data) {
        if (data.status == true && data.data != null) {
          emit(SupplierRegistered(data.data!));
        } else {
          emit(SuppliersError(data.message ?? "OTP Failed"));
        }
      },
      failure: (err) {
        emit(SuppliersError(err.apiErrorModel.message ?? "Error"));
      },
    );
  }

  Future<void> updateSupplier(String id, UpdateSupplierRequestBody body) async {
  emit(SuppliersLoading(suppliers));

  final res = await repo.updateSupplier(id, body);

  res.when(
    success: (data) async {
      if (data.status == true) {
        emit(SupplierUpdated());

        // ✅ دي أهم سطرين
        await fetchSuppliers(); // يجيب البيانات الجديدة
      } else {
        emit(SuppliersError("Update failed"));
      }
    },
    failure: (err) {
      emit(SuppliersError(err.apiErrorModel.message ?? "Error"));
    },
  );
}
    
}
