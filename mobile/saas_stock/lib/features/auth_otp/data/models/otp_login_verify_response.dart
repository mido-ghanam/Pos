import 'package:json_annotation/json_annotation.dart';
import 'package:saas_stock/features/login/data/model/login_response_body.dart';

part 'otp_login_verify_response.g.dart';

@JsonSerializable()
class OtpLoginVerifyResponse {
  final bool? status;
  final UserData? data;
  final Tokens? tokens;

  OtpLoginVerifyResponse({this.status, this.data, this.tokens});

  factory OtpLoginVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpLoginVerifyResponseFromJson(json);
}
