"""
Signals للتحديث التلقائي للخزنة والأرباح
"""
from django.db.models.signals import post_save
from django.dispatch import receiver
from decimal import Decimal
from .models import Expense, CashBox


@receiver(post_save, sender=Expense)
def deduct_cashbox_on_expense_created(sender, instance, created, **kwargs):
    """
    عند إنشاء مصروف:
    - خصم من الخزنة تلقائياً
    - الأرباح تنقص من الحساب الرياضي فقط
    """
    if created and instance.amount > 0:
        cashbox = CashBox.objects.select_for_update().first()
        if not cashbox:
            cashbox = CashBox.objects.create(id=1, balance=Decimal("0.00"))
        
        # تخصم من الخزنة إذا كان الرصيد كافياً
        if cashbox.balance >= instance.amount:
            cashbox.balance -= instance.amount
            cashbox.save()
