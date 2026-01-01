from rest_framework import serializers
from .models import Customers, Suppliers, OTPVerification
import re

class OTPVerificationSerializer(serializers.ModelSerializer):
  class Meta:
    model = OTPVerification
    fields = ['id', 'phone', 'otp_code', 'is_verified', 'partner_type', 'created_at']
    read_only_fields = ('id', 'created_at', 'is_verified')


class CustomerSerializer(serializers.ModelSerializer):
  class Meta:
    model = Customers
    fields = ['id', 'name', 'phone', 'address', 'blocked', 'vip', 'notes', 'is_verified', 'created_at', 'updated_at' ]
    read_only_fields = ('id', 'created_at', 'updated_at', 'is_verified')
  def validate_name(self, value):
    if not value or not value.strip(): raise serializers.ValidationError("Customer name is required")
    return value

  def validate_phone(self, value):
    if value:
      if not re.match(r'^[\d\s+\-()]+$', value): raise serializers.ValidationError("Phone contains invalid characters")
    return value


class CustomerRegistrationSerializer(serializers.ModelSerializer):
  """Serializer for customer registration with OTP"""
  class Meta:
    model = Customers
    fields = ['name', 'phone', 'address', 'notes']
  
  def validate_phone(self, value):
    if not value: raise serializers.ValidationError("Phone number is required")
    if not re.match(r'^[\d\s+\-()]+$', value): raise serializers.ValidationError("Phone contains invalid characters")
    return value


class SupplierSerializer(serializers.ModelSerializer):
  class Meta:
    model = Suppliers
    fields = ['id', 'person_name', 'company_name', 'phone', 'address', 'active', 'notes', 'is_verified', 'created_at', 'updated_at']
    read_only_fields = ('id', 'created_at', 'updated_at', 'is_verified')
  def validate_person_name(self, value):
    if not value or not value.strip(): raise serializers.ValidationError("Person name is required")
    return value
  def validate_phone(self, value):
    if value:
      if not re.match(r'^[\d\s+\-()]+$', value): raise serializers.ValidationError("Phone contains invalid characters")
    return value


class SupplierRegistrationSerializer(serializers.ModelSerializer):
  """Serializer for supplier registration with OTP"""
  class Meta:
    model = Suppliers
    fields = ['person_name', 'company_name', 'phone', 'address', 'notes']
  
  def validate_phone(self, value):
    if not value: raise serializers.ValidationError("Phone number is required")
    if not re.match(r'^[\d\s+\-()]+$', value): raise serializers.ValidationError("Phone contains invalid characters")
    return value
