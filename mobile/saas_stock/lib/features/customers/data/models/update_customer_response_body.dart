import 'package:json_annotation/json_annotation.dart';
import 'customer_model.dart';

part 'update_customer_response_body.g.dart';

@JsonSerializable()
class UpdateCustomerResponseBody {
  final bool? status;
  final CustomerModel? data;

  UpdateCustomerResponseBody({
    this.status,
    this.data,
  });

  factory UpdateCustomerResponseBody.fromJson(Map<String, dynamic> json) =>
      _$UpdateCustomerResponseBodyFromJson(json);
}
