from django.urls import path
from . import views as v

urlpatterns = [
  ## Products ##
  path("get/all/", v.products.AllProductsAPIView.as_view(), name='GetAllProducts'),
  path("get/", v.products.GetProductAPIView.as_view(), name='GetProduct'),
  path("add/", v.products.AddProductAPIView.as_view(), name='AddProduct'),
  path("delete/", v.products.DeleteProductAPIView.as_view(), name='DeleteProduct'),
  path("edit/", v.products.EditProductAPIView.as_view(), name='EditProduct'),
  
  ## Categories ##
  path("categories/get/all/", v.categories.AllCategoriesAPIView.as_view(), name='GetAllCategories'),
  path("categories/get/", v.categories.GetCategoryAPIView.as_view(), name='GetCategory'),
  path("categories/add/", v.categories.AddCategoryAPIView.as_view(), name='AddCategory'),
  path("categories/delete/", v.categories.DeleteCategoryAPIView.as_view(), name='DeleteCategory'),
  path("categories/edit/", v.categories.EditCategoryAPIView.as_view(), name='EditCategory'),

]
