from authentication.serializers import UserSerializer, RegisterSerializer, LoginSerializer
from django.contrib.auth import authenticate, get_user_model
from rest_framework.authtoken.models import Token
from rest_framework import status, permissions
from rest_framework.response import Response
from core import utils, models as core_m
from rest_framework.views import APIView
from django.contrib.auth import login
from django.conf import settings
from authentication import models as m
import random

User = get_user_model()
OTP_EXPIRY_SECONDS = 300


class RegisterAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    serializer = RegisterSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.save()
    otp = str(random.randint(100000, 999999))
    core_m.OTPs.objects.create(user=user, code=otp, otp_type="register")
    utils.send_whatsapp_in_background(to=user.phone, full_name=user.get_full_name(), code=otp, template="otp_registration")
    return Response({"status": True, "message": "User created. OTP sent for verification.",}, status=status.HTTP_201_CREATED)

class ResendRegisterOTPAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    username = request.data.get("username")
    user = User.objects.filter(username=username).first()
    if not user: return Response({"status": False, "message": "User not found"}, status=404)
    if user.verified: return Response({"status": False, "message": "User is already verified"}, status=400)
    otp = str(random.randint(100000, 999999))
    core_m.OTPs.objects.create(user=user, code=otp, otp_type="register")
    utils.send_whatsapp_in_background(to=user.phone, full_name=user.get_full_name(), code=otp, template="otp_registration")
    return Response({"status": True, "message": "Verification code has been sent successfully"}, status=status.HTTP_200_OK)

class VerifyRegisterOTPAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    username, otp = request.data.get("username"), request.data.get("otp")
    user = User.objects.filter(username=username).first()
    if not user: return Response({"status": False, "message": "User not found"}, status=404)
    otp_obj = core_m.OTPs.objects.filter(user=user, code=otp, otp_type="register", is_used=False).first()
    if not otp_obj or otp_obj.is_expired(): return Response({"status": False, "message": "Invalid or expired OTP"}, status=400)
    otp_obj.is_used, user.verified = True, True
    otp_obj.save(), user.save()
    msg = f"""Welcome aboard,\n
*We are pleased to inform you that your phone number has been successfully verified.*
*Your account has been activated, and you may now proceed to use our services without any restrictions.*
*Should you need any assistance, our support team is always available.*
\n*Sincerely*,
*Pos system Team*"""
    utils.send_whatsapp_in_background(to=user.phone, msg=msg, template="text_message")
    return Response({"status": True, "message": "Account verified successfully"})
