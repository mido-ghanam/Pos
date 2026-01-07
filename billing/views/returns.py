from rest_framework import viewsets, status
from rest_framework.response import Response
from billing.models import ReturnInvoice, ReturnInvoiceItem, SalesInvoice, PurchaseInvoice
from billing.serializers import ReturnInvoiceSerializer
from products.models import Products
from partners.models import Customers, Suppliers
from billing.utils import send_invoice_whatsapp
from django.db.models import Sum
from rest_framework.permissions import AllowAny
from django.db import transaction
from decimal import Decimal

# ---------------- List all Return Invoices ----------------
class ReturnInvoiceListView(viewsets.ViewSet):
    def list(self, request):
        invoices = ReturnInvoice.objects.all()
        total_returns = invoices.aggregate(total=Sum('total'))["total"] or 0
        count = invoices.count()
        serializer = ReturnInvoiceSerializer(invoices, many=True)
        return Response({
            "total_invoices": count,
            "total_returns": total_returns,
            "invoices": serializer.data
        })


# ---------------- Retrieve single Return Invoice ----------------
class ReturnInvoiceDetailView(viewsets.ViewSet):
    def retrieve(self, request, pk=None):
        invoice = ReturnInvoice.objects.filter(id=pk).first()
        if not invoice:
            return Response({"error": "Invoice not found"}, status=404)
        serializer = ReturnInvoiceSerializer(invoice)
        return Response(serializer.data)


# ---------------- Create Return Invoice ----------------


class ReturnInvoiceCreateView(viewsets.ViewSet):
    permission_classes = [AllowAny]

    @transaction.atomic
    def create(self, request):
        return_type = request.data.get("return_type")  # sale | purchase
        party_id = request.data.get("party_id")
        original_invoice_id = request.data.get("original_invoice_id")  # معرف الفاتورة الأصلية
        products_data = request.data.get("products", [])

        if return_type not in ["sale", "purchase"]:
            return Response(
                {"error": "return_type must be sale or purchase"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not products_data:
            return Response(
                {"error": "Products list is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ✅ identify party
        if return_type == "sale":
            party = Customers.objects.filter(id=party_id, blocked=False).first()
            if not party:
                return Response({"error": "Customer not found"}, status=400)
            
            # الحصول على الفاتورة الأصلية
            original_invoice = None
            if original_invoice_id:
                original_invoice = SalesInvoice.objects.filter(id=original_invoice_id).first()
            else:
                # إذا لم تُحدد الفاتورة، اختر أقدم فاتورة مستحقة للعميل
                original_invoice = SalesInvoice.objects.filter(
                    customer=party,
                    remaining_amount__gt=0
                ).order_by('created_at').first()
            
            invoice = ReturnInvoice.objects.create(
                partner_type="sale",
                customer=party,
                sale_invoice=original_invoice
            )
        else:
            party = Suppliers.objects.filter(id=party_id, active=True).first()
            if not party:
                return Response({"error": "Supplier not found"}, status=400)
            
            # الحصول على الفاتورة الأصلية
            original_invoice = None
            if original_invoice_id:
                original_invoice = PurchaseInvoice.objects.filter(id=original_invoice_id).first()
            else:
                # إذا لم تُحدد الفاتورة، اختر أقدم فاتورة مستحقة للمورد
                original_invoice = PurchaseInvoice.objects.filter(
                    supplier=party,
                    remaining_amount__gt=0
                ).order_by('created_at').first()
            
            invoice = ReturnInvoice.objects.create(
                partner_type="purchase",
                supplier=party,
                purchase_invoice=original_invoice
            )

        total_return = Decimal("0.00")
        items = []

        for item in products_data:
            product = Products.objects.filter(id=item["product_id"]).first()
            quantity = item["quantity"]

            if not product or quantity <= 0:
                return Response({"error": "Invalid product data"}, status=400)

            price = Decimal(str(product.sell_price)) if return_type == "sale" else Decimal(str(product.buy_price))
            subtotal = price * Decimal(quantity)

            # stock logic
            if return_type == "sale":
                product.quantity += quantity
            else:
                if product.quantity < quantity:
                    return Response(
                        {"error": f"Not enough stock for {product.name}"},
                        status=400
                    )
                product.quantity -= quantity

            product.save()

            ReturnInvoiceItem.objects.create(
                invoice=invoice,
                product=product,
                quantity=quantity,
                unit_price=price,
                subtotal=subtotal
            )

            total_return += subtotal
            items.append({
                "product_name": product.name,
                "quantity": quantity,
                "subtotal": float(subtotal)
            })

        invoice.total = total_return
        invoice.save()

        # ✅ تحديث الفاتورة الأصلية إذا كانت موجودة
        if original_invoice:
            if return_type == "sale":
                # تقليل الرصيد المتبقي والإجمالي
                original_invoice.total -= total_return
                original_invoice.remaining_amount -= total_return
                
                # تحديث حالة الدفع إذا لزم الأمر
                if original_invoice.remaining_amount <= 0:
                    original_invoice.remaining_amount = Decimal("0.00")
                    original_invoice.payment_status = 'paid'
                elif original_invoice.paid_amount > 0:
                    original_invoice.payment_status = 'partial'
            else:
                # نفس العملية للمشتريات
                original_invoice.total -= total_return
                original_invoice.remaining_amount -= total_return
                
                if original_invoice.remaining_amount <= 0:
                    original_invoice.remaining_amount = Decimal("0.00")
                    original_invoice.payment_status = 'paid'
                elif original_invoice.paid_amount > 0:
                    original_invoice.payment_status = 'partial'
            
            original_invoice.save()

        send_invoice_whatsapp(
            party.phone,
            f"{return_type.title()} Return",
            getattr(party, "name", getattr(party, "person_name", "")),
            float(total_return),
            items,
            return_amount=float(total_return),
            original_invoice_id=original_invoice_id
        )

        serializer = ReturnInvoiceSerializer(invoice)
        return Response(serializer.data, status=201)

