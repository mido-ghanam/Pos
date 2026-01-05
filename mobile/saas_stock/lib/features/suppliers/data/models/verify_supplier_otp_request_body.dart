class VerifySupplierOtpRequestBody {
  final String phone;
  final String otpCode;

  VerifySupplierOtpRequestBody({required this.phone, required this.otpCode});

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "otp_code": otpCode,
      };
}
