import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/helpers/app_regex.dart';
import 'package:saas_stock/core/helpers/constants.dart';
import 'package:saas_stock/core/helpers/shared_pref_helper.dart';
import 'package:saas_stock/core/networking/dio_factory.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/features/auth_otp/data/models/otp_verify_request_body.dart';
import 'package:saas_stock/features/auth_otp/data/repo/otp_repo.dart';
import 'package:saas_stock/features/auth_otp/logic/otp_states.dart';
import 'package:saas_stock/features/auth_otp/ui/screens/otp_screen.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepo otpRepo;

  OtpCubit(this.otpRepo) : super(OtpInitial());

  final TextEditingController otpController = TextEditingController();

  Future<void> verifyOtp({
    required BuildContext context,
    required String username,
    required OtpMode mode,
  }) async {
    if (state is OtpLoading) return;

    final otp = otpController.text.trim();

    // ✅ OTP validation by regex
    if (!AppRegex.isOtpValid(otp)) {
      emit(OtpError("من فضلك أدخل كود صحيح"));
      return;
    }

    emit(OtpLoading());

    final body = OtpVerifyRequestBody(username: username, otp: otp);

    if (mode == OtpMode.register) {
      final res = await otpRepo.registerVerify(body);

      res.when(
        success: (data) async {
          if (data.status == true) {
            emit(OtpSuccess(data.message ?? "تم تفعيل الحساب ✅"));
            if (context.mounted) {
              await Future.delayed(const Duration(milliseconds: 300));
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routers.login,
                (route) => false,
              );
            }
          } else {
            emit(OtpError(data.message ?? "Invalid or expired OTP"));
          }
        },
        failure: (err) {
          emit(OtpError(
            err.apiErrorModel.readableMessage ??
                err.apiErrorModel.message ??
                "فشل التحقق",
          ));
        },
      );
    } else {
      final res = await otpRepo.loginVerify(body);

      res.when(
        success: (data) async {
          final access = data.tokens?.access;
          final refresh = data.tokens?.refresh;

          if (access == null || access.isEmpty) {
            emit(OtpError("لم يتم استلام التوكن من السيرفر"));
            return;
          }

          await SharedPrefHelper.setSecuredString(
            SharedPrefKeys.userToken,
            access,
          );

          if (refresh != null && refresh.isNotEmpty) {
            await SharedPrefHelper.setSecuredString(
              SharedPrefKeys.refreshToken,
              refresh,
            );
          }

          final u = data.data?.username;
          if (u != null && u.isNotEmpty) {
            await SharedPrefHelper.setSecuredString(
              SharedPrefKeys.userName,
              u,
            );
          }

          isLoggedInUser = true;
          DioFactory.setTokenIntoHeaderAfterLogin(access);

          emit(OtpSuccess("تم تسجيل الدخول بنجاح ✅"));

          if (context.mounted) {
            await Future.delayed(const Duration(milliseconds: 300));
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routers.home,
              (route) => false,
            );
          }
        },
        failure: (err) {
          emit(OtpError(
            err.apiErrorModel.readableMessage ??
                err.apiErrorModel.message ??
                "Invalid or expired OTP",
          ));
        },
      );
    }
  }

  Future<void> resendOtp({
    required String username,
    required OtpMode mode,
  }) async {
    emit(OtpResendLoading());

    final res = mode == OtpMode.login
        ? await otpRepo.resendLoginOtp(username)
        : await otpRepo.resendRegisterOtp(username);

    res.when(
      success: (data) {
        emit(OtpSuccess(data.message ?? "تم إرسال الكود ✅"));
      },
      failure: (err) {
        emit(OtpError(
          err.apiErrorModel.readableMessage ??
              err.apiErrorModel.message ??
              "فشل إعادة الإرسال",
        ));
      },
    );
  }

  @override
  Future<void> close() {
    otpController.dispose();
    return super.close();
  }
}
