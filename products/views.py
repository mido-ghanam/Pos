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

class AddProductAPIView(APIView):
  permission_classes = [permissions.AllowAny]
  def post(self, request):
    serializer = AddProductSerializer(data=request.data)
    if not serializer.is_valid(): return Response({"status": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
    data = serializer.validated_data
    category_id = data.pop("category")
    category = m.Category.objects.filter(id=category_id).first()
    if not category: return Response({"status": False, "message": f"Category with id '{category_id}' not found."}, status=status.HTTP_400_BAD_REQUEST)
    product = m.Products.objects.create(category=category, **data)
    return Response({"status": True, "message": "Product created successfully.", "product_id": product.id}, status=status.HTTP_201_CREATED)

class DeleteProductAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  def delete(self, request, productId):
    qs = m.Products.objects.filter(id=productId)
    if not qs.exists():
      return Response({"status": False, "message": f"Product with id '{productId}' isn't exists!"}, status=404)
    productName = qs.first().name
    qs.delete()
    return Response({"status": True, "message": f"Product '{productName}' has been deleted."})

class EditProductAPIView(APIView):
  permission_classes = [permissions.AllowAny]#[permissions.IsAuthenticated]
  def patch(self, request, productId):
    qs = m.Products.objects.filter(id=productId)
    if not qs.exists(): return Response({"status": False, "message": f"Product with id '{productId}' doesn't exist!"}, status=404)
    qs, updated, notFound = qs.first(), {}, []
    for key, value in request.data.items():
      if not hasattr(qs, key): notFound.append(key)
      if key == "category": value = m.Category.objects.filter(id=str(value)).first()
      updated[key] = {"before": getattr(qs, key)}        
      setattr(qs, key, value)
      updated[key]["after"] = value
    qs.save()
    return Response({"status": True, "message": "Product updated successfully!", "updated": updated, "notFound": notFound})
