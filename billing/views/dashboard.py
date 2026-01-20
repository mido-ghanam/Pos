from rest_framework.views import APIView
from rest_framework.response import Response
from billing.models import SalesInvoice, PurchaseInvoice, ReturnInvoice, CashBox, SalesInvoiceItem, Expense, ReturnInvoiceItem
from django.db.models import Sum, F, DecimalField, ExpressionWrapper
from django.db.models.functions import Cast
from rest_framework.permissions import AllowAny
from django.utils import timezone
from django.db import transaction
from decimal import Decimal

class BillingDashboardView(APIView):
    def get(self, request):
        """
        الأرباح = الفرق بين سعر البيع والشراء فقط (لا تتأثر بالمشتريات الإجمالية)
        الخزنة = الفلوس المتاحة من الدفع والاستقبال
        """
        # 🏧 الخزنة الحالية
        cashbox = CashBox.objects.first()
        cash_balance = cashbox.balance if cashbox else 0

        # 💰 حساب الأرباح = مجموع الفرق بين سعر البيع والشراء لكل منتج مباع
        profit_from_sales = SalesInvoiceItem.objects.aggregate(
            profit=Sum(
                ExpressionWrapper(
                    F('subtotal') - (Cast(F('product__buy_price'), DecimalField()) * F('quantity')),
                    output_field=DecimalField()
                )
            )
        )["profit"] or Decimal("0")

        # 🔻 خصم المرتجعات من الأرباح
        profit_from_returns = ReturnInvoiceItem.objects.filter(
            invoice__partner_type='sale'
        ).aggregate(
            profit=Sum(
                ExpressionWrapper(
                    F('subtotal') - (Cast(F('product__buy_price'), DecimalField()) * F('quantity')),
                    output_field=DecimalField()
                )
            )
        )["profit"] or Decimal("0")

        # 💸 خصم المصروفات من الأرباح
        total_expenses = Expense.objects.aggregate(total=Sum('amount'))["total"] or Decimal("0")

        # 📊 الربح الصافي النهائي
        net_profit = profit_from_sales - profit_from_returns - total_expenses

        # 📈 البيانات الإجمالية للعرض
        total_sales = SalesInvoice.objects.aggregate(total=Sum('total'))["total"] or 0
        total_purchases = PurchaseInvoice.objects.aggregate(total=Sum('total'))["total"] or 0
        sales_returns = ReturnInvoice.objects.filter(partner_type='sale').aggregate(total=Sum('total'))["total"] or 0
        
        # المبيعات الصافية بعد طرح المرتجعات
        net_total_sales = total_sales - sales_returns

        return Response({
            "total_sales": float(total_sales),
            "sales_returns": float(sales_returns),
            "net_total_sales": float(net_total_sales),
            "total_purchases": float(total_purchases),
            "cash_balance": float(cash_balance),
            "profit_from_sales": float(profit_from_sales),
            "profit_from_returns": float(profit_from_returns),
            "total_expenses": float(total_expenses),
            "net_profit": float(net_profit)
        })
