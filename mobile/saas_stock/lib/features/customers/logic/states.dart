import 'package:saas_stock/features/customers/data/models/customer_model.dart';

abstract class CustomersState {}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {
  final List<CustomerModel> oldCustomers;
  CustomersLoading(this.oldCustomers);
}

class CustomersLoaded extends CustomersState {
  final List<CustomerModel> customers;
  CustomersLoaded(this.customers);
}

// عند إرسال OTP بعد Register
class CustomerOtpSent extends CustomersState {
  final String phone;
  final String message;
  CustomerOtpSent({required this.phone, required this.message});
}

// بعد تأكيد OTP وتسجيل العميل فعلاً
class CustomerRegistered extends CustomersState {
  final CustomerModel customer;
  CustomerRegistered(this.customer);
}

class CustomerUpdated extends CustomersState {}

class CustomersError extends CustomersState {
  final String message;
  CustomersError(this.message);
}

