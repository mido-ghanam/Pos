from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework.decorators import action
from django.db.models import Sum
from rest_framework.views import APIView
from billing.models import SalesInvoice, SalesInvoiceItem, InvoicePayment
from billing.serializers import SalesInvoiceSerializer
from products.models import Products
from partners.models import Customers
from django.utils import timezone
from django.db import transaction
from decimal import Decimal
from decimal import Decimal
from rest_framework.decorators import action
from billing.models import InvoicePayment
from django.db.models import Q
from billing.models import CashBox

# ----------- List Sales Invoices -----------
class SalesInvoiceListView(viewsets.ViewSet):
    def list(self, request):
        invoices = SalesInvoice.objects.all()
        total_sales = invoices.aggregate(total=Sum('total'))["total"] or 0

        serializer = SalesInvoiceSerializer(invoices, many=True)
        return Response({
            "total_invoices": invoices.count(),
            "total_sales": total_sales,
            "invoices": serializer.data
        })


# ----------- Sales Invoice Details -----------
class SalesInvoiceDetailView(viewsets.ViewSet):
    def retrieve(self, request, pk=None):
        invoice = SalesInvoice.objects.filter(id=pk).first()
        if not invoice:
            return Response({"error": "Invoice not found"}, status=404)

        serializer = SalesInvoiceSerializer(invoice)
        return Response(serializer.data)


 # ----------- Create Sales Invoice -----------
class SalesInvoiceCreateView(viewsets.ViewSet):
    permission_classes = [AllowAny]

    @transaction.atomic
    def create(self, request):
        customer_id = request.data.get("customer_id")
        payment_method = request.data.get("payment_method", "Cash")
        payment_type = request.data.get("payment_type", "cash")
        discount_percent = Decimal(request.data.get("discount", 0))
        installment_months = int(request.data.get("installment_months", 0))
        paid_amount = Decimal(str(request.data.get("paid_amount", 0)))  # المبلغ المدفوع الآن
        products_data = request.data.get("products", [])

        # ✅ check customer
        customer = Customers.objects.filter(id=customer_id, blocked=False).first()
        if not customer:
            return Response({"error": "Customer not found or blocked"}, status=400)

        if not products_data:
            return Response({"error": "Products list is required"}, status=400)

        invoice = SalesInvoice.objects.create(
            customer=customer,
            payment_method=payment_method,
            payment_type=payment_type,
            subtotal=Decimal("0.00"),
            discount=Decimal("0.00"),
            total=Decimal("0.00"),
            paid_amount=Decimal("0.00"),
            remaining_amount=Decimal("0.00"),
            payment_status='unpaid'
        )

        subtotal = Decimal("0.00")

        for item in products_data:
            product = Products.objects.filter(id=item["product_id"]).first()
            quantity = int(item["quantity"])

            if not product:
                return Response({"error": "Product not found"}, status=400)

            if product.quantity < quantity:
                return Response(
                    {"error": f"Not enough stock for {product.name}"},
                    status=400
                )

            line_total = Decimal(str(product.sell_price)) * Decimal(quantity)

            SalesInvoiceItem.objects.create(
                invoice=invoice,
                product=product,
                quantity=quantity,
                unit_price=product.sell_price,
                subtotal=line_total
            )

            product.quantity -= quantity
            product.save()

            subtotal += line_total

        # ✅ apply discount (%)
        discount_value = (discount_percent / Decimal("100")) * subtotal
        total_after_discount = subtotal - discount_value

        invoice.subtotal = subtotal
        invoice.discount = discount_value
        invoice.total = total_after_discount

        # ✅ نظام الدفع الجزئي
        if paid_amount > 0:
            if paid_amount > total_after_discount:
                return Response(
                    {"error": f"Paid amount ({paid_amount}) cannot exceed total ({total_after_discount})"},
                    status=400
                )
            
            invoice.paid_amount = paid_amount
            invoice.remaining_amount = total_after_discount - paid_amount
            
            # تحديد حالة الدفع
            if invoice.remaining_amount == 0:
                invoice.payment_status = 'paid'
            else:
                invoice.payment_status = 'partial'
            
            # تسجيل الدفعة في InvoicePayment
            InvoicePayment.objects.create(
                invoice_type='sale',
                sale_invoice=invoice,
                amount=paid_amount,
                payment_method=payment_method
            )
            cashbox, _ = CashBox.objects.get_or_create(id=1)
            cashbox.balance += paid_amount
            cashbox.save()
        else:
            invoice.remaining_amount = total_after_discount
            invoice.payment_status = 'unpaid'

        # ✅ installment
        if payment_type == "installment" and installment_months > 0:
            invoice.installment_months = installment_months

        invoice.save()

        serializer = SalesInvoiceSerializer(invoice)
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class SalesInvoicesByCustomerView(APIView):
    permission_classes = [AllowAny]
    def get(self, request, customer_id):
        customer = Customers.objects.filter(id=customer_id, blocked=False).first()
        if not customer:
            return Response({"error": "Customer not found"}, status=404)

        invoices = SalesInvoice.objects.filter(customer=customer)

        total_sales = invoices.aggregate(total=Sum('total'))["total"] or 0

        serializer = SalesInvoiceSerializer(invoices, many=True)

        return Response({
            "customer": {
                "id": str(customer.id),
                "name": customer.name,
                "phone": customer.phone,
            },
            "total_invoices": invoices.count(),
            "total_sales": total_sales,
            "invoices": serializer.data
        })


