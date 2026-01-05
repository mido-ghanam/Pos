import 'package:json_annotation/json_annotation.dart';
part 'add_product_response_body.g.dart';

@JsonSerializable()
class AddProductResponseBody {
  final bool? status;
  final String? message;
  
  @JsonKey(name: 'product_id')
  final String? productId;

  AddProductResponseBody({
    this.status,
    this.message,
    this.productId,
  });

  factory AddProductResponseBody.fromJson(Map<String, dynamic> json) =>
      _$AddProductResponseBodyFromJson(json);
}
