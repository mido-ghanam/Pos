from django.urls import path
from rest_framework.routers import DefaultRouter
from billing.views.sales import (
    SalesInvoiceListView,
    SalesInvoiceDetailView,
    SalesInvoiceCreateView,
    SalesInvoicesByCustomerView,
    SalesStatsView,
    PayInvoiceBalanceView,
    PayCustomerAccountView,
    CustomersWithBalanceView
)
from billing.views.purchases import (
    PurchaseInvoiceListView,
    PurchaseInvoiceDetailView,
    PurchaseInvoiceCreateView,
    PurchaseInvoicesBySupplierView,
    PurchaseStatsView,
    PayPurchaseBalanceView,
    PaySupplierAccountView,
    SuppliersWithBalanceView
)
from billing.views.returns import (
    ReturnInvoiceListView,
    ReturnInvoiceDetailView,
    ReturnInvoiceCreateView
)
from billing.views.dashboard import BillingDashboardView, ProfitStatsView,CashBoxView
from billing.views.expenses import ExpenseCreateView


urlpatterns = [
    # Sales
    path('sales/', SalesInvoiceListView.as_view({'get':'list'}), name='sales-list'),
    path('sales/<int:pk>/', SalesInvoiceDetailView.as_view({'get':'retrieve'}), name='sales-detail'),
    path('sales/create/', SalesInvoiceCreateView.as_view({'post':'create'}), name='sales-create'),
    path('sales/<int:invoice_id>/pay-balance/', PayInvoiceBalanceView.as_view(), name='pay-invoice-balance'),
    path('sales/customer/<uuid:customer_id>/',SalesInvoicesByCustomerView.as_view(), name='sales-by-customer'),
    path('customers/<uuid:customer_id>/pay-balance/', PayCustomerAccountView.as_view(), name='pay-customer-balance'),
    path('customers/with-balance/', CustomersWithBalanceView.as_view(), name='customers-with-balance'),
    # Sales Stats
    path('sales/stats/', SalesStatsView.as_view(), name='sales-stats'),
    # Purchases
    path('purchases/', PurchaseInvoiceListView.as_view({'get':'list'}), name='purchases-list'),
    path('purchases/<int:pk>/', PurchaseInvoiceDetailView.as_view({'get':'retrieve'}), name='purchases-detail'),
    path('purchases/create/', PurchaseInvoiceCreateView.as_view({'post':'create'}), name='purchases-create'),
    path('purchases/<int:invoice_id>/pay-balance/', PayPurchaseBalanceView.as_view(), name='pay-purchase-balance'),
    path('purchases/supplier/<uuid:supplier_id>/',PurchaseInvoicesBySupplierView.as_view(), name='purchases-by-supplier'),
    path('suppliers/<uuid:supplier_id>/pay-balance/', PaySupplierAccountView.as_view(), name='pay-supplier-balance'),
    path('suppliers/with-balance/', SuppliersWithBalanceView.as_view(), name='suppliers-with-balance'),
    # Purchase Stats
    path('purchases/stats/', PurchaseStatsView.as_view(), name='purchases-stats'),
    # Returns
    path('refunds/', ReturnInvoiceListView.as_view({'get':'list'}), name='returns-list'),
    path('refunds/<int:pk>/', ReturnInvoiceDetailView.as_view({'get':'retrieve'}), name='returns-detail'),
    path('refunds/create/', ReturnInvoiceCreateView.as_view({'post':'create'}), name='returns-create'),

    # Dashboard & Stats
    path('profit/', BillingDashboardView.as_view(), name='billing-dashboard'),
    path('profit-stats/', ProfitStatsView.as_view(), name='profit-stats'),
    path('cashbox/', CashBoxView.as_view(), name='cashbox'),

    # Expenses
    path('expenses/create/', ExpenseCreateView.as_view(), name='expense-create'),
]
