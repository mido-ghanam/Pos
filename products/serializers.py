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

class AddProductSerializer(serializers.Serializer):
  name = serializers.CharField()
  barcode = serializers.IntegerField()
  category = serializers.CharField()
  discription = serializers.CharField(required=False, allow_blank=True)
  buy_price = serializers.FloatField()
  sell_price = serializers.FloatField()
  quantity = serializers.FloatField(required=False)
  min_quantity = serializers.FloatField(required=False)
  active = serializers.BooleanField(required=False, default=True)
  monitor = serializers.BooleanField(required=False, default=False)

