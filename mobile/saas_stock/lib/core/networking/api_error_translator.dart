class ApiErrorTranslator {
  static String translate(String msg) {
    final lower = msg.toLowerCase();

    if (lower.contains("ensure this field has at least 8 characters")) {
      return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
    }

    if (lower.contains("already exists")) {
      return "هذا المستخدم موجود بالفعل";
    }

    if (lower.contains("invalid or expired otp")) {
      return "الكود غير صحيح أو منتهي الصلاحية";
    }

    if (lower.contains("no active account")) {
      return "اسم المستخدم أو كلمة المرور غير صحيحة";
    }

    return msg; // fallback
  }
}
