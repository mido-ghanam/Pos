from django.db import models
from products.models import Products  # ✅ الاسم الحقيقي
from partners.models import Customers, Suppliers

# ---------------------- Sales ----------------------
class SalesInvoice(models.Model):
    customer = models.ForeignKey(Customers, on_delete=models.CASCADE)
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    payment_method = models.CharField(max_length=50, default="Cash")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Sales Invoice #{self.id} - {self.customer.name}"


class SalesInvoiceItem(models.Model):
    invoice = models.ForeignKey(
        SalesInvoice,
        on_delete=models.CASCADE,
        related_name="items"
    )
    product = models.ForeignKey(Products, on_delete=models.CASCADE)  # ✅
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    subtotal = models.DecimalField(max_digits=12, decimal_places=2)


# ---------------------- Purchases ----------------------
class PurchaseInvoice(models.Model):
    supplier = models.ForeignKey(Suppliers, on_delete=models.CASCADE)
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    payment_method = models.CharField(max_length=50, default="Cash")
    created_at = models.DateTimeField(auto_now_add=True)


class PurchaseInvoiceItem(models.Model):
    invoice = models.ForeignKey(
        PurchaseInvoice,
        on_delete=models.CASCADE,
        related_name="items"
    )
    product = models.ForeignKey(Products, on_delete=models.CASCADE)  # ✅
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    subtotal = models.DecimalField(max_digits=12, decimal_places=2)


# ---------------------- Returns ----------------------
class ReturnInvoice(models.Model):
    TYPE_CHOICES = (
        ("sale", "Sale Return"),
        ("purchase", "Purchase Return"),
    )

    partner_type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    customer = models.ForeignKey(Customers, null=True, blank=True, on_delete=models.CASCADE)
    supplier = models.ForeignKey(Suppliers, null=True, blank=True, on_delete=models.CASCADE)
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)


class ReturnInvoiceItem(models.Model):
    invoice = models.ForeignKey(
        ReturnInvoice,
        on_delete=models.CASCADE,
        related_name="items"
    )
    product = models.ForeignKey(Products, on_delete=models.CASCADE)  # ✅
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    subtotal = models.DecimalField(max_digits=12, decimal_places=2)
