class SupplierModel {
  String? id;
  String? personName;
  String? companyName;
  String? phone;
  String? address;
  bool? blocked;
  bool? vip;
  String? notes;
  bool? isVerified;
  String? createdAt;
  String? updatedAt;

  SupplierModel({
    this.id,
    this.personName,
    this.companyName,
    this.phone,
    this.address,
    this.blocked,
    this.vip,
    this.notes,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json["id"],
      personName: json["person_name"],
      companyName: json["company_name"],
      phone: json["phone"],
      address: json["address"],
      blocked: json["blocked"],
      vip: json["vip"],
      notes: json["notes"],
      isVerified: json["is_verified"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
}
