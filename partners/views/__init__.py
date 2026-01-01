"""
Partners Views Package
Organized views for Customers and Suppliers
"""

# Customer Views
from .customers import (
  GetCustomersAPIView,
  GetCustomerDetailAPIView,
  RegisterCustomerAPIView,
  VerifyCustomerAPIView,
  UpdateCustomerAPIView,
  DeleteCustomerAPIView,
  BlockCustomerAPIView,
)

# Supplier Views
from .suppliers import (
  GetSuppliersAPIView,
  GetSupplierDetailAPIView,
  RegisterSupplierAPIView,
  VerifySupplierAPIView,
  UpdateSupplierAPIView,
  DeleteSupplierAPIView,
  ToggleSupplierActiveAPIView,
)

__all__ = [
  # OTP
  'SendOTPAPIView',
  'VerifyOTPAPIView',
  'generate_otp',
  'verify_otp_code',
  
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
  'ToggleSupplierActiveAPIView',
]
