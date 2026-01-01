from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from partners.models import Customers, OTPVerification
from partners.serializers import CustomerSerializer
from core import utils
from datetime import datetime, timedelta
import random
import string
import threading
from django.utils import timezone

# ================= Helper functions =================

# Generate 6-digit OTP
def generate_otp():
    return ''.join(random.choices(string.digits, k=6))

# Send OTP via WhatsApp in background
def send_otp(phone: str, otp: str, name: str):
    """إرسال OTP عبر الواتس"""
    utils.send_whatsapp_in_background(to=phone, full_name=name, code=otp, template="otp_registration")

# Send welcome message via WhatsApp in background
def send_welcome_message(phone: str, name: str):
    """إرسال رسالة ترحيب"""
    msg = f"""Welcome aboard, {name}!
We're thrilled to have you as a customer.
Your phone number has been verified and your account is now active.
You can start using our services right away.

Thank you for choosing Pos System Team!"""
    
    utils.send_whatsapp_in_background(to=phone, msg=msg, template="text_message")

# ================== Register Customer ==================
class RegisterCustomerAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        phone = request.data.get('phone')
        name = request.data.get('name')
        address = request.data.get('address')

        if not all([phone, name, address]):
            return Response({'status': False, 'error': 'Missing required fields'}, status=400)

        if Customers.objects.filter(phone=phone).exists():
            return Response({'status': False, 'error': 'Customer already exists'}, status=400)

        # Remove any old OTP for this phone
        OTPVerification.objects.filter(phone=phone, partner_type='customer').delete()

        otp = generate_otp()
        OTPVerification.objects.create(
            phone=phone,
            otp_code=otp,
            partner_type='customer',
            expires_at=timezone.now() + timedelta(minutes=10),
            temp_data={
                'name': name,
                'address': address,
                'notes': request.data.get('notes', '')
            }
        )

        # Send OTP in background
        send_otp(phone, otp, name)

        return Response({
            'status': True,
            'message': 'OTP sent successfully',
            'phone': phone,
            'next_step': 'Verify OTP using VerifyCustomerAPIView'
        }, status=201)

# ================== Verify Customer ==================
class VerifyCustomerAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        phone = request.data.get('phone')
        otp_code = request.data.get('otp_code')

        otp = OTPVerification.objects.filter(
            phone=phone,
            otp_code=otp_code,
            partner_type='customer'
        ).first()

        if not otp:
            return Response({'status': False, 'error': 'Invalid OTP'}, status=400)

        if otp.expires_at < timezone.now():
            return Response({'status': False, 'error': 'OTP expired'}, status=400)

        # Create customer after OTP verification
        customer = Customers.objects.create(
            name=otp.temp_data.get('name'),
            phone=phone,
            address=otp.temp_data.get('address'),
            notes=otp.temp_data.get('notes', ''),
            is_verified=True
        )

        # Delete OTP after successful verification
        otp.delete()

        # Send welcome message
        send_welcome_message(phone, customer.name)

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
