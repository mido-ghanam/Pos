from rest_framework import viewsets, status
from rest_framework.response import Response
from billing.models import PurchaseInvoice, PurchaseInvoiceItem
from billing.serializers import PurchaseInvoiceSerializer
from products.models import Products
from partners.models import Suppliers
from billing.utils import send_invoice_whatsapp
from django.db.models import Sum

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
    def create(self, request):
        supplier_id = request.data.get("supplier_id")
        payment_method = request.data.get("payment_method", "Cash")
        products_data = request.data.get("products")  # [{"product_id":1, "quantity":2}, ...]

        supplier = Suppliers.objects.filter(id=supplier_id, blocked=False).first()
        if not supplier:
            return Response({"error": "Supplier blocked or not found"}, status=400)

        invoice = PurchaseInvoice.objects.create(supplier=supplier, payment_method=payment_method, total=0)
        total_invoice = 0
        items_serialized = []

        for p in products_data:
            product = Products.objects.filter(id=item["product_id"]).first()
            if not product:
                invoice.delete()
                return Response({"error": f"Product {p.get('product_id')} not found"}, status=400)

            subtotal = product.purchase_price * p["quantity"]  # Assuming purchase_price field

            PurchaseInvoiceItem.objects.create(
                invoice=invoice,
                product=product,
                quantity=p["quantity"],
                unit_price=product.purchase_price,
                subtotal=subtotal
            )

            # Update product stock
            product.quantity += p["quantity"]
            product.save()

            total_invoice += subtotal
            items_serialized.append({"product_name": product.name, "quantity": p["quantity"], "subtotal": subtotal})

        invoice.total = total_invoice
        invoice.save()

        # Send invoice to supplier via WhatsApp
        send_invoice_whatsapp(supplier.phone, "Purchase", supplier.name, total_invoice, items_serialized)

        serializer = PurchaseInvoiceSerializer(invoice)
        return Response(serializer.data, status=201)
