from rest_framework import viewsets, status
from rest_framework.response import Response
from billing.models import ReturnInvoice, ReturnInvoiceItem, SalesInvoiceItem, PurchaseInvoiceItem
from billing.serializers import ReturnInvoiceSerializer
from products.models import Products
from partners.models import Customers, Suppliers
from billing.utils import send_invoice_whatsapp
from django.db.models import Sum

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
    """
    Handle return from sales or purchase
    """
    def create(self, request):
        return_type = request.data.get("return_type")  # "sales" or "purchase"
        party_id = request.data.get("party_id")  # Customer or Supplier ID
        products_data = request.data.get("products")  # [{"product_id":1, "quantity":1}, ...]

        # Identify party
        if return_type == "sales":
            party = Customers.objects.filter(id=party_id, blocked=False).first()
        else:
            party = Suppliers.objects.filter(id=party_id, blocked=False).first()

        if not party:
            return Response({"error": "Customer/Supplier blocked or not found"}, status=400)

        invoice = ReturnInvoice.objects.create(return_type=return_type, party_id=party_id, total=0)
        total_invoice = 0
        items_serialized = []

        for p in products_data:
            product = Products.objects.filter(id=item["product_id"]).first()
            if not product:
                invoice.delete()
                return Response({"error": f"Product {p.get('product_id')} not found"}, status=400)

            # Check stock for return (if sales return, add back to stock; if purchase return, subtract)
            if return_type == "sales":
                product.quantity += p["quantity"]
            else:
                if product.quantity < p["quantity"]:
                    invoice.delete()
                    return Response({"error": f"Not enough stock to return for product {product.name}"}, status=400)
                product.quantity -= p["quantity"]
            product.save()

            # Calculate subtotal
            price = product.price if return_type == "sales" else product.purchase_price
            subtotal = price * p["quantity"]

            ReturnInvoiceItem.objects.create(
                invoice=invoice,
                product=product,
                quantity=p["quantity"],
                unit_price=price,
                subtotal=subtotal
            )

            total_invoice += subtotal
            items_serialized.append({"product_name": product.name, "quantity": p["quantity"], "subtotal": subtotal})

        invoice.total = total_invoice
        invoice.save()

        # Send invoice via WhatsApp
        send_invoice_whatsapp(party.phone, f"{return_type.title()} Return", party.name, total_invoice, items_serialized)

        serializer = ReturnInvoiceSerializer(invoice)
        return Response(serializer.data, status=201)
