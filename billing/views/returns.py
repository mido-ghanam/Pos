from rest_framework import viewsets, status
from rest_framework.response import Response
from billing.models import ReturnInvoice, ReturnInvoiceItem, SalesInvoiceItem, PurchaseInvoiceItem
from billing.serializers import ReturnInvoiceSerializer
from products.models import Products
from partners.models import Customers, Suppliers
from billing.utils import send_invoice_whatsapp
from django.db.models import Sum
from rest_framework.permissions import AllowAny

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
    """
    Handle return from sales or purchase
    """
    def create(self, request):
        return_type = request.data.get("return_type")  # "sales" or "purchase"
        party_id = request.data.get("party_id")  # Customer or Supplier ID
        products_data = request.data.get("products")  # [{"product_id":1, "quantity":1}, ...]

        if return_type not in ["sales", "purchase"]:
            return Response({"error": "Invalid return_type, must be 'sales' or 'purchase'"}, status=400)

        # Identify party
        if return_type == "sales":
            party = Customers.objects.filter(id=party_id, blocked=False).first()
        else:
            party = Suppliers.objects.filter(id=party_id, active=True).first()

        if not party:
            return Response({"error": "Customer/Supplier blocked or not found"}, status=400)

        # Create invoice with correct fields
        if return_type == "sales":
            invoice = ReturnInvoice.objects.create(
                partner_type="sale",
                customer=party,
                total=0
            )
        else:
            invoice = ReturnInvoice.objects.create(
                partner_type="purchase",
                supplier=party,
                total=0
            )

        total_invoice = 0
        items_serialized = []

        for p in products_data:
            product = Products.objects.filter(id=p["product_id"]).first()
            if not product:
                invoice.delete()
                return Response({"error": f"Product {p.get('product_id')} not found"}, status=400)

            # Check stock for return
            if return_type == "sales":
                # Sales return → add back to stock
                product.quantity += p["quantity"]
            else:
                # Purchase return → subtract from stock
                if product.quantity < p["quantity"]:
                    invoice.delete()
                    return Response({"error": f"Not enough stock to return for product {product.name}"}, status=400)
                product.quantity -= p["quantity"]

            product.save()

            # Calculate subtotal
            price = product.sell_price if return_type == "sales" else product.buy_price
            subtotal = price * p["quantity"]

            # Create ReturnInvoiceItem
            ReturnInvoiceItem.objects.create(
                invoice=invoice,
                product=product,
                quantity=p["quantity"],
                unit_price=price,
                subtotal=subtotal
            )

            total_invoice += subtotal
            items_serialized.append({
                "product_name": product.name,
                "quantity": p["quantity"],
                "subtotal": subtotal
            })

        # Update invoice total
        invoice.total = total_invoice
        invoice.save()

        # Send invoice via WhatsApp
        party_name = getattr(party, "name", None) or getattr(party, "person_name", "")
        send_invoice_whatsapp(party.phone, f"{return_type.title()} Return", party_name, total_invoice, items_serialized)

        serializer = ReturnInvoiceSerializer(invoice)
        return Response(serializer.data, status=201)