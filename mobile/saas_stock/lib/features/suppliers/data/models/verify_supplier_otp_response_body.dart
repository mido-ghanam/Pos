import 'supplier_model.dart';

class VerifySupplierOtpResponseBody {
  bool? status;
  String? message;
  SupplierModel? data;

  VerifySupplierOtpResponseBody({this.status, this.message, this.data});

  factory VerifySupplierOtpResponseBody.fromJson(Map<String, dynamic> json) {
    return VerifySupplierOtpResponseBody(
      status: json["status"],
      message: json["message"],
      data: json["data"] != null ? SupplierModel.fromJson(json["data"]) : null,
    );
  }
}
