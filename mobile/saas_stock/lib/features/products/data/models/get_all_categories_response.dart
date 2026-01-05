import 'package:json_annotation/json_annotation.dart';

part 'get_all_categories_response.g.dart';

@JsonSerializable()
class CategoryModel {
  final String? id;
  final String? name;

  CategoryModel({this.id, this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
