from partners.serializers import SupplierSerializer
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from partners.models import Suppliers
from django.db.models import Q

# ================= Register Supplier =================
class RegisterSupplierAPIView(APIView):
    permission_classes = [permissions.AllowAny]
    def post(self, request):
        phone = request.data.get('phone')
        person_name = request.data.get('person_name')
        company_name = request.data.get('company_name')
        address = request.data.get('address')

        if not all([phone, person_name, company_name, address]):
            return Response(
                {'status': False, 'error': 'Missing required fields'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if Suppliers.objects.filter(phone=phone).exists():
            return Response(
                {'status': False, 'error': 'Supplier already exists'},
                status=status.HTTP_400_BAD_REQUEST
            )
        supplier = Suppliers.objects.create(
            person_name=person_name,
            company_name=company_name,
            phone=phone,
            address=address,
            notes=request.data.get('notes', ''),
            is_verified=True,
            active=True
        )

        return Response(
            {
                'status': True,
                'message': 'Supplier registered successfully',
                'data': SupplierSerializer(supplier).data
            },
            status=status.HTTP_201_CREATED
        )

# ================= Supplier Management =================

class GetSuppliersAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        suppliers = Suppliers.objects.all().order_by('-created_at')

        search = request.query_params.get('search')
        if search:
            suppliers = suppliers.filter(
                Q(person_name__icontains=search) |
                Q(company_name__icontains=search) |
                Q(phone__icontains=search)
            )

        active = request.query_params.get('active')
        if active is not None:
            suppliers = suppliers.filter(active=active.lower() == 'true')

        serializer = SupplierSerializer(suppliers, many=True)
        return Response({
            'status': True,
            'count': suppliers.count(),
            'data': serializer.data
        })

class GetSupplierDetailAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, supplier_id):
        try:
            supplier = Suppliers.objects.get(id=supplier_id)
        except Suppliers.DoesNotExist:
            return Response(
                {'status': False, 'error': 'Supplier not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        return Response({
            'status': True,
            'data': SupplierSerializer(supplier).data
        })

class UpdateSupplierAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def patch(self, request, supplier_id):
        try:
            supplier = Suppliers.objects.get(id=supplier_id)
        except Suppliers.DoesNotExist:
            return Response(
                {'status': False, 'error': 'Supplier not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = SupplierSerializer(
            supplier,
            data=request.data,
            partial=True
        )

        if serializer.is_valid():
            serializer.save()
            return Response({'status': True, 'data': serializer.data})

        return Response(
            {'status': False, 'errors': serializer.errors},
            status=status.HTTP_400_BAD_REQUEST
        )

class DeleteSupplierAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def delete(self, request, supplier_id):
        try:
            supplier = Suppliers.objects.get(id=supplier_id)
        except Suppliers.DoesNotExist:
            return Response(
                {'status': False, 'error': 'Supplier not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        supplier.delete()
        return Response(
            {'status': True, 'message': 'Supplier deleted'},
            status=status.HTTP_204_NO_CONTENT
        )

class ToggleSupplierActiveAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, supplier_id):
        try:
            supplier = Suppliers.objects.get(id=supplier_id)
        except Suppliers.DoesNotExist:
            return Response(
                {'status': False, 'error': 'Supplier not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        supplier.active = not supplier.active
        supplier.save()

        return Response({
            'status': True,
            'active': supplier.active
        })
