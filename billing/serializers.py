from rest_framework import serializers
from .models import (
    SalesInvoice, SalesInvoiceItem,
    PurchaseInvoice, PurchaseInvoiceItem,
    ReturnInvoice, ReturnInvoiceItem,
    InvoicePayment,CashBox
)
from products.models import Products as Product
from partners.serializers import CustomerSerializer, SupplierSerializer


# -------- InvoicePayment (يجب أن يكون قبل استخدامه) --------
class InvoicePaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = InvoicePayment
        fields = ["id", "amount", "payment_method", "created_at"]


# ---------------- Sales ----------------
class SalesInvoiceItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)

    class Meta:
        model = SalesInvoiceItem
        fields = ["id", "product", "product_name", "quantity", "unit_price", "subtotal"]

class SalesInvoiceSerializer(serializers.ModelSerializer):
    customer = CustomerSerializer(read_only=True)
    items = SalesInvoiceItemSerializer(many=True, read_only=True)
    payments = serializers.SerializerMethodField()

    # قسط شهري (محسوب)
    installment_amount = serializers.SerializerMethodField()

    # نسبة الخصم (محسوبة للعرض فقط)
    discount_percent = serializers.SerializerMethodField()

    class Meta:
        model = SalesInvoice
        fields = [
            "id",
            "customer",
            "subtotal",
            "discount",           # قيمة الخصم
            "discount_percent",   # نسبة الخصم
            "total",
            "paid_amount",        # المبلغ المدفوع
            "remaining_amount",   # الرصيد المتبقي
            "payment_status",     # حالة الدفع (unpaid, partial, paid)
            "payment_method",
            "payment_type",
            "installment_months",
            "installment_amount",
            "created_at",
            "items",
            "payments"
        ]

    def get_installment_amount(self, obj):
        if obj.payment_type == "installment" and obj.installment_months:
            return round(obj.total / obj.installment_months, 2)
        return None

    def get_discount_percent(self, obj):
        if obj.subtotal and obj.discount:
            return round((obj.discount / obj.subtotal) * 100, 2)
        return 0
    
    def get_payments(self, obj):
        payments = InvoicePayment.objects.filter(
            invoice_type="sale",
            sale_invoice=obj
        )
        return InvoicePaymentSerializer(payments, many=True).data

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
        fields = [
            "id",
            "supplier",
            "subtotal",
            "discount",
            "total",
            "paid_amount",
            "remaining_amount",
            "payment_status",
            "payment_method",
            "created_at",
            "items",
        ]

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
        fields = [
            "id",
            "partner_type",
            "customer",
            "supplier",
            "total",
            "created_at",
            "items",
        ]

class CashBoxSerializer(serializers.ModelSerializer):
    class Meta:
        model = CashBox
        fields = ["balance", "updated_at"]
