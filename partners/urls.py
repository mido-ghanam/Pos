from .views import (
  # Customers
  GetCustomersAPIView,
  GetCustomerDetailAPIView,
  RegisterCustomerAPIView,
  VerifyCustomerAPIView,
  UpdateCustomerAPIView,
  DeleteCustomerAPIView,
  BlockCustomerAPIView,
  
  # Suppliers
  GetSuppliersAPIView,
  GetSupplierDetailAPIView,
  RegisterSupplierAPIView,
  VerifySupplierAPIView,
  UpdateSupplierAPIView,
  DeleteSupplierAPIView,
  ToggleSupplierActiveAPIView,
)
from django.urls import path

urlpatterns = [
  # ================================
  # Customer Endpoints
  # ================================
  path('customers/', GetCustomersAPIView.as_view(), name='list-customers'),
  path('customers/<uuid:customer_id>/', GetCustomerDetailAPIView.as_view(), name='customer-detail'),
  path('customers/register/', RegisterCustomerAPIView.as_view(), name='register-customer'),
  path('customers/register_verify/', VerifyCustomerAPIView.as_view(), name='verify-customer'),
  path('customers/update/<uuid:customer_id>/', UpdateCustomerAPIView.as_view(), name='update-customer'),
  path('customers/delete/<uuid:customer_id>/', DeleteCustomerAPIView.as_view(), name='delete-customer'),
  path('customers/block/<uuid:customer_id>/', BlockCustomerAPIView.as_view(), name='block-customer'),
  
  # ================================
  # Supplier Endpoints
  # ================================
  path('suppliers/', GetSuppliersAPIView.as_view(), name='list-suppliers'),
  path('suppliers/<uuid:supplier_id>/', GetSupplierDetailAPIView.as_view(), name='supplier-detail'),
  path('suppliers/register/', RegisterSupplierAPIView.as_view(), name='register-supplier'),
  path('suppliers/register_verify/', VerifySupplierAPIView.as_view(), name='verify-supplier'),
  path('suppliers/update/<uuid:supplier_id>/', UpdateSupplierAPIView.as_view(), name='update-supplier'),
  path('suppliers/delete/<uuid:supplier_id>/', DeleteSupplierAPIView.as_view(), name='delete-supplier'),
  path('suppliers/toggle-active/<uuid:supplier_id>/', ToggleSupplierActiveAPIView.as_view(), name='toggle-supplier-active'),
]
