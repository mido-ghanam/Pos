import 'supplier_model.dart';

class GetSuppliersResponseBody {
  bool? status;
  int? count;
  List<SupplierModel>? data;

  GetSuppliersResponseBody({this.status, this.count, this.data});

  factory GetSuppliersResponseBody.fromJson(Map<String, dynamic> json) {
    return GetSuppliersResponseBody(
      status: json["status"],
      count: json["count"],
      data: (json["data"] as List?)
          ?.map((e) => SupplierModel.fromJson(e))
          .toList(),
    );
  }
}
