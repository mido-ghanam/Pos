import 'package:json_annotation/json_annotation.dart';
part 'otp_simple_response.g.dart';

@JsonSerializable()
class OtpSimpleResponse {
  final bool? status;
  final String? message;

  OtpSimpleResponse({this.status, this.message});

  factory OtpSimpleResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpSimpleResponseFromJson(json);
}
