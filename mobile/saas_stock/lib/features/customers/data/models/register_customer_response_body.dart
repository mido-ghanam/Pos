import 'package:json_annotation/json_annotation.dart';

part 'register_customer_response_body.g.dart';

@JsonSerializable()
class RegisterCustomerResponseBody {
  final bool? status;
  final String? message;
  final String? phone;

  @JsonKey(name: "next_step")
  final String? nextStep;

  RegisterCustomerResponseBody({
    this.status,
    this.message,
    this.phone,
    this.nextStep,
  });

  factory RegisterCustomerResponseBody.fromJson(Map<String, dynamic> json) =>
      _$RegisterCustomerResponseBodyFromJson(json);
}
