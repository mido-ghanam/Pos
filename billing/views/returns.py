from rest_framework import viewsets, status
from rest_framework.response import Response
from billing.models import ReturnInvoice, ReturnInvoiceItem, SalesInvoice, PurchaseInvoice,CashBox
from billing.serializers import ReturnInvoiceSerializer
from products.models import Products
from partners.models import Customers, Suppliers
from django.db.models import Sum
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from decimal import Decimal
from rest_framework.pagination import PageNumberPagination

def addPagination(pageSize):
  paginator = PageNumberPagination()
  paginator.page_size = pageSize if pageSize else 10
  return paginator

def update_cashbox(amount, increase=True):
    """
    increase=True  -> تضيف للرصيد (Purchase Return)
    increase=False -> تنقص الرصيد (Sale Return)
    """
    from billing.models import CashBox
    cashbox = CashBox.objects.select_for_update().first()
    if not cashbox:
        raise Exception("CashBox not found")

    if not increase and cashbox.balance < amount:
        raise Exception("Insufficient cash balance for sale return")

    if increase:
        cashbox.balance += amount
    else:
        cashbox.balance -= amount

    cashbox.save()


# ---------------- List all Return Invoices ----------------
class ReturnInvoiceListView(viewsets.ViewSet):
    def list(self, request):
        invoices = ReturnInvoice.objects.all()
        total_returns = invoices.aggregate(total=Sum('total'))["total"] or 0
        count = invoices.count()
        paginator = addPagination(10)
        invoices = paginator.paginate_queryset(invoices, request)
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
    permission_classes = [IsAuthenticated]

    @transaction.atomic
    def create(self, request):
        return_type = request.data.get("return_type")  # sale | purchase
        party_id = request.data.get("party_id")
        original_invoice_id = request.data.get("original_invoice_id")  # معرف الفاتورة الأصلية
        products_data = request.data.get("products", [])
        discount = Decimal(str(request.data.get("discount", 0)))  # خصم النسبة المئوية

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
                # إذا لم تُحدد الفاتورة، ابحث عن أحدث فاتورة للعميل (لا تحتاج للشرط remaining_amount > 0)
                original_invoice = SalesInvoice.objects.filter(customer=party).order_by('-created_at').first()
            
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
                # إذا لم تُحدد الفاتورة، ابحث عن أحدث فاتورة للمورد
                original_invoice = PurchaseInvoice.objects.filter(supplier=party).order_by('-created_at').first()
            
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

            # 🔧 استخدم السعر من الفاتورة الأصلية إن وجدت
            # لضمان أن المرتجع يكون بنفس السعر الفعلي المباع/المشترى
            price = None
            
            if original_invoice:
                if return_type == "sale":
                    # ابحث عن نفس المنتج في الفاتورة الأصلية
                    original_item = original_invoice.items.filter(product_id=product.id).first()
                    if original_item:
                        price = original_item.unit_price
                else:
                    # ابحث عن نفس المنتج في فاتورة الشراء الأصلية
                    original_item = original_invoice.items.filter(product_id=product.id).first()
                    if original_item:
                        price = original_item.unit_price
            
            # إذا لم نجد السعر من الفاتورة الأصلية، استخدم السعر الحالي
            if price is None:
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

        # حساب الخصم كنسبة مئوية من الإجمالي
        #discount_amount = (total_return * discount_percent) / Decimal("100")
        total_after_discount = total_return - discount
        # تحديث الخزنة بناءً على نوع المرتجع
        if return_type == "sale":
           update_cashbox(total_after_discount, increase=False)  # العملاء رجعوا فلوس → نقص
        else:   
           update_cashbox(total_after_discount, increase=True)   # المورد رجع فلوس → زيادة

        
        if total_after_discount < Decimal("0.00"):
            total_after_discount = Decimal("0.00")
        
        invoice.total = total_after_discount
        invoice.save()

        # ❌ لا نعدل الفاتورة الأصلية
        # المرتجع هو فاتورة منفصلة وليس تعديل على الفاتورة الأصلية
        # Accounts: 
        # - purchases_total يبقى ثابت (مجموع كل الفواتير الأصلية)
        # - purchase_returns يزيد (مجموع كل المرتجعات)
        # - net_purchases = purchases_total - purchase_returns

        

        serializer = ReturnInvoiceSerializer(invoice)
        return Response(serializer.data, status=201)

