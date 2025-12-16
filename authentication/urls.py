from django.urls import path
from . import views as v

urlpatterns = [
  path('register/', v.RegisterAPIView.as_view(), name='register'),
  path('login/', v.LoginAPIView.as_view(), name='login'),
  path('logout/', v.LogoutAPIView.as_view(), name='logout'),
  path('me/', v.MeAPIView.as_view(), name='me'),
  path('change-password/', v.ChangePasswordAPIView.as_view(), name='change-password'),
]