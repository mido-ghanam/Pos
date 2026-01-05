import 'package:json_annotation/json_annotation.dart';
part 'register_request_body.g.dart';

@JsonSerializable()
class RegisterRequestBody {
  final String username;
  final String password;
  final String phone;
  final String first_name;
  final String last_name;
  

  

  RegisterRequestBody({
    required this.username,
    required this.password,
    required this.phone,
    required this.first_name,
    required this.last_name,
  });

  Map<String, dynamic> toJson() => _$RegisterRequestBodyToJson(this);
}
