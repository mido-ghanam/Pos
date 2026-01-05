import 'package:json_annotation/json_annotation.dart';
import 'customer_model.dart';

part 'get_customers_response_body.g.dart';

@JsonSerializable()
class GetCustomersResponseBody {
  final bool? status;
  final int? count;
  final List<CustomerModel>? data;

  GetCustomersResponseBody({
    this.status,
    this.count,
    this.data,
  });

  factory GetCustomersResponseBody.fromJson(Map<String, dynamic> json) =>
      _$GetCustomersResponseBodyFromJson(json);
}
