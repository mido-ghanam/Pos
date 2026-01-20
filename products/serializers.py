from rest_framework import serializers
from .models import Products, Category

class CategoriesSerializer(serializers.ModelSerializer):
  class Meta: model, fields = Category, ('id', 'name')

class AddCategoriesSerializer(serializers.Serializer): name = serializers.CharField()
  
class AllProductsSerializer(serializers.ModelSerializer):
  category = serializers.ReadOnlyField(source="category.name")
  class Meta: model, fields = Products, ('id', 'name', 'category', "unit_scale", "barcode", "quantity", 'buy_price', "sell_price", "min_quantity", "active", "monitor")

class GetProductSerializer(serializers.ModelSerializer):
  category = CategoriesSerializer()
  class Meta: model, fields = Products, ('id', 'name', 'barcode', "unit_scale", 'category', 'discription', 'buy_price', "sell_price", "quantity", "min_quantity", "active", "monitor")

class AddProductSerializer(serializers.Serializer):
  name = serializers.CharField()
  barcode = serializers.IntegerField()
  category = serializers.CharField()
  unit_scale = serializers.CharField(required=False)
  discription = serializers.CharField(required=False, allow_blank=True)
  buy_price = serializers.FloatField()
  sell_price = serializers.FloatField()
  quantity = serializers.FloatField(required=False)
  min_quantity = serializers.FloatField(required=False)
  active = serializers.BooleanField(required=False, default=True)
  monitor = serializers.BooleanField(required=False, default=False)

class EditProductSerializer(serializers.ModelSerializer): 
  class Meta: model, fields = Products, ["name", "price", "category", "description", "unit_scale"]
