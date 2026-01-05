import 'supplier_model.dart';

class UpdateSupplierResponseBody {
  bool? status;
  SupplierModel? data;

  UpdateSupplierResponseBody({this.status, this.data});

  factory UpdateSupplierResponseBody.fromJson(Map<String, dynamic> json) {
    return UpdateSupplierResponseBody(
      status: json["status"],
      data: json["data"] != null ? SupplierModel.fromJson(json["data"]) : null,
    );
  }
}
