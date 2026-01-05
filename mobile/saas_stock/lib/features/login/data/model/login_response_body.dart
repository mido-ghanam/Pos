import 'package:json_annotation/json_annotation.dart';

part 'login_response_body.g.dart';

@JsonSerializable()
class LoginResponseBody {
  final bool? status;
  final String? message;
  final UserData? data;
  final Tokens? tokens;

  LoginResponseBody({
    this.status,
    this.message,
    this.data,
    this.tokens,
  });

  factory LoginResponseBody.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseBodyFromJson(json);
}
@JsonSerializable()
class UserData {
  final String? id;
  final String? username;
  final String? email;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  final String? phone;

  UserData({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
@JsonSerializable()
class Tokens {
  final String? access;
  final String? refresh;

  Tokens({
    this.access,
    this.refresh,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) =>
      _$TokensFromJson(json);
}
