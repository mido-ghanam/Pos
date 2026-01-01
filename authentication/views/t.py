from .serializers import UserSerializer, RegisterSerializer, LoginSerializer
from django.contrib.auth import authenticate, get_user_model
from rest_framework.authtoken.models import Token
from rest_framework import status, permissions
from rest_framework.response import Response
from core import utils, models as core_m
from rest_framework.views import APIView
from django.contrib.auth import login
from django.conf import settings
from . import models as m
import requests, random

User = get_user_model()
OTP_EXPIRY_SECONDS = 300

class RequestChangePasswordOTPAPIView(APIView):
  permission_classes = (permissions.IsAuthenticated,)
  def post(self, request):
    otp = str(random.randint(100000, 999999))
    core_m.OTPs.objects.create(user=request.user, code=otp, otp_type="change_password")
    utils.send_whatsapp_in_background(
          to=request.user.phone,
          full_name=request.user.get_full_name(),
          code=otp,
          template="otp_change_password"
      )
    return Response({"status": True, "message": "OTP sent"})

class VerifyChangePasswordAPIView(APIView):
  permission_classes = (permissions.IsAuthenticated,)
  def post(self, request):
      otp = request.data.get("otp")
      new_password = request.data.get("new_password")

      otp_obj = core_m.LoginOTP.objects.filter(
          user=request.user,
          code=otp,
          otp_type=m.OTPType.CHANGE_PASSWORD,
          is_used=False
      ).first()

      if not otp_obj or otp_obj.is_expired():
          return Response({"status": False, "message": "Invalid or expired OTP"}, status=400)

      request.user.set_password(new_password)
      request.user.save()

      otp_obj.is_used = True
      otp_obj.save()

      Token.objects.filter(user=request.user).delete()

      return Response({"status": True, "message": "Password changed successfully"})
