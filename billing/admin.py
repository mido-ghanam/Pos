from django.contrib import admin
from .models import SalesInvoice, SalesInvoiceItem, PurchaseInvoice, PurchaseInvoiceItem, ReturnInvoice, ReturnInvoiceItem
@admin.register(SalesInvoice)
class SalesInvoiceAdmin(admin.ModelAdmin):
    list_display = ("id", "customer", "total", "payment_method", "created_at")
    search_fields = ("customer__name", "payment_method")
    ordering = ("-created_at",)
@admin.register(PurchaseInvoice)
class PurchaseInvoiceAdmin(admin.ModelAdmin):
    list_display = ("id", "supplier", "total", "payment_method", "created_at")
    search_fields = ("supplier__name", "payment_method")
    ordering = ("-created_at",)
@admin.register(ReturnInvoice)
class ReturnInvoiceAdmin(admin.ModelAdmin):
    list_display = ("id", "partner_type", "customer", "supplier", "total", "created_at")
    search_fields = ("customer__name", "supplier__name", "partner_type")
    ordering = ("-created_at",)
@admin.register(SalesInvoiceItem)
class SalesInvoiceItemAdmin(admin.ModelAdmin):
    list_display = ("id", "invoice", "product", "quantity", "unit_price", "subtotal")
    search_fields = ("invoice__id", "product__name")
    ordering = ("-id",)

@admin.register(PurchaseInvoiceItem)
class PurchaseInvoiceItemAdmin(admin.ModelAdmin):
    list_display = ("id", "invoice", "product", "quantity", "unit_price", "subtotal")
    search_fields = ("invoice__id", "product__name")
    ordering = ("-id",)
@admin.register(ReturnInvoiceItem)
class ReturnInvoiceItemAdmin(admin.ModelAdmin):
    list_display = ("id", "invoice", "product", "quantity", "unit_price", "subtotal")
    search_fields = ("invoice__id", "product__name")
    ordering = ("-id",)