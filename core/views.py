from billing.models import SalesInvoice, SalesInvoiceItem, PurchaseInvoice, ReturnInvoice, ReturnInvoiceItem, Expense
from django.db.models import Sum, F, DecimalField, ExpressionWrapper
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView, Response
from partners.models import Customers, Suppliers
from django.db.models.functions import Coalesce
from products.models import Products
from django.utils import timezone
from decimal import Decimal

def gettingAllObjectsCount(obj): return obj.objects.count()

def gettingTodaysObjectsCount(obj): return obj.objects.filter(created_at__date=timezone.localdate()).count()

class Index(APIView):
  permission_classes = [IsAuthenticated]
  def get(self, request): 
    sales_profit = SalesInvoiceItem.objects.filter(invoice__created_at__gte=timezone.localdate()).aggregate(profit=Sum(ExpressionWrapper(F('subtotal') - (Coalesce(F('product__buy_price'), 0) * F('quantity')), output_field=DecimalField())))["profit"] or Decimal("0")
    return_profit = ReturnInvoiceItem.objects.filter(invoice__created_at__gte=timezone.localdate(), invoice__partner_type='sale').aggregate(profit=Sum(ExpressionWrapper(F('subtotal') - (Coalesce(F('product__buy_price'), 0) * F('quantity')), output_field=DecimalField())))["profit"] or Decimal("0")
    expenses = Expense.objects.filter(created_at__gte=timezone.localdate()).aggregate(total=Sum('amount'))["total"] or Decimal("0")
    
    sales_total = SalesInvoice.objects.filter(created_at__date=timezone.localdate()).aggregate(total=Sum('total'))["total"] or Decimal("0")
    return_total = ReturnInvoice.objects.filter(partner_type='sale', created_at__date=timezone.localdate()).aggregate(total=Sum('total'))["total"] or Decimal("0")
    
    data = {
      "status": True, 
      "data": {
        "products_count": gettingAllObjectsCount(Products),
        "customers_count": gettingAllObjectsCount(Customers),
        "suppliers_count": gettingAllObjectsCount(Suppliers),
        "SalesInvoicesCount": gettingTodaysObjectsCount(SalesInvoice),
        "PurchaseInvoicesCount": gettingTodaysObjectsCount(PurchaseInvoice),
        "ReturnInvoicesCount": gettingTodaysObjectsCount(ReturnInvoice),
        "net_profit": sales_profit - return_profit - expenses,
        "net_total_sales": sales_total - return_total,
      }
    }
    return Response(data)
