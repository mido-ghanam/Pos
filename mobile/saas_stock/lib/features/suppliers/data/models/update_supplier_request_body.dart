class UpdateSupplierRequestBody {
  final String personName;
  final String companyName;
  final String phone;
  final String address;
  final bool blocked;
  final bool vip;
  final String notes;
  final bool isVerified;

  UpdateSupplierRequestBody({
    required this.personName,
    required this.companyName,
    required this.phone,
    required this.address,
    required this.blocked,
    required this.vip,
    required this.notes,
    required this.isVerified,
  });

  Map<String, dynamic> toJson() => {
        "person_name": personName,
        "company_name": companyName,
        "phone": phone,
        "address": address,
        "blocked": blocked,
        "vip": vip,
        "notes": notes,
        "is_verified": isVerified,
      };
}
