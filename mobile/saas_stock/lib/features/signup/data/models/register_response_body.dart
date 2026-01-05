import 'package:json_annotation/json_annotation.dart';
part 'register_response_body.g.dart';

@JsonSerializable()
class RegisterResponseBody {
  final bool? status;
  final String? message;
  

  RegisterResponseBody({
    this.status,
    this.message,

  });

  factory RegisterResponseBody.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseBodyFromJson(json);
}
