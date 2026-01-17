from partners.models import Customers, OTPVerification
from partners.serializers import CustomerSerializer
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q

class RegisterCustomerAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        phone = request.data.get('phone')
        name = request.data.get('name')
        address = request.data.get('address')
        if not all([phone, name, address]): return Response({'status': False, 'error': 'Missing required fields'}, status=400)

        if Customers.objects.filter(phone=phone).exists(): return Response({'status': False, 'error': 'Customer already exists'}, status=400)
        customer = Customers.objects.create(
            name=name,
            phone=phone,
            address=address,
            notes=request.data.get('notes', ''),
            is_verified=True
        )
        return Response({
            'status': True,
            'message': 'Customer registered successfully',
            'data': CustomerSerializer(customer).data
        }, status=201)

# ================= Customer Management APIs =================
class GetCustomersAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        customers = Customers.objects.all().order_by('-created_at')

        search = request.query_params.get('search')
        if search:
            customers = customers.filter(
                Q(name__icontains=search) |
                Q(phone__icontains=search)
            )

        blocked = request.query_params.get('blocked')
        if blocked is not None:
            customers = customers.filter(blocked=blocked.lower() == 'true')

        serializer = CustomerSerializer(customers, many=True)
        return Response({
            'status': True,
            'count': customers.count(),
            'data': serializer.data
        })
class GetCustomerDetailAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, customer_id):
        try:
            customer = Customers.objects.get(id=customer_id)
        except Customers.DoesNotExist:
            return Response({'status': False, 'error': 'Customer not found'}, status=404)

        return Response({'status': True, 'data': CustomerSerializer(customer).data})

class UpdateCustomerAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def patch(self, request, customer_id):
        try:
            customer = Customers.objects.get(id=customer_id)
        except Customers.DoesNotExist:
            return Response({'status': False, 'error': 'Customer not found'}, status=404)

        serializer = CustomerSerializer(customer, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'status': True, 'data': serializer.data})

        return Response({'status': False, 'errors': serializer.errors}, status=400)
class DeleteCustomerAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def delete(self, request, customer_id):
        try:
            customer = Customers.objects.get(id=customer_id)
        except Customers.DoesNotExist:
            return Response({'status': False, 'error': 'Customer not found'}, status=404)

        customer.delete()
        return Response({'status': True, 'message': 'Customer deleted'}, status=204)
class BlockCustomerAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, customer_id):
        try:
            customer = Customers.objects.get(id=customer_id)
        except Customers.DoesNotExist:
            return Response({'status': False, 'error': 'Customer not found'}, status=404)

        customer.blocked = not customer.blocked
        customer.save()

        return Response({
            'status': True,
            'blocked': customer.blocked
        })
