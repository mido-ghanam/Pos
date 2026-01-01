from rest_framework_simplejwt.views import TokenRefreshView
from django.urls import path
from . import views as v
from authentication.views.logout import LogoutAPIView


urlpatterns = [
  path("register/", v.register.RegisterAPIView.as_view(), name="register"),
  path("register/verify/", v.register.VerifyRegisterOTPAPIView.as_view(), name="register-verify"),
  path("register/verify/resendOTP/", v.register.ResendRegisterOTPAPIView.as_view(), name="register-verify-resendOTP"),
  path("login/", v.login.LoginOTPAPIView.as_view(), name="login"),
  path("login/verify/", v.login.VerifyLoginOTPAPIView.as_view(), name="login-verify"),
  path("login/verify/resendOTP/", v.login.ResendLoginOTPAPIView.as_view(), name="login-verify-resendOTP"),
  #path("google/callback/", v.GoogleAuthAPIView.as_view(), name="google-auth"),
  path("me/", v.AccountCenter.me.MeAPIView.as_view(), name="me"),

  path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
  path("logout/", LogoutAPIView.as_view(), name="logout"),

  #path("change-password/", v.RequestChangePasswordOTPAPIView.as_view(), name="change-password-request"),
  #path("change-password/verify/", v.VerifyChangePasswordAPIView.as_view(), name="change-password-verify"),
]
