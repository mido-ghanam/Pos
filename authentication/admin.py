from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import Users

@admin.register(Users)
class CustomUserAdmin(UserAdmin):
  model = Users
  list_display = ("username", "email", "first_name", "last_name", "phone", "verified", "is_staff", "is_active", "date_joined")
  list_filter = ("verified", "is_staff", "is_active")
  search_fields = ("username", "email", "phone")
  ordering = ("date_joined",)
  fieldsets = (
      (None, {"fields": ("username", "email", "password")}),
      ("Personal info", {"fields": ("first_name", "last_name", "phone")}),
      ("Permissions", {"fields": ("is_staff", "is_active", "verified")}),
      ("Important dates", {"fields": ("last_login", "date_joined")}),
  )