class ProfitStatsView(APIView):
    def get(self, request):
        """
        الأرباح = الفرق بين سعر البيع والشراء لكل منتج مباع - المصروفات
        لا تتأثر الأرباح بالمشتريات الإجمالية، فقط بـ الفارق الفعلي
        """
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

        # 📊 المبيعات الإجمالية في الفترة
        sales_total = SalesInvoice.objects.filter(created_at__gte=start).aggregate(
            total=Sum('total')
        )["total"] or Decimal("0")

        # � خصم المرتجعات من إجمالي المبيعات
        sales_returns = ReturnInvoice.objects.filter(
            partner_type="sale",
            created_at__gte=start
        ).aggregate(total=Sum('total'))["total"] or Decimal("0")
        
        # المبيعات الصافية بعد طرح المرتجعات
        net_sales_total = sales_total - sales_returns

        # 💵 المبيعات المدفوعة (للخزنة)
        sales_received = SalesInvoice.objects.filter(
            created_at__gte=start,
            payment_status__in=['paid', 'partial']
        ).aggregate(total=Sum('paid_amount'))["total"] or Decimal("0")

        # 💰 حساب الأرباح من الفرق بين سعر البيع والشراء
        profit_from_sales = SalesInvoiceItem.objects.filter(
            invoice__created_at__gte=start
        ).aggregate(
            profit=Sum(
                ExpressionWrapper(
                    F('subtotal') - (Cast(F('product__buy_price'), DecimalField()) * F('quantity')),
                    output_field=DecimalField()
                )
            )
        )["profit"] or Decimal("0")

        # لحساب خسارة المرتجعات من الأرباح (الفارق بين البيع والشراء للسلع المرتجعة فقط)
        profit_lost_from_returns = ReturnInvoiceItem.objects.filter(
            invoice__created_at__gte=start,
            invoice__partner_type='sale'
        ).aggregate(
            profit=Sum(
                ExpressionWrapper(
                    F('subtotal') - (Cast(F('product__buy_price'), DecimalField()) * F('quantity')),
                    output_field=DecimalField()
                )
            )
        )["profit"] or Decimal("0")

        # 💸 المصروفات في الفترة
        expenses = Expense.objects.filter(
            created_at__gte=start
        ).aggregate(total=Sum('amount'))["total"] or Decimal("0")

        # 📊 المشتريات والخزنة
        purchases_total = PurchaseInvoice.objects.filter(created_at__gte=start).aggregate(
            total=Sum('total')
        )["total"] or Decimal("0")

        purchases_paid = PurchaseInvoice.objects.filter(
            created_at__gte=start,
            payment_status__in=['paid', 'partial']
        ).aggregate(total=Sum('paid_amount'))["total"] or Decimal("0")

        # 🏧 الخزنة = المبيعات المدفوعة - المشتريات المدفوعة
        cashbox = CashBox.objects.first()
        cash_balance = cashbox.balance if cashbox else Decimal("0")

        # 📈 الربح الصافي = أرباح المبيعات - خسائر المرتجعات - المصروفات
        net_profit = profit_from_sales - profit_lost_from_returns - expenses

        return Response({
            "period": period,
            "sales_total": float(sales_total),
            "sales_returns": float(sales_returns),
            "net_sales_total": float(net_sales_total),
            "sales_received": float(sales_received),
            "purchases_total": float(purchases_total),
            "purchases_paid": float(purchases_paid),
            "profit_from_sales": float(profit_from_sales),
            "profit_lost_from_returns": float(profit_lost_from_returns),
            "expenses": float(expenses),
            "cash_balance": float(cash_balance),
            "net_profit": float(net_profit)
        })

class CashBoxView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        """
        عرض الرصيد الحالي في الخزنة
        """
        cashbox = CashBox.objects.first()
        if not cashbox:
            return Response({"error": "CashBox not found"}, status=404)
        return Response({
            "cash_balance": float(cashbox.balance),
            "updated_at": cashbox.updated_at
        })

    @transaction.atomic
    def post(self, request):
        """
        تحديث الرصيد أو إضافة قيمة جديدة للخزنة
        Request:
        {
            "amount": 5000  # الرقم اللي عايزة تضيفيه أو تحدديه
        }
        """
        cashbox = CashBox.objects.select_for_update().first()
        if not cashbox:
            # لو الخزنة مش موجودة، ننشئها
            cashbox = CashBox.objects.create(balance=Decimal("0.00"))

        amount = Decimal(str(request.data.get("amount", 0)))
        if amount < 0:
            return Response({"error": "Amount must be positive"}, status=400)

        # تحديث الرصيد (ممكن تختاري طريقة: replace أو add)
        cashbox.balance += amount  # لو عايزة تضيفي المبلغ
        # cashbox.balance = amount  # لو عايزة تحددي الرصيد مباشرة

        cashbox.save()
        return Response({
            "message": "CashBox updated successfully",
            "cash_balance": float(cashbox.balance),
            "updated_at": cashbox.updated_at
        })

