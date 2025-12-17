from django.contrib.auth.admin import UserAdmin
from django.contrib import admin
from .models import Users

#admin.site.register(Users)

@admin.register(Users)
class CustomUserAdmin(UserAdmin):
  list_display = [field.name for field in Users._meta.fields if str(field.name) != "password" ]
