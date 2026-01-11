from rest_framework import viewsets, status
from rest_framework.response import Response
from billing.models import PurchaseInvoice, PurchaseInvoiceItem, InvoicePayment
from billing.serializers import PurchaseInvoiceSerializer
from products.models import Products
from partners.models import Suppliers
from billing.utils import send_invoice_whatsapp
from django.db.models import Sum, Q
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from django.utils import timezone
from django.db import transaction
from decimal import Decimal
# ---------------- List all Purchase Invoices ----------------
class PurchaseInvoiceListView(viewsets.ViewSet):
    def list(self, request):
        invoices = PurchaseInvoice.objects.all()
        total_purchases = invoices.aggregate(total=Sum('total'))["total"] or 0
        count = invoices.count()
        serializer = PurchaseInvoiceSerializer(invoices, many=True)
        return Response({
            "total_invoices": count,
            "total_purchases": total_purchases,
            "invoices": serializer.data
        })


# ---------------- Retrieve single Purchase Invoice ----------------
class PurchaseInvoiceDetailView(viewsets.ViewSet):
    def retrieve(self, request, pk=None):
        invoice = PurchaseInvoice.objects.filter(id=pk).first()
        if not invoice:
            return Response({"error": "Invoice not found"}, status=404)
        serializer = PurchaseInvoiceSerializer(invoice)
        return Response(serializer.data)


 # ---------------- Create Purchase Invoice ----------------

