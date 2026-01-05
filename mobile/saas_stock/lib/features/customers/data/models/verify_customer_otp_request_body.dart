import 'package:json_annotation/json_annotation.dart';

part 'verify_customer_otp_request_body.g.dart';

@JsonSerializable()
class VerifyCustomerOtpRequestBody {
  final String phone;
  @JsonKey(name: "otp_code")
  final String otpCode;

  VerifyCustomerOtpRequestBody({
    required this.phone,
    required this.otpCode,
  });

  factory VerifyCustomerOtpRequestBody.fromJson(Map<String, dynamic> json) =>
      _$VerifyCustomerOtpRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyCustomerOtpRequestBodyToJson(this);
}
