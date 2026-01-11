from django.contrib import admin
from .models import Category, Products

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)

@admin.register(Products)
class ProductsAdmin(admin.ModelAdmin):
    list_display = ("name", "category", "buy_price", "sell_price", "quantity")
    list_filter = ("category",)
    search_fields = ("name", "category__name")
