from django.contrib import admin
from .models import SalesInvoice, PurchaseInvoice, ReturnInvoice, Expense

@admin.register(SalesInvoice)
class SalesInvoiceAdmin(admin.ModelAdmin):
    list_display = ("id", "customer", "total")
    search_fields = ("customer__name", "id")

@admin.register(PurchaseInvoice)
class PurchaseInvoiceAdmin(admin.ModelAdmin):
    list_display = ("id", "supplier", "total")
    search_fields = ("supplier__person_name", "id")

@admin.register(ReturnInvoice)
class ReturnInvoiceAdmin(admin.ModelAdmin):
    list_display = ("id", "partner_type", "total")
    search_fields = ("customer__name", "supplier__person_name", "id")

@admin.register(Expense)
class ExpenseAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "amount", "category")
    search_fields = ("title", "category")