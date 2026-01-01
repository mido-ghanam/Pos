from ..serializers import UserSerializer, LoginSerializer
from django.contrib.auth import authenticate, get_user_model
from rest_framework.authtoken.models import Token
from rest_framework import status, permissions
from rest_framework.response import Response
from core import utils, models as core_m
from rest_framework.views import APIView
from django.contrib.auth import login
from .. import models as m
import random

User = get_user_model()
OTP_EXPIRY_SECONDS = 300

class LoginOTPAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    serializer = LoginSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = authenticate(request, username=serializer.validated_data["username"], password=serializer.validated_data["password"])
    if not user: return Response({"status": False, "message": "Invalid credentials"}, status=401)
    otp = str(random.randint(100000, 999999))
    core_m.OTPs.objects.create(user=user, code=otp, otp_type="login")
    utils.send_whatsapp_in_background(to=user.phone, full_name=user.get_full_name(), code=otp, template="otp_login")
    return Response({"status": True, "message": "OTP sent"})

class ResendLoginOTPAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    username = request.data.get("username")
    user = User.objects.filter(username=username).first()
    if not user: return Response({"status": False, "message": "User not found"}, status=404)
    otp = str(random.randint(100000, 999999))
    core_m.OTPs.objects.create(user=user, code=otp, otp_type="login")
    utils.send_whatsapp_in_background(to=user.phone, full_name=user.get_full_name(), code=otp, template="otp_login")
    return Response({"status": True, "message": "OTP sent"})

class VerifyLoginOTPAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    username = request.data.get("username")
    otp = request.data.get("otp")
    user = User.objects.filter(username=username).first()
    if not user: return Response({"status": False, "message": "User not found"}, status=404)
    otp_obj = core_m.OTPs.objects.filter(user=user, code=otp, otp_type="login", is_used=False).first()
    if not otp_obj or otp_obj.is_expired(): return Response({"status": False, "message": "Invalid or expired OTP"}, status=400)
    otp_obj.is_used = True
    otp_obj.save()
    data = UserSerializer(user).data
    login(request, user)
    return Response({"status": True, "data": data, "tokens": utils.getUserTokens(user)})
