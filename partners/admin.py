from django.contrib import admin
from .models import *

@admin.register(OTPVerification)
class OTPVerificationAdmin(admin.ModelAdmin):
  list_display = ['phone', 'partner_type', 'is_verified', 'created_at', 'expires_at']
  list_filter = ['partner_type', 'is_verified', 'created_at']
  search_fields = ['phone', 'otp_code']
  readonly_fields = ['id', 'created_at']

@admin.register(Customers)
class CustomersAdmin(admin.ModelAdmin):
  list_display = ['name', 'phone', 'blocked', 'vip', 'is_verified', 'created_at']
  list_filter = ['blocked', 'vip', 'is_verified', 'created_at']
  search_fields = ['name', 'phone']
  readonly_fields = ['id', 'created_at', 'updated_at']

@admin.register(Suppliers)
class SuppliersAdmin(admin.ModelAdmin):
  list_display = ['person_name', 'company_name', 'phone', 'active', 'is_verified', 'created_at']
  list_filter = ['active', 'is_verified', 'created_at']
  search_fields = ['person_name', 'company_name', 'phone']
  readonly_fields = ['id', 'created_at', 'updated_at']
