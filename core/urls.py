from django.urls import path
from . import views as v

urlpatterns = [
  path("", v.Index.as_view(), name="index")
]
