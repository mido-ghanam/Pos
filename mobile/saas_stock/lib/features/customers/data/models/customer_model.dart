import 'package:json_annotation/json_annotation.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  final String? id;
  final String? name;
  final String? phone;
  final String? address;
  final bool? blocked;
  final bool? vip;
  final String? notes;

  @JsonKey(name: "is_verified")
  final bool? isVerified;

  @JsonKey(name: "created_at")
  final String? createdAt;

  @JsonKey(name: "updated_at")
  final String? updatedAt;

  CustomerModel({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.blocked,
    this.vip,
    this.notes,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);
}
