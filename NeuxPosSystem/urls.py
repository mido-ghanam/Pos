from django.urls import path, include
from django.contrib import admin

urlpatterns = [
  path('admin/', admin.site.urls),
  path('auth/', include('authentication.urls')),
  path('products/', include('products.urls')),
  path('partners/', include('partners.urls')),
  path('billing/', include('billing.urls')),

]
