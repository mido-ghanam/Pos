class RegisterSupplierRequestBody {
  final String personName;
  final String companyName;
  final String phone;
  final String address;
  final String notes;

  RegisterSupplierRequestBody({
    required this.personName,
    required this.companyName,
    required this.phone,
    required this.address,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        "person_name": personName,
        "company_name": companyName,
        "phone": phone,
        "address": address,
        "notes": notes,
      };
}
