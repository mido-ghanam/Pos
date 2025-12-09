from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
	list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'store')
	fieldsets = UserAdmin.fieldsets + (
		('Store', {'fields': ('store',)}),
	)


from .models import Store


@admin.register(Store)
class StoreAdmin(admin.ModelAdmin):
    list_display = ('name', 'type', 'created_at')
    search_fields = ('name', 'type')


from .models import Business


@admin.register(Business)
class BusinessAdmin(admin.ModelAdmin):
	list_display = ('name', 'business_type', 'owner', 'created_at')
	list_filter = ('business_type', 'created_at')
	search_fields = ('name', 'owner__username')
