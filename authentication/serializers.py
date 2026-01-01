from django.contrib.auth import get_user_model
from rest_framework import serializers
from core.models import OTPs

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
  class Meta:
    model = User
    fields = ("id", "username", "email", "first_name", "last_name", "phone", "verified", "created_at")
    read_only_fields = ("id", "verified", "created_at")

class RegisterSerializer(serializers.ModelSerializer):
  password = serializers.CharField(write_only=True, min_length=8)
  class Meta:
    model = User
    fields = ("id", "username", "email", "password", "first_name", "last_name", "phone")
  def create(self, validated_data):
    password = validated_data.pop("password")
    user = User(**validated_data)
    user.set_password(password)
    user.verified = False
    user.save()
    return user

class LoginSerializer(serializers.Serializer):
  username = serializers.CharField()
  password = serializers.CharField(write_only=True)

class ChangePasswordSerializer(serializers.Serializer): new_password = serializers.CharField(write_only=True, min_length=8)

class VerifyOTPSerializer(serializers.Serializer):
  username = serializers.CharField()
  otp = serializers.CharField(min_length=6, max_length=6)
  otp_type = serializers.ChoiceField(choices=OTPs.OTP_CHOICES)

class GoogleAuthSerializer(serializers.Serializer): access_token = serializers.CharField()

class RequestOTPSerializer(serializers.Serializer): otp_type = serializers.ChoiceField(choices=OTPs.OTP_CHOICES)
