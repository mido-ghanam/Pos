from django.urls import path
from . import views as v

urlpatterns = [
  path("get/all/", v.AllProductsAPIView.as_view(), name='GetAllProducts'),
  path("get/<uuid:productId>/", v.GetProductAPIView.as_view(), name='GetAllProducts'),
  path("delete/<uuid:productId>/", v.DeleteProductAPIView.as_view(), name='GetAllProducts'),


]
