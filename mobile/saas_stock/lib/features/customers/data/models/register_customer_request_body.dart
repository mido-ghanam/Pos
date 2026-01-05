import 'package:json_annotation/json_annotation.dart';

part 'register_customer_request_body.g.dart';

@JsonSerializable()
class RegisterCustomerRequestBody {
  final String name;
  final String phone;
  final String address;
  final String notes;

  RegisterCustomerRequestBody({
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
  });

  factory RegisterCustomerRequestBody.fromJson(Map<String, dynamic> json) =>
      _$RegisterCustomerRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterCustomerRequestBodyToJson(this);
}
