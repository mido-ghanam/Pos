from rest_framework.views import APIView
from rest_framework.response import Response
from billing.models import SalesInvoice, PurchaseInvoice, ReturnInvoice
from django.db.models import Sum
from rest_framework.permissions import AllowAny

class BillingDashboardView(APIView):
    def get(self, request):
        total_sales = SalesInvoice.objects.aggregate(total=Sum('total'))["total"] or 0
        total_purchases = PurchaseInvoice.objects.aggregate(total=Sum('total'))["total"] or 0

        # Returns حسب النوع
        sales_returns = ReturnInvoice.objects.filter(partner_type='sale').aggregate(total=Sum('total'))["total"] or 0
        purchase_returns = ReturnInvoice.objects.filter(partner_type='purchase').aggregate(total=Sum('total'))["total"] or 0

        # الأرباح الحقيقية
        profit = (total_sales - sales_returns) - (total_purchases - purchase_returns)

        return Response({
            "total_sales": total_sales,
            "total_purchases": total_purchases,
            "total_returns": sales_returns + purchase_returns,
            "profit": profit
        })
