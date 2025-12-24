from django.urls import path
from . import views as v

urlpatterns = [
  ## Products ##
  path("get/all/", v.products.AllProductsAPIView.as_view(), name='GetAllProducts'),
  path("get/<uuid:productId>/", v.products.GetProductAPIView.as_view(), name='GetProduct'),
  path("add/", v.products.AddProductAPIView.as_view(), name='AddProduct'),
  path("delete/<uuid:productId>/", v.products.DeleteProductAPIView.as_view(), name='DeleteProduct'),
  path("edit/<uuid:productId>/", v.products.EditProductAPIView.as_view(), name='EditProduct'),
  
  ## Categories ##
  path("categories/get/all/", v.categories.AllCategoriesAPIView.as_view(), name='GetAllProducts'),
  path("categories/get/<uuid:categoryId>/", v.categories.GetCategoryAPIView.as_view(), name='GetProduct'),
  path("categories/add/", v.categories.AddCategoryAPIView.as_view(), name='AddProduct'),
  #path("delete/<uuid:productId>/", v.categories.DeleteProductAPIView.as_view(), name='DeleteProduct'),
  #path("edit/<uuid:productId>/", v.categories.EditProductAPIView.as_view(), name='EditProduct'),
  

]
