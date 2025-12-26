from . import views as v
from rest_framework.routers import DefaultRouter
from django.urls import path, include

router = DefaultRouter()
router.register(r'customers', v.CustomerViewSet, basename='customer')
router.register(r'suppliers', v.SupplierViewSet, basename='supplier')

urlpatterns = [path('', include(router.urls)),]
