from rest_framework import serializers
from .models import Customers, Suppliers


class CustomerSerializer(serializers.ModelSerializer):
  class Meta:
    model = Customers
    fields = [
      'id', 'name', 'phone', 'address', 'blocked', 'vip', 'notes', 'created_at', 'updated_at'
    ]
    read_only_fields = ('id', 'created_at', 'updated_at')

  def validate_name(self, value):
    if not value or not value.strip():
      raise serializers.ValidationError("Customer name is required")
    return value

  def validate_phone(self, value):
    # basic phone validation similar to SupplierSerializer
    if value:
      import re
      if not re.match(r'^[\d\s+\-()]+$', value):
        raise serializers.ValidationError("Phone contains invalid characters")
    return value


class SupplierSerializer(serializers.ModelSerializer):
  class Meta:
    model = Suppliers
    fields = [
      'id', 'person_name', 'company_name', 'phone', 'address', 'active', 'notes', 'created_at', 'updated_at'
    ]
    read_only_fields = ('id', 'created_at', 'updated_at')

  def validate_person_name(self, value):
    if not value or not value.strip():
      raise serializers.ValidationError("Person name is required")
    return value

  def validate_phone(self, value):
    # basic phone validation: digits and optional +,-, spaces
    if value:
      import re
      if not re.match(r'^[\d\s+\-()]+$', value):
        raise serializers.ValidationError("Phone contains invalid characters")
    return value