class PurchaseInvoiceCreateView(viewsets.ViewSet):
    permission_classes = [AllowAny]

    @transaction.atomic
    def create(self, request):
        supplier_id = request.data.get("supplier_id")
        payment_method = request.data.get("payment_method", "Cash")
        discount_percent = Decimal(str(request.data.get("discount", 0)))  # الخصم كنسبة مئوية
        paid_amount = Decimal(str(request.data.get("paid_amount", 0)))  # المبلغ المدفوع
        products_data = request.data.get("products", [])

        # ✅ validate supplier
        supplier = Suppliers.objects.filter(id=supplier_id, active=True).first()
        if not supplier:
            return Response(
                {"error": "Supplier not found or blocked"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not products_data:
            return Response(
                {"error": "Products list is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        invoice = PurchaseInvoice.objects.create(
            supplier=supplier,
            payment_method=payment_method,
            paid_amount=Decimal("0.00"),
            remaining_amount=Decimal("0.00"),
            payment_status='unpaid'
        )

        subtotal = Decimal("0.00")
        whatsapp_items = []

        for item in products_data:
            product_id = item.get("product_id")
            quantity = item.get("quantity", 0)

            if not product_id or quantity <= 0:
                return Response(
                    {"error": "Invalid product data"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            product = Products.objects.filter(id=product_id).first()
            if not product:
                return Response(
                    {"error": f"Product {product_id} not found"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            line_subtotal = Decimal(str(product.buy_price)) * Decimal(quantity)

            PurchaseInvoiceItem.objects.create(
                invoice=invoice,
                product=product,
                quantity=quantity,
                unit_price=product.buy_price,
                subtotal=line_subtotal
            )

            # ✅ stock increase
            product.quantity += quantity
            product.save()

            subtotal += line_subtotal
            whatsapp_items.append({
                "product_name": product.name,
                "quantity": quantity,
                "subtotal": float(line_subtotal)
            })

        # ✅ حساب الخصم كنسبة مئوية
        if discount_percent < 0 or discount_percent > 100:
            return Response(
                {"error": "Invalid discount percentage (0-100)"},
                status=status.HTTP_400_BAD_REQUEST
            )

        discount_amount = (subtotal * discount_percent) / Decimal("100")
        total = subtotal - discount_amount

        invoice.subtotal = subtotal
        invoice.discount = discount_amount
        invoice.total = total

        # ✅ نظام الدفع الجزئي
        if paid_amount > 0:
            if paid_amount > total:
                return Response(
                    {"error": f"Paid amount ({paid_amount}) cannot exceed total ({total})"},
                    status=400
                )
            
            invoice.paid_amount = paid_amount
            invoice.remaining_amount = total - paid_amount
            
            # تحديد حالة الدفع
            if invoice.remaining_amount == 0:
                invoice.payment_status = 'paid'
            else:
                invoice.payment_status = 'partial'
            
            # تسجيل الدفعة
            InvoicePayment.objects.create(
                invoice_type='purchase',
                purchase_invoice=invoice,
                amount=paid_amount,
                payment_method=payment_method
            )
        else:
            invoice.remaining_amount = total
            invoice.payment_status = 'unpaid'

        invoice.save()

        # ✅ WhatsApp
        if supplier.phone:
            send_invoice_whatsapp(
                supplier.phone,
                "Purchase",
                supplier.person_name,
                float(total),
                whatsapp_items,
                invoice_id=invoice.id,
                paid_amount=float(invoice.paid_amount),
                remaining_amount=float(invoice.remaining_amount),
                payment_status=invoice.payment_status
            )

        serializer = PurchaseInvoiceSerializer(invoice)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
class PurchaseInvoicesBySupplierView(APIView):
    def get(self, request, supplier_id):
        # التأكد إن المورد موجود
        supplier = Suppliers.objects.filter(id=supplier_id, active=True).first()
        if not supplier:
            return Response({"error": "Supplier not found"}, status=404)

        # فواتير الشراء الخاصة بالمورد
        invoices = PurchaseInvoice.objects.filter(supplier=supplier)

        total_purchases = invoices.aggregate(
            total=Sum('total')
        )["total"] or 0

        serializer = PurchaseInvoiceSerializer(invoices, many=True)

        return Response({
            "supplier": {
                "id": str(supplier.id),
                "person_name": supplier.person_name,
                "company_name": supplier.company_name,
                "phone": supplier.phone,
            },
            "total_invoices": invoices.count(),
            "total_purchases": total_purchases,
            "invoices": serializer.data
        })



class PurchaseStatsView(APIView):
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

        invoices = PurchaseInvoice.objects.filter(created_at__gte=start_date)

        total_purchases = invoices.aggregate(
            total=Sum('total')
        )["total"] or 0

        serializer = PurchaseInvoiceSerializer(invoices, many=True)

        return Response({
            "period": period,
            "from": start_date,
            "to": now,
            "total_invoices": invoices.count(),
            "total_purchases": total_purchases,
            "invoices": serializer.data
        })

# ----------- Pay Purchase Balance -----------
class PayPurchaseBalanceView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request, invoice_id):
        """
        دفع الرصيد المتبقي من فاتورة الشراء
        """
        invoice = PurchaseInvoice.objects.filter(id=invoice_id).first()
        if not invoice:
            return Response({"error": "Invoice not found"}, status=404)

        if invoice.remaining_amount == 0:
            return Response({
                "error": "Invoice is already paid",
                "invoice": PurchaseInvoiceSerializer(invoice).data
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
            invoice_type='purchase',
            purchase_invoice=invoice,
            amount=payment_amount,
            payment_method=payment_method
        )

        # تحديث الفاتورة
        invoice.paid_amount += payment_amount
        invoice.remaining_amount -= payment_amount

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
            "invoice": PurchaseInvoiceSerializer(invoice).data
        }, status=200)


# ----------- Pay Partial Payment for Purchase Invoice -----------
class PayPurchaseBalanceView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request, invoice_id):
        """
        Pay remaining balance for purchase invoice
        """
        invoice = PurchaseInvoice.objects.filter(id=invoice_id).first()
        if not invoice:
            return Response({"error": "Invoice not found"}, status=404)

        if invoice.remaining_amount == 0:
            return Response({
                "error": "Invoice is already paid",
                "invoice": PurchaseInvoiceSerializer(invoice).data
            }, status=400)

        payment_amount = Decimal(str(request.data.get("amount", 0)))
        payment_method = request.data.get("payment_method", "Cash")

        if payment_amount <= 0:
            return Response({"error": "Payment amount must be positive"}, status=400)

        if payment_amount > invoice.remaining_amount:
            return Response({
                "error": f"Payment amount ({payment_amount}) exceeds remaining balance ({invoice.remaining_amount})",
                "remaining_balance": float(invoice.remaining_amount)
            }, status=400)

        # Register payment
        InvoicePayment.objects.create(
            invoice_type='purchase',
            purchase_invoice=invoice,
            amount=payment_amount,
            payment_method=payment_method
        )

        # Update invoice
        invoice.paid_amount += payment_amount
        invoice.remaining_amount -= payment_amount

        # Update payment status
        if invoice.remaining_amount == 0:
            invoice.payment_status = 'paid'
        else:
            invoice.payment_status = 'partial'

        invoice.save()

        return Response({
            "message": "Payment recorded successfully",
            "paid_amount": float(invoice.paid_amount),
            "remaining_amount": float(invoice.remaining_amount),
            "payment_status": invoice.payment_status,
            "invoice": PurchaseInvoiceSerializer(invoice).data
        }, status=200)


# ----------- Pay Supplier Account Balance (Distribute to Multiple Invoices) -----------
class PaySupplierAccountView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request, supplier_id):
        """
        دفع من حساب المورد العام (توزيع على الفواتير الأقدم أولاً)
        
        Request:
        {
            "amount": 5000.00,
            "payment_method": "Check"
        }
        """
        supplier = Suppliers.objects.filter(id=supplier_id, active=True).first()
        if not supplier:
            return Response({"error": "Supplier not found or inactive"}, status=404)

        payment_amount = Decimal(str(request.data.get("amount", 0)))
        payment_method = request.data.get("payment_method", "Cash")

        if payment_amount <= 0:
            return Response({"error": "Payment amount must be positive"}, status=400)

        # احصل على الفواتير المستحقة (unpaid + partial)
        unpaid_invoices = PurchaseInvoice.objects.filter(
            supplier=supplier,
            remaining_amount__gt=0
        ).order_by('created_at')  # الأقدم أولاً

        if not unpaid_invoices.exists():
            return Response({
                "error": "No outstanding invoices for this supplier",
                "supplier": {
                    "id": str(supplier.id),
                    "company_name": supplier.company_name
                }
            }, status=400)

        remaining_payment = payment_amount
        payment_details = []  # سجل الفواتير المدفوعة
        total_supplier_balance = Decimal('0.00')

        # احسب المجموع المستحق
        for invoice in PurchaseInvoice.objects.filter(supplier=supplier, remaining_amount__gt=0):
            total_supplier_balance += invoice.remaining_amount

        # وزع الدفع على الفواتير
        for invoice in unpaid_invoices:
            if remaining_payment <= 0:
                break

            invoice_balance = invoice.remaining_amount
            payment_for_this_invoice = min(remaining_payment, invoice_balance)

            # سجل الدفعة
            InvoicePayment.objects.create(
                invoice_type='purchase',
                purchase_invoice=invoice,
                amount=payment_for_this_invoice,
                payment_method=payment_method
            )

            # حدث الفاتورة
            invoice.paid_amount += payment_for_this_invoice
            invoice.remaining_amount -= payment_for_this_invoice

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
        remaining_supplier_balance = Decimal('0.00')
        for invoice in PurchaseInvoice.objects.filter(supplier=supplier, remaining_amount__gt=0):
            remaining_supplier_balance += invoice.remaining_amount

        # أرسل واتس
        from billing.utils import send_supplier_payment_whatsapp
        send_supplier_payment_whatsapp(
            supplier=supplier,
            paid_amount=payment_amount,
            remaining_balance=remaining_supplier_balance,
            payment_details=payment_details,
            payment_method=payment_method
        )

        return Response({
            "message": "تم تسجيل الدفع بنجاح",
            "supplier": {
                "id": str(supplier.id),
                "company_name": supplier.company_name,
                "phone": supplier.phone
            },
            "amount_paid": float(payment_amount),
            "total_balance_before": float(total_supplier_balance),
            "total_balance_after": float(remaining_supplier_balance),
            "payment_details": payment_details
        }, status=200)


# ----------- List Suppliers with Outstanding Balance -----------
class SuppliersWithBalanceView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        """
        Get all suppliers with outstanding balance
        Shows supplier info and their total due amount
        """
        # احصل على جميع فواتير الشراء المستحقة
        outstanding_invoices = PurchaseInvoice.objects.filter(
            remaining_amount__gt=0
        ).select_related('supplier').order_by('-created_at')

        # جمّع حسب المورد
        suppliers_balance = {}
        for invoice in outstanding_invoices:
            supplier_id = str(invoice.supplier.id)
            if supplier_id not in suppliers_balance:
                suppliers_balance[supplier_id] = {
                    "id": supplier_id,
                    "company_name": invoice.supplier.company_name,
                    "person_name": invoice.supplier.person_name,
                    "phone": invoice.supplier.phone,
                    "email": invoice.supplier.email if hasattr(invoice.supplier, 'email') else None,
                    "total_due": Decimal('0.00'),
                    "total_invoices": 0,
                    "invoices": []
                }
            
            suppliers_balance[supplier_id]["total_due"] += invoice.remaining_amount
            suppliers_balance[supplier_id]["total_invoices"] += 1
            suppliers_balance[supplier_id]["invoices"].append({
                "invoice_id": invoice.id,
                "total": float(invoice.total),
                "paid": float(invoice.paid_amount),
                "remaining": float(invoice.remaining_amount),
                "status": invoice.payment_status,
                "created_at": invoice.created_at
            })

        # تحويل إلى list
        suppliers_list = [
            {
                **data,
                "total_due": float(data["total_due"])
            }
            for data in suppliers_balance.values()
        ]

        # رتب بناءً على المبلغ المستحق
        suppliers_list = sorted(
            suppliers_list,
            key=lambda x: x["total_due"],
            reverse=True
        )

        return Response({
            "total_suppliers_with_balance": len(suppliers_list),
            "total_amount_due": float(sum(Decimal(str(s["total_due"])) for s in suppliers_list)),
            "suppliers": suppliers_list
        }, status=200)