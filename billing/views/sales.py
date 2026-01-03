from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.db.models import Sum
from rest_framework.views import APIView
from billing.models import SalesInvoice, SalesInvoiceItem
from billing.serializers import SalesInvoiceSerializer
from products.models import Products
from partners.models import Customers
from billing.utils import send_invoice_whatsapp


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
    
    def create(self, request):
        customer_id = request.data.get("customer_id")
        payment_method = request.data.get("payment_method", "Cash")
        products_data = request.data.get("products", [])

        # Check customer
        customer = Customers.objects.filter(id=customer_id, blocked=False).first()
        if not customer:
            return Response({"error": "Customer blocked or not found"}, status=400)

        invoice = SalesInvoice.objects.create(
            customer=customer,
            payment_method=payment_method
        )

        total_invoice = 0
        whatsapp_items = []

        for item in products_data:
            product = Products.objects.filter(id=item["product_id"]).first()

            if not product:
                invoice.delete()
                return Response({"error": "Product not found"}, status=400)

            if product.quantity < item["quantity"]:
                invoice.delete()
                return Response({
                    "error": f"Not enough stock for {product.name}"
                }, status=400)

            subtotal = product.sell_price * item["quantity"]

            SalesInvoiceItem.objects.create(
                invoice=invoice,
                product=product,
                quantity=item["quantity"],
                unit_price=product.sell_price,
                subtotal=subtotal
            )

            product.quantity -= item["quantity"]
            product.save()

            total_invoice += subtotal
            whatsapp_items.append({
                "product_name": product.name,
                "quantity": item["quantity"],
                "subtotal": subtotal
            })

        invoice.total = total_invoice
        invoice.save()

        send_invoice_whatsapp(
            customer.phone,
            "Sales",
            customer.name,
            total_invoice,
            whatsapp_items
        )

        serializer = SalesInvoiceSerializer(invoice)
        return Response(serializer.data, status=201)

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