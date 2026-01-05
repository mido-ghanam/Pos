import 'package:json_annotation/json_annotation.dart';

part 'update_customer_request_body.g.dart';

@JsonSerializable()
class UpdateCustomerRequestBody {
  final String name;
  final String phone;
  final String address;
  final bool blocked;
  final bool vip;
  final String notes;

  @JsonKey(name: "is_verified")
  final bool isVerified;

  UpdateCustomerRequestBody({
    required this.name,
    required this.phone,
    required this.address,
    required this.blocked,
    required this.vip,
    required this.notes,
    required this.isVerified,
  });

  factory UpdateCustomerRequestBody.fromJson(Map<String, dynamic> json) =>
      _$UpdateCustomerRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCustomerRequestBodyToJson(this);
}
