from rest_framework.views import APIView
from rest_framework.response import Response
from billing.models import SalesInvoice, PurchaseInvoice, ReturnInvoice
from django.db.models import Sum
from rest_framework.permissions import AllowAny
from django.utils import timezone
from billing.models import Expense

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
class ProfitStatsView(APIView):
    def get(self, request):
        period = request.query_params.get("period", "today")
        now = timezone.now()

        if period == "today":
            start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        elif period == "week":
            start = now - timezone.timedelta(days=7)
        elif period == "month":
            start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        elif period == "year":
            start = now.replace(month=1, day=1, hour=0, minute=0, second=0, microsecond=0)
        else:
            return Response({"error": "Invalid period"}, status=400)

        # حساب المبيعات الإجمالية (total بعد الخصم)
        sales_total = SalesInvoice.objects.filter(created_at__gte=start).aggregate(total=Sum('total'))["total"] or 0
        sales_paid = SalesInvoice.objects.filter(created_at__gte=start).aggregate(total=Sum('paid_amount'))["total"] or 0
        
        # حساب المشتريات الإجمالية (total بعد الخصم)
        purchases_total = PurchaseInvoice.objects.filter(created_at__gte=start).aggregate(total=Sum('total'))["total"] or 0
        purchases_paid = PurchaseInvoice.objects.filter(created_at__gte=start).aggregate(total=Sum('paid_amount'))["total"] or 0

        # حساب مرتجعات المبيعات (المرتجع من العملاء - يقلل من الإيراد)
        sales_returns = ReturnInvoice.objects.filter(
            partner_type="sale",
            created_at__gte=start
        ).aggregate(total=Sum('total'))["total"] or 0

        # حساب مرتجعات المشتريات (المرتجع للموردين - يقلل من التكاليف)
        purchase_returns = ReturnInvoice.objects.filter(
            partner_type="purchase",
            created_at__gte=start
        ).aggregate(total=Sum('total'))["total"] or 0

        expenses = Expense.objects.filter(
            created_at__gte=start
        ).aggregate(total=Sum('amount'))["total"] or 0

        # صيغة الحساب الصحيحة:
        # صافي المبيعات = إجمالي المبيعات - مرتجعات المبيعات
        # صافي المشتريات = إجمالي المشتريات - مرتجعات المشتريات
        # الربح الإجمالي = صافي المبيعات - صافي المشتريات
        net_sales = sales_total - sales_returns
        net_purchases = purchases_total - purchase_returns
        gross_profit = net_sales - net_purchases
        net_profit = gross_profit - expenses

        return Response({
            "period": period,
            "sales_total": sales_total,
            "sales_paid": sales_paid,
            "sales_returns": sales_returns,
            "net_sales": net_sales,
            "purchases_total": purchases_total,
            "purchases_paid": purchases_paid,
            "purchase_returns": purchase_returns,
            "net_purchases": net_purchases,
            "expenses": expenses,
            "gross_profit": gross_profit,
            "net_profit": net_profit
        })
