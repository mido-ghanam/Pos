from .serializers import AllProductsSerializer, GetProductSerializer
from rest_framework import status, permissions
from rest_framework.parsers import JSONParser
from rest_framework.response import Response
from rest_framework.views import APIView
from . import models as m

class AllProductsAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  parser_classes = [JSONParser]
  def get(self, request):
    qs = m.Products.objects.all()
    serializer = AllProductsSerializer(qs, many=True)
    return Response(serializer.data)

class GetProductAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  parser_classes = [JSONParser]
  def get(self, request, productId):
    qs = m.Products.objects.filter(id=productId)
    serializer = GetProductSerializer(qs, many=True)
    return Response(serializer.data)

class DeleteProductAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  def delete(self, request, productId):
    qs = m.Products.objects.filter(id=productId)
    if not qs.exists():
      return Response({"status": False, "message": f"Product with id '{productId}' isn't exists!"})
    productName = qs.first().name
    qs.delete()
    return Response({"status": True, "message": f"Product '{productName}' has been deleted."})

class EditProductAPIView(APIView):
  permission_classes = [permissions.AllowAny] #[permissions.IsAuthenticated]
  def post(self, request, productId):
    qs = m.Products.objects.filter(id=productId)
    if not qs.exists():
      return Response({"status": False, "message": f"Product with id '{productId}' isn't exists!"})
    productName = qs.first().name
    qs.delete()
    return Response({"status": True, "message": f"Product '{productName}' has been deleted."})
