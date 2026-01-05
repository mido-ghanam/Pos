class RegisterSupplierResponseBody {
  bool? status;
  String? message;
  String? phone;
  String? nextStep;

  RegisterSupplierResponseBody({this.status, this.message, this.phone, this.nextStep});

  factory RegisterSupplierResponseBody.fromJson(Map<String, dynamic> json) {
    return RegisterSupplierResponseBody(
      status: json["status"],
      message: json["message"],
      phone: json["phone"],
      nextStep: json["next_step"],
    );
  }
}
