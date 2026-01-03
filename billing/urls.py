from django.urls import path
from rest_framework.routers import DefaultRouter
from billing.views.sales import (
    SalesInvoiceListView,
    SalesInvoiceDetailView,
    SalesInvoiceCreateView,
    SalesInvoicesByCustomerView
)
from billing.views.purchases import (
    PurchaseInvoiceListView,
    PurchaseInvoiceDetailView,
    PurchaseInvoiceCreateView,
    PurchaseInvoicesBySupplierView
)
from billing.views.returns import (
    ReturnInvoiceListView,
    ReturnInvoiceDetailView,
    ReturnInvoiceCreateView
)
from billing.views.dashboard import BillingDashboardView


urlpatterns = [
    # Sales
    path('sales/', SalesInvoiceListView.as_view({'get':'list'}), name='sales-list'),
    path('sales/<int:pk>/', SalesInvoiceDetailView.as_view({'get':'retrieve'}), name='sales-detail'),
    path('sales/create/', SalesInvoiceCreateView.as_view({'post':'create'}), name='sales-create'),
    path('sales/customer/<uuid:customer_id>/',SalesInvoicesByCustomerView.as_view(), name='sales-by-customer'),
    # Purchases
    path('purchases/', PurchaseInvoiceListView.as_view({'get':'list'}), name='purchases-list'),
    path('purchases/<int:pk>/', PurchaseInvoiceDetailView.as_view({'get':'retrieve'}), name='purchases-detail'),
    path('purchases/create/', PurchaseInvoiceCreateView.as_view({'post':'create'}), name='purchases-create'),
    path('purchases/supplier/<uuid:supplier_id>/',PurchaseInvoicesBySupplierView.as_view(), name='purchases-by-supplier'),
    # Returns
    path('returns/', ReturnInvoiceListView.as_view({'get':'list'}), name='returns-list'),
    path('returns/<int:pk>/', ReturnInvoiceDetailView.as_view({'get':'retrieve'}), name='returns-detail'),
    path('returns/create/', ReturnInvoiceCreateView.as_view({'post':'create'}), name='returns-create'),

    # Dashboard
    path('dashboard/', BillingDashboardView.as_view(), name='billing-dashboard'),
]
