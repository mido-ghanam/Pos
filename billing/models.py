from django.db import models
from products.models import Products  # ✅ الاسم الحقيقي
from partners.models import Customers, Suppliers


# ---------------------- Sales ----------------------
class SalesInvoice(models.Model):
    PAYMENT_STATUS = [
        ('unpaid', 'غير مدفوعة'),
        ('partial', 'مدفوعة جزئياً'),
        ('paid', 'مدفوعة بالكامل'),
    ]

    customer = models.ForeignKey(Customers, on_delete=models.CASCADE)

    subtotal = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    discount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    # الدفع الجزئي
    paid_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    remaining_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='unpaid')

    payment_method = models.CharField(max_length=50, default="Cash")
    payment_type = models.CharField(
        max_length=20,
        choices=[("cash", "Cash"), ("installment", "Installment")],
        default="cash"
    )

    installment_months = models.PositiveIntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Sales Invoice #{self.id} - {self.customer.name} - {self.payment_status}"


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
    PAYMENT_STATUS = [
        ('unpaid', 'غير مدفوعة'),
        ('partial', 'مدفوعة جزئياً'),
        ('paid', 'مدفوعة بالكامل'),
    ]

    supplier = models.ForeignKey(Suppliers, on_delete=models.CASCADE)

    subtotal = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    discount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    # الدفع الجزئي
    paid_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    remaining_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='unpaid')

    payment_method = models.CharField(max_length=50, default="Cash")

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Purchase Invoice #{self.id} - {self.supplier.name} - {self.payment_status}"


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
    
    # reference للفاتورة الأصلية
    sale_invoice = models.ForeignKey(SalesInvoice, null=True, blank=True, on_delete=models.SET_NULL)
    purchase_invoice = models.ForeignKey(PurchaseInvoice, null=True, blank=True, on_delete=models.SET_NULL)
    
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        if self.partner_type == "sale":
            return f"Return Invoice #{self.id} - Customer: {self.customer.name if self.customer else 'Unknown'}"
        else:
            return f"Return Invoice #{self.id} - Supplier: {self.supplier.name if self.supplier else 'Unknown'}"


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
class InvoicePayment(models.Model):
    invoice_type = models.CharField(
        max_length=10,
        choices=(("sale", "Sale"), ("purchase", "Purchase"))
    )
    sale_invoice = models.ForeignKey(SalesInvoice, null=True, blank=True, on_delete=models.CASCADE)
    purchase_invoice = models.ForeignKey(PurchaseInvoice, null=True, blank=True, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    payment_method = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
class Expense(models.Model):
    title = models.CharField(max_length=200)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    category = models.CharField(max_length=100)  # كهربا، إيجار، نت...
    created_at = models.DateTimeField(auto_now_add=True)
