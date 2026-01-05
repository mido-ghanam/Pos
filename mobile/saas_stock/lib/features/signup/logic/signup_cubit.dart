import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/helpers/app_regex.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/features/auth_otp/ui/screens/otp_screen.dart';
import 'package:saas_stock/features/signup/data/models/register_request_body.dart';
import 'package:saas_stock/features/signup/data/repos/signup_repo.dart';
import 'package:saas_stock/features/signup/logic/signup_states.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo registerRepo;

  RegisterCubit(this.registerRepo) : super(RegisterInitial());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> emitRegisterState(BuildContext context) async {
    if (state is RegisterLoading) return;

    emit(RegisterLoading());

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final phone = phoneController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    // ✅ Username validation
    if (username.isEmpty) {
      emit(RegisterError('اسم المستخدم مطلوب'));
      return;
    }
    if (username.length < 3) {
      emit(RegisterError('اسم المستخدم يجب أن يكون 3 أحرف على الأقل'));
      return;
    }

    // ✅ Phone validation
    if (phone.isEmpty) {
      emit(RegisterError('رقم الهاتف مطلوب'));
      return;
    }
    if (!AppRegex.isPhoneNumberValid(phone)) {
      emit(RegisterError('رقم الهاتف غير صحيح (مثال: 010xxxxxxxx)'));
      return;
    }

    // ✅ Names validation
    if (firstName.isEmpty) {
      emit(RegisterError('الاسم الأول مطلوب'));
      return;
    }
    if (lastName.isEmpty) {
      emit(RegisterError('اسم العائلة مطلوب'));
      return;
    }

    // ✅ Password validation
    if (password.isEmpty) {
      emit(RegisterError('كلمة المرور مطلوبة'));
      return;
    }

    // ✅ Strong password check
    if (!AppRegex.isPasswordValid(password)) {
      emit(RegisterError(
          'كلمة المرور يجب أن تكون 8 أحرف + حرف صغير وكبير + رقم + رمز'));
      return;
    }

    if (confirmPassword.isEmpty) {
      emit(RegisterError('تأكيد كلمة المرور مطلوب'));
      return;
    }

    if (password != confirmPassword) {
      emit(RegisterError('كلمة المرور غير متطابقة'));
      return;
    }

    final response = await registerRepo.register(
      RegisterRequestBody(
        username: username,
        password: password,
        phone: phone,
        first_name: firstName,
        last_name: lastName,
      ),
    );

    response.when(
      success: (registerResponse) async {
        final message = registerResponse.message ?? 'تم التسجيل بنجاح';
        emit(RegisterSuccess(message));

        // ✅ OTP
        if (context.mounted) {
          await Future.delayed(const Duration(milliseconds: 300));
          Navigator.pushNamed(
            context,
            Routers.otp,
            arguments: OtpArgs(username: username, mode: OtpMode.register),
          );
        }
      },
      failure: (error) {
        emit(RegisterError(
          error.apiErrorModel.readableMessage ??
              error.apiErrorModel.message ??
              'حدث خطأ في التسجيل',
        ));
      },
    );
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(state);
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    emit(state);
  }

  @override
  Future<void> close() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    return super.close();
  }
}
