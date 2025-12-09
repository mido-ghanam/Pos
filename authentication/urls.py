from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.RegisterAPIView.as_view(), name='register'),
    path('login/', views.LoginAPIView.as_view(), name='login'),
    path('logout/', views.LogoutAPIView.as_view(), name='logout'),
    path('me/', views.MeAPIView.as_view(), name='me'),
    path('change-password/', views.ChangePasswordAPIView.as_view(), name='change-password'),
    # Stores (multi-organization support)
    path('stores/', views.StoreListCreateAPIView.as_view(), name='stores-list'),
    path('stores/<int:pk>/', views.StoreDetailAPIView.as_view(), name='store-detail'),
]
