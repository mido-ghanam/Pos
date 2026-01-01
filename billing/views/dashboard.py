from rest_framework.views import APIView
from rest_framework.response import Response
from billing.models import SalesInvoice, PurchaseInvoice, ReturnInvoice
from django.db.models import Sum

class BillingDashboardView(APIView):
    def get(self, request):
        total_sales = SalesInvoice.objects.aggregate(total=Sum('total'))["total"] or 0
        total_purchases = PurchaseInvoice.objects.aggregate(total=Sum('total'))["total"] or 0
        total_returns = ReturnInvoice.objects.aggregate(total=Sum('total'))["total"] or 0
        profit = total_sales - total_purchases - total_returns

        return Response({
            "total_sales": total_sales,
            "total_purchases": total_purchases,
            "total_returns": total_returns,
            "profit": profit
        })
