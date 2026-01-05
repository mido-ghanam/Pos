import 'package:json_annotation/json_annotation.dart';
import 'customer_model.dart';

part 'verify_customer_otp_response_body.g.dart';

@JsonSerializable()
class VerifyCustomerOtpResponseBody {
  final bool? status;
  final String? message;
  final CustomerModel? data;

  VerifyCustomerOtpResponseBody({
    this.status,
    this.message,
    this.data,
  });

  factory VerifyCustomerOtpResponseBody.fromJson(Map<String, dynamic> json) =>
      _$VerifyCustomerOtpResponseBodyFromJson(json);
}
