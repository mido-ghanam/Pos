from django.urls import path
from . import views

urlpatterns = [
  path('stores/', views.StoreListCreateAPIView.as_view(), name='stores-list'),
  path('stores/<int:pk>/', views.StoreDetailAPIView.as_view(), name='store-detail'),
]
