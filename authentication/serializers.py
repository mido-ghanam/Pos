from rest_framework import serializers
from django.contrib.auth import get_user_model

Users = get_user_model()

class UserSerializer(serializers.ModelSerializer):
  class Meta:
    model = Users
    fields = ('id', 'username', 'email', 'first_name', 'last_name', 'phone', 'store')


class RegisterSerializer(serializers.ModelSerializer):
  password = serializers.CharField(write_only=True, min_length=8)
  class Meta:
    model = Users
    fields = ('id', 'username', 'email', 'password', 'first_name', 'last_name', 'phone')
  def create(self, validated_data):
    password = validated_data.pop('password')
    user = Users(**validated_data)
    user.set_password(password)
    user.save()
    return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=8)
