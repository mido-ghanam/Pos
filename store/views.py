from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from .serializers import StoreSerializer
from .models import Store

User = get_user_model()

class StoreListCreateAPIView(APIView):
  queryset = Store.objects.filter(members=request.user)
  serializer_class = StoreSerializer
  permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

class StoreDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
  queryset = Store.objects.all()
  serializer_class = StoreSerializer
  permission_classes = (permissions.IsAuthenticated,)
