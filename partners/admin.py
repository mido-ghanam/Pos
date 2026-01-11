from django.contrib import admin
from .models import OTPVerification, Customers, Suppliers

@admin.register(OTPVerification)
class OTPVerificationAdmin(admin.ModelAdmin):
    list_display = ("phone", "partner_type", "is_verified")
    search_fields = ("phone", "otp_code")

@admin.register(Customers)
class CustomersAdmin(admin.ModelAdmin):
    list_display = ("name", "phone", "blocked", "vip")
    list_filter = ("blocked", "vip")
    search_fields = ("name", "phone")

@admin.register(Suppliers)
class SuppliersAdmin(admin.ModelAdmin):
    list_display = ("person_name", "company_name", "phone", "active")
    list_filter = ("active",)
    search_fields = ("person_name", "company_name", "phone")
