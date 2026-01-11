from django.contrib import admin
from .models import OTPs

@admin.register(OTPs)
class OTPsAdmin(admin.ModelAdmin):
    list_display = ("user", "code", "otp_type", "is_used")
    list_filter = ("otp_type", "is_used")
    search_fields = ("user__username", "code")
