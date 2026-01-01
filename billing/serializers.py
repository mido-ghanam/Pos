from rest_framework import serializers
from .models import SalesInvoice, SalesInvoiceItem, PurchaseInvoice, PurchaseInvoiceItem, ReturnInvoice, ReturnInvoiceItem
from products.models import Products as Product
from partners.serializers import CustomerSerializer, SupplierSerializer

# ---------------- Sales ----------------
class SalesInvoiceItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)
    class Meta:
        model = SalesInvoiceItem
        fields = ["id", "product", "product_name", "quantity", "unit_price", "subtotal"]

class SalesInvoiceSerializer(serializers.ModelSerializer):
    customer = CustomerSerializer(read_only=True)
    items = SalesInvoiceItemSerializer(many=True, read_only=True)
    class Meta:
        model = SalesInvoice
        fields = ["id", "customer", "total", "payment_method", "created_at", "items"]

# ---------------- Purchases ----------------
class PurchaseInvoiceItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)
    class Meta:
        model = PurchaseInvoiceItem
        fields = ["id", "product", "product_name", "quantity", "unit_price", "subtotal"]

class PurchaseInvoiceSerializer(serializers.ModelSerializer):
    supplier = SupplierSerializer(read_only=True)
    items = PurchaseInvoiceItemSerializer(many=True, read_only=True)
    class Meta:
        model = PurchaseInvoice
        fields = ["id", "supplier", "total", "payment_method", "created_at", "items"]

# ---------------- Returns ----------------
class ReturnInvoiceItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)
    class Meta:
        model = ReturnInvoiceItem
        fields = ["id", "product", "product_name", "quantity", "unit_price", "subtotal"]

class ReturnInvoiceSerializer(serializers.ModelSerializer):
    customer = CustomerSerializer(read_only=True)
    supplier = SupplierSerializer(read_only=True)
    items = ReturnInvoiceItemSerializer(many=True, read_only=True)
    class Meta:
        model = ReturnInvoice
        fields = ["id", "partner_type", "customer", "supplier", "total", "created_at", "items"]
