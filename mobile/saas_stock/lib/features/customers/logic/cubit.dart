import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/customers/data/models/customer_model.dart';
import 'package:saas_stock/features/customers/data/repositories/customers_repo.dart';
import 'package:saas_stock/features/customers/logic/states.dart';
import '../data/models/register_customer_request_body.dart';
import '../data/models/update_customer_request_body.dart';
import '../data/models/verify_customer_otp_request_body.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepo repo;
  CustomersCubit(this.repo) : super(CustomersInitial());

  List<CustomerModel> customers = [];

  Future<void> fetchCustomers() async {
        emit(CustomersLoading(customers));
    final res = await repo.getAllCustomers();
    res.when(
      success: (data) {
        customers = data.data ?? [];
        emit(CustomersLoaded(customers));
      },
      failure: (err) {
        emit(CustomersError(err.apiErrorModel.message ?? "Error"));
      },
    );
  }

  Future<void> registerCustomer(RegisterCustomerRequestBody body) async {
    emit(CustomersLoading(customers));
    final res = await repo.registerCustomer(body);

    res.when(
      success: (data) {
        if (data.status == true) {
          emit(CustomerOtpSent(
            phone: data.phone ?? body.phone,
            message: data.message ?? "OTP Sent",
          ));
        } else {
          emit(CustomersError(data.message ?? "Failed"));
        }
      },
      failure: (err) {
        emit(CustomersError(err.apiErrorModel.message ?? "Error"));
      },
    );
  }

  Future<void> verifyCustomerOtp(VerifyCustomerOtpRequestBody body) async {
    emit(CustomersLoading(customers));
    final res = await repo.verifyCustomerOtp(body);

    res.when(
      success: (data) {
        if (data.status == true && data.data != null) {
          emit(CustomerRegistered(CustomerModel.fromJson(data.data!.toJson())));
        } else {
          emit(CustomersError(data.message ?? "OTP Failed"));
        }
      },
      failure: (err) {
        emit(CustomersError(err.apiErrorModel.message ?? "Error"));
      },
    );
  }

 Future<void> updateCustomer(String id, UpdateCustomerRequestBody body) async {
  emit(CustomersLoading(customers));

  final res = await repo.updateCustomer(id, body);

  res.when(
    success: (data) async {
      if (data.status == true) {
        emit(CustomerUpdated());

        // ✅ refresh list
        await fetchCustomers();
      } else {
        emit(CustomersError("Update failed"));
      }
    },
    failure: (err) {
      emit(CustomersError(err.apiErrorModel.message ?? "Error"));
    },
  );
}
}
