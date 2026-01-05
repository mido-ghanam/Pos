  import 'package:json_annotation/json_annotation.dart';
  part 'add_category_request_body.g.dart';

  @JsonSerializable()
  class AddCategoryRequestBody {
    final String name;

    AddCategoryRequestBody({required this.name});

    Map<String, dynamic> toJson() => _$AddCategoryRequestBodyToJson(this);
  }