class SalesStatsView(APIView):
    def get(self, request):
        period = request.query_params.get("period", "today")
        now = timezone.now()

        if period == "today":
            start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)

        elif period == "week":
            start_date = now - timezone.timedelta(days=7)

        elif period == "month":
            start_date = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

        elif period == "year":
            start_date = now.replace(month=1, day=1, hour=0, minute=0, second=0, microsecond=0)

        else:
            return Response(
                {"error": "Invalid period. Use today, week, month, or year"},
                status=400
            )

        invoices = SalesInvoice.objects.filter(created_at__gte=start_date)

        total_sales = invoices.aggregate(
            total=Sum('total')
        )["total"] or 0

        serializer = SalesInvoiceSerializer(invoices, many=True)

        return Response({
            "period": period,
            "from": start_date,
            "to": now,
            "total_invoices": invoices.count(),
            "total_sales": total_sales,
            "invoices": serializer.data
        })


class SalesInvoiceViewSet(viewsets.ModelViewSet):
    queryset = SalesInvoice.objects.all()
    serializer_class = SalesInvoiceSerializer

    # ---- دفع جزئي ----
    @action(detail=True, methods=["post"])
    def pay_partial(self, request, pk=None):
        invoice = self.get_object()

        amount = request.data.get("amount")
        payment_method = request.data.get("payment_method", "Cash")

        if amount is None:
            return Response({"error": "Specify amount"}, status=400)

        amount = Decimal(str(amount))

        if amount <= 0:
            return Response({"error": "Amount must be positive"}, status=400)

        if amount > invoice.remaining_amount:
            return Response({"error": "Amount exceeds remaining balance"}, status=400)

        # تسجيل الدفع
        InvoicePayment.objects.create(
            invoice_type="sale",
            sale_invoice=invoice,
            amount=amount,
            payment_method=payment_method
        )

        # خصم المبلغ من الرصيد المستحق
        invoice.paid_amount += amount
        invoice.remaining_amount -= amount
        invoice.payment_status = "paid" if invoice.remaining_amount == 0 else "partial"
        invoice.save()

        cashbox, _ = CashBox.objects.get_or_create(id=1)
        cashbox.balance += amount
        cashbox.save()

        serializer = self.get_serializer(invoice)
        return Response({
            "message": "تم الدفع الجزئي بنجاح",
            "invoice": serializer.data
        })


