import 'package:json_annotation/json_annotation.dart';
part 'add_category_response_body.g.dart';

@JsonSerializable()
class AddCategoryResponseBody {
  final bool? status;
  final String? message;
  
  @JsonKey(name: 'category_id')
  final String? categoryId;

  AddCategoryResponseBody({
    this.status,
    this.message,
    this.categoryId,
  });

  factory AddCategoryResponseBody.fromJson(Map<String, dynamic> json) =>
      _$AddCategoryResponseBodyFromJson(json);
}
