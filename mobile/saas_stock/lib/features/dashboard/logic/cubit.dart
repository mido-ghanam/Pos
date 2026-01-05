import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/helpers/constants.dart';
import 'package:saas_stock/core/helpers/shared_pref_helper.dart';
import 'package:saas_stock/core/networking/dio_factory.dart';
import 'package:saas_stock/features/dashboard/data/repositories/auth_repo.dart';
import 'package:saas_stock/features/dashboard/logic/states.dart';


class LogoutCubit extends Cubit<LogoutState> {
  final AuthRepo repo;
  LogoutCubit(this.repo) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());

    // ✅ خزن refresh قبل ما تمسحه
    final refreshToken = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.refreshToken,
    );

    final res = await repo.logout(refreshToken: refreshToken);

    res.when(
      success: (data) async {
        // ✅ امسح كل حاجة محلي (حتى لو السيرفر رجع success)
        await _localLogout();

        emit(LogoutSuccess(data["message"] ?? "تم تسجيل الخروج ✅"));
      },
      failure: (err) async {
        // ✅ حتى لو فشل السيرفر.. امسح محلي عشان المستخدم يطلع
        await _localLogout();

        emit(LogoutError(err.apiErrorModel.message ?? "Logout failed"));
      },
    );
  }

  Future<void> _localLogout() async {
    await SharedPrefHelper.clearAllSecuredData();
    DioFactory.clearToken();
  }
}