# ----------- Pay Partial Payment for Invoice -----------
class PayInvoiceBalanceView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request, invoice_id):
        """
        دفع الرصيد المتبقي من الفاتورة
        
        Request:
        {
            "amount": 100.00,
            "payment_method": "Cash"
        }
        """
        invoice = SalesInvoice.objects.filter(id=invoice_id).first()
        if not invoice:
            return Response({"error": "Invoice not found"}, status=404)

        if invoice.remaining_amount == 0:
            return Response({
                "error": "Invoice is already paid",
                "invoice": SalesInvoiceSerializer(invoice).data
            }, status=400)

        payment_amount = Decimal(str(request.data.get("amount", 0)))
        payment_method = request.data.get("payment_method", "Cash")

        if payment_amount <= 0:
            return Response({"error": "Payment amount must be positive"}, status=400)

        if payment_amount > invoice.remaining_amount:
            return Response({
                "error": f"Payment amount ({payment_amount}) exceeds remaining balance ({invoice.remaining_amount})",
                "remaining_balance": invoice.remaining_amount
            }, status=400)

        # تسجيل الدفعة
        InvoicePayment.objects.create(
            invoice_type='sale',
            sale_invoice=invoice,
            amount=payment_amount,
            payment_method=payment_method
        )

        # تحديث الفاتورة
        invoice.paid_amount += amount
        invoice.remaining_amount -= amount
        invoice.payment_status = "paid" if invoice.remaining_amount == 0 else "partial"
        invoice.save()

        # ✅ الخزنة
        cashbox, _ = CashBox.objects.get_or_create(id=1)
        cashbox.balance += amount
        cashbox.save()

        # تحديث حالة الدفع
        if invoice.remaining_amount == 0:
            invoice.payment_status = 'paid'
        else:
            invoice.payment_status = 'partial'

        invoice.save()

        return Response({
            "message": "تم تسجيل الدفع بنجاح",
            "paid_amount": float(invoice.paid_amount),
            "remaining_amount": float(invoice.remaining_amount),
            "payment_status": invoice.payment_status,
            "invoice": SalesInvoiceSerializer(invoice).data
        }, status=200)


