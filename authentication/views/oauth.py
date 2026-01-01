from authentication.serializers import UserSerializer, RegisterSerializer, LoginSerializer
from django.contrib.auth import authenticate, get_user_model
from rest_framework.authtoken.models import Token
from rest_framework import status, permissions
from rest_framework.response import Response
from core import utils, models as core_m
from rest_framework.views import APIView
from django.conf import settings
from authentication import models as m

import requests, random


class GoogleAuthAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    access_token = request.data.get("access_token")
    google_response = requests.get(settings.GOOGLE_OAUTH["USER_INFO_URI"], headers={"Authorization": f"Bearer {access_token}"})
    if google_response.status_code != 200: return Response({"status": False, "message": "Invalid Google token"}, status=400)
    data = google_response.json()
    email = data.get("email")
    user, created = User.objects.get_or_create(email=email, defaults={"username": email.split("@")[0], "first_name": data.get("given_name", ""), "last_name": data.get("family_name", ""),})
    if created:
      user.set_unusable_password()
      user.save()
    otp = str(random.randint(100000, 999999))
    core_m.OTPs.objects.create(user=user, code=otp, otp_type="register")
    utils.send_whatsapp_in_background(to=user.phone, full_name=user.get_full_name(), code=otp, template="otp_verify")
    return Response({"status": True, "message": "OTP sent to verify phone number", "is_new": created})
