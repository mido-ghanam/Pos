from django.urls import path
from . import views as v

urlpatterns = [
  path("get/all/", v.AllProductsAPIView.as_view(), name='GetAllProducts'),
  path("get/<uuid:productId>/", v.GetProductAPIView.as_view(), name='GetProduct'),
  path("delete/<uuid:productId>/", v.DeleteProductAPIView.as_view(), name='DeleteProduct'),
  path("edit/", v.EditProductAPIView.as_view(), name='EditProduct'),


]
