from .serializers import CustomerSerializer, SupplierSerializer
from rest_framework import viewsets, permissions
from .models import Customers, Suppliers
from django.db.models import Q

class IsAdminOrReadOnly(permissions.BasePermission):
  def has_permission(self, request, view):
    if request.method in permissions.SAFE_METHODS: return True
    return request.user and request.user.is_staff

class CustomerViewSet(viewsets.ModelViewSet):
  serializer_class = CustomerSerializer
  permission_classes = [permissions.IsAuthenticatedOrReadOnly]
  def get_queryset(self):
    qs = Customers.objects.all().order_by('-created_at')
    params = self.request.query_params
    search = params.get('search')
    if search: qs = qs.filter(Q(name__icontains=search) | Q(phone__icontains=search))
    blocked = params.get('blocked')
    if blocked is not None:
      if blocked.lower() in ('true', '1'): qs = qs.filter(blocked=True)
      elif blocked.lower() in ('false', '0'): qs = qs.filter(blocked=False)
    return qs

class SupplierViewSet(viewsets.ModelViewSet):
  serializer_class = SupplierSerializer
  permission_classes = [permissions.IsAuthenticatedOrReadOnly]  # تم تعليق للاختبار
  def get_queryset(self):
    qs = Suppliers.objects.all().order_by('-created_at')
    params = self.request.query_params
    search = params.get('search')
    if search: qs = qs.filter(Q(person_name__icontains=search) | Q(company_name__icontains=search) | Q(phone__icontains=search))
    active = params.get('active')
    if active is not None:
      if active.lower() in ('true', '1'): qs = qs.filter(active=True)
      elif active.lower() in ('false', '0'): qs = qs.filter(active=False)
    return qs