# ----------- Pay Customer Account Balance (Distribute to Multiple Invoices) -----------
class PayCustomerAccountView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request, customer_id):
        """
        دفع من حساب العميل العام (توزيع على الفواتير الأقدم أولاً)
        
        Request:
        {
            "amount": 1000.00,
            "payment_method": "Cash"
        }
        """
        customer = Customers.objects.filter(id=customer_id, blocked=False).first()
        if not customer:
            return Response({"error": "Customer not found or blocked"}, status=404)

        payment_amount = Decimal(str(request.data.get("amount", 0)))
        payment_method = request.data.get("payment_method", "Cash")

        if payment_amount <= 0:
            return Response({"error": "Payment amount must be positive"}, status=400)

        # احصل على الفواتير المستحقة (unpaid + partial)
        unpaid_invoices = SalesInvoice.objects.filter(
            customer=customer,
            remaining_amount__gt=0
        ).order_by('created_at')  # الأقدم أولاً

        if not unpaid_invoices.exists():
            return Response({
                "error": "No outstanding invoices for this customer",
                "customer": {
                    "id": str(customer.id),
                    "name": customer.name
                }
            }, status=400)

        remaining_payment = payment_amount
        payment_details = []  # سجل الفواتير المدفوعة
        total_customer_balance = Decimal('0.00')

        # احسب المجموع المستحق
        for invoice in SalesInvoice.objects.filter(customer=customer, remaining_amount__gt=0):
            total_customer_balance += invoice.remaining_amount

        # وزع الدفع على الفواتير
        for invoice in unpaid_invoices:
            if remaining_payment <= 0:
                break

            invoice_balance = invoice.remaining_amount
            payment_for_this_invoice = min(remaining_payment, invoice_balance)

            # سجل الدفعة
            InvoicePayment.objects.create(
                invoice_type='sale',
                sale_invoice=invoice,
                amount=payment_for_this_invoice,
                payment_method=payment_method
            )

            # حدث الفاتورة
            invoice.paid_amount += payment_for_this_invoice
            invoice.remaining_amount -= payment_for_this_invoice
            

        # ✅ الخزنة
            cashbox, _ = CashBox.objects.get_or_create(id=1)
            cashbox.balance += amount
            cashbox.save()


            # حدث حالة الدفع
            if invoice.remaining_amount == 0:
                invoice.payment_status = 'paid'
            else:
                invoice.payment_status = 'partial'

            invoice.save()

            # سجل التفاصيل
            payment_details.append({
                "invoice_id": invoice.id,
                "amount_paid": float(payment_for_this_invoice),
                "remaining": float(invoice.remaining_amount),
                "status": invoice.payment_status
            })

            remaining_payment -= payment_for_this_invoice

        # احسب الرصيد المتبقي بعد الدفع
        remaining_customer_balance = Decimal('0.00')
        for invoice in SalesInvoice.objects.filter(customer=customer, remaining_amount__gt=0):
            remaining_customer_balance += invoice.remaining_amount

        # أرسل واتس
        from billing.utils import send_customer_payment_whatsapp
        send_customer_payment_whatsapp(
            customer=customer,
            paid_amount=payment_amount,
            remaining_balance=remaining_customer_balance,
            payment_details=payment_details,
            payment_method=payment_method
        )

        return Response({
            "message": "تم تسجيل الدفع بنجاح",
            "customer": {
                "id": str(customer.id),
                "name": customer.name,
                "phone": customer.phone
            },
            "amount_paid": float(payment_amount),
            "total_balance_before": float(total_customer_balance),
            "total_balance_after": float(remaining_customer_balance),
            "payment_details": payment_details
        }, status=200)


# ----------- List Customers with Outstanding Balance -----------
class CustomersWithBalanceView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        """
        Get all customers with outstanding balance
        Shows customer info and their total due amount
        """
        # احصل على جميع الفواتير المستحقة
        outstanding_invoices = SalesInvoice.objects.filter(
            remaining_amount__gt=0
        ).select_related('customer').order_by('-created_at')

        # جمّع حسب العميل
        customers_balance = {}
        for invoice in outstanding_invoices:
            customer_id = str(invoice.customer.id)
            if customer_id not in customers_balance:
                customers_balance[customer_id] = {
                    "id": customer_id,
                    "name": invoice.customer.name,
                    "phone": invoice.customer.phone,
                    "email": invoice.customer.email if hasattr(invoice.customer, 'email') else None,
                    "total_due": Decimal('0.00'),
                    "total_invoices": 0,
                    "invoices": []
                }
            
            customers_balance[customer_id]["total_due"] += invoice.remaining_amount
            customers_balance[customer_id]["total_invoices"] += 1
            customers_balance[customer_id]["invoices"].append({
                "invoice_id": invoice.id,
                "total": float(invoice.total),
                "paid": float(invoice.paid_amount),
                "remaining": float(invoice.remaining_amount),
                "status": invoice.payment_status,
                "created_at": invoice.created_at
            })

        # تحويل إلى list
        customers_list = [
            {
                **data,
                "total_due": float(data["total_due"])
            }
            for data in customers_balance.values()
        ]

        # رتب بناءً على المبلغ المستحق
        customers_list = sorted(
            customers_list,
            key=lambda x: x["total_due"],
            reverse=True
        )

        return Response({
            "total_customers_with_balance": len(customers_list),
            "total_amount_due": float(sum(Decimal(str(c["total_due"])) for c in customers_list)),
            "customers": customers_list
        }, status=200)
