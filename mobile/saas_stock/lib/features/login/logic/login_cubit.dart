import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/helpers/app_regex.dart';
import 'package:saas_stock/features/login/data/model/login_request_body.dart';
import 'package:saas_stock/features/login/data/repo/login_repo.dart';
import 'package:saas_stock/features/login/logic/login_states.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;

  LoginCubit(this.loginRepo) : super(LoginInitial());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  Future<void> emitLoginState(BuildContext context) async {
    if (state is LoginLoading) return;

    emit(LoginLoading());

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // ✅ Username validation
    if (username.isEmpty) {
      emit(LoginError('اسم المستخدم مطلوب'));
      return;
    }

    if (username.length < 3) {
      emit(LoginError('اسم المستخدم يجب أن يكون 3 أحرف على الأقل'));
      return;
    }

    // ✅ Password validation
    if (password.isEmpty) {
      emit(LoginError('كلمة المرور مطلوبة'));
      return;
    }

    // ✅ لو عايز قوي
    if (!AppRegex.hasMinLength(password)) {
      emit(LoginError('كلمة المرور يجب أن تكون 8 أحرف على الأقل'));
      return;
    }

    final response = await loginRepo.login(
      LoginRequestBody(username: username, password: password),
    );

    response.when(
      success: (loginResponse) async {
        if (loginResponse.status == true) {
          emit(LoginOtpSent(
            message: loginResponse.message ?? "OTP sent",
            username: username,
          ));
        } else {
          emit(LoginError(loginResponse.message ?? 'فشل تسجيل الدخول'));
        }
      },
      failure: (error) {
        emit(LoginError(
          error.apiErrorModel.readableMessage ??
              error.apiErrorModel.message ??
              'حدث خطأ في الاتصال بالسيرفر',
        ));
      },
    );
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(state);
  }

  @override
  Future<void> close() {
    usernameController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
