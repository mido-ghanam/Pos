from rest_framework import serializers
from .models import Products, Category

class AllProductsSerializer(serializers.ModelSerializer):
  category = serializers.ReadOnlyField(source="category.name")
  class Meta:
    model = Products
    fields = ('id', 'name', 'category', "barcode", "quantity", 'buy_price', "sell_price", "min_quantity", "active", "monitor")

class CategoriesSerializer(serializers.ModelSerializer):
  class Meta:
    model = Category
    fields = ('id', 'name')

class GetProductSerializer(serializers.ModelSerializer):
  category = CategoriesSerializer()
  class Meta:
    model = Products
    fields = ('id', 'name', 'barcode', 'category', 'discription', 'buy_price', "sell_price", "quantity", "min_quantity", "active", "monitor")
