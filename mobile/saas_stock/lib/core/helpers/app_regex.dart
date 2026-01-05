class AppRegex {
  /// ✅ Email
  static bool isEmailValid(String email) {
    return RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    ).hasMatch(email.trim());
  }

  /// ✅ Password (Strong password)
  /// at least 8 chars + lower + upper + number + special
  static bool isPasswordValid(String password) {
    return RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",
    ).hasMatch(password.trim());
  }

  /// ✅ Egyptian phone
  static bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^(010|011|012|015)[0-9]{8}$')
        .hasMatch(phoneNumber.trim());
  }

  static bool hasLowerCase(String password) {
    return RegExp(r'(?=.*[a-z])').hasMatch(password);
  }

  static bool hasUpperCase(String password) {
    return RegExp(r'(?=.*[A-Z])').hasMatch(password);
  }

  static bool hasNumber(String password) {
    return RegExp(r'(?=.*?[0-9])').hasMatch(password);
  }

  static bool hasSpecialCharacter(String password) {
    return RegExp(r'(?=.*?[#?!@$%^&*-])').hasMatch(password);
  }

  static bool hasMinLength(String password) {
    return password.length >= 8;
  }

  /// ✅ OTP Validation
  static bool isOtpValid(String otp) {
    return RegExp(r'^\d{4,6}$').hasMatch(otp.trim());
  }
}
