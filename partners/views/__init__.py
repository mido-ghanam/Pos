"""
Partners Views Package
Organized views for Customers and Suppliers
"""

# Customer Views
from .customers import (
  GetCustomersAPIView,
  GetCustomerDetailAPIView,
  RegisterCustomerAPIView,
  UpdateCustomerAPIView,
  DeleteCustomerAPIView,
  BlockCustomerAPIView,
)

# Supplier Views
from .suppliers import (
  GetSuppliersAPIView,
  GetSupplierDetailAPIView,
  RegisterSupplierAPIView,
  UpdateSupplierAPIView,
  DeleteSupplierAPIView,
  ToggleSupplierActiveAPIView,
)

__all__ = [
  
  # Customers
  'GetCustomersAPIView',
  'GetCustomerDetailAPIView',
  'RegisterCustomerAPIView',
  'UpdateCustomerAPIView',
  'DeleteCustomerAPIView',
  'BlockCustomerAPIView',
  
  # Suppliers
  'GetSuppliersAPIView',
  'GetSupplierDetailAPIView',
  'RegisterSupplierAPIView',
  'UpdateSupplierAPIView',
  'DeleteSupplierAPIView',
]
