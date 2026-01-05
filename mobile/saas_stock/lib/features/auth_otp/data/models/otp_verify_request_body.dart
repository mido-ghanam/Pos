import 'package:json_annotation/json_annotation.dart';
part 'otp_verify_request_body.g.dart';

@JsonSerializable()
class OtpVerifyRequestBody {
  final String username;
  final String otp;

  OtpVerifyRequestBody({required this.username, required this.otp});

  Map<String, dynamic> toJson() => _$OtpVerifyRequestBodyToJson(this);
}
