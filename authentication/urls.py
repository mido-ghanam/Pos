from rest_framework_simplejwt.views import TokenRefreshView
from django.urls import path
from . import views as v

urlpatterns = [
  path("register/", v.auth.RegisterAPIView.as_view(), name="register"),
  path("login/", v.auth.LoginOTPAPIView.as_view(), name="login"),
  path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
  path("change-password/", v.account_center.forget_password.ChangePasswordAPIView.as_view(), name="request-forgot_password"),
  path("logout/", v.auth.LogoutAPIView.as_view(), name="logout"),
]