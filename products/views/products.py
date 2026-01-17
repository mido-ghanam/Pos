from ..serializers import AllProductsSerializer, GetProductSerializer, AddProductSerializer
from rest_framework import status, permissions
from rest_framework.parsers import JSONParser
from rest_framework.response import Response
from rest_framework.views import APIView
from .. import models as m
import uuid, random

class AllProductsAPIView(APIView):
  permission_classes = [permissions.AllowAny]
  #permission_classes = [permissions.IsAuthenticated]
  parser_classes = [JSONParser]
  def get(self, request):
    qs = m.Products.objects.all()
    serializer = AllProductsSerializer(qs, many=True)
    return Response({"status": True, "data": serializer.data})

class GetProductAPIView(APIView):
  #permission_classes = [permissions.IsAuthenticated]
  permission_classes = [permissions.AllowAny]
  parser_classes = [JSONParser]
  def get(self, request):
    productId = request.GET.get("productId", "")
    if not productId: return Response({"status": True, "message": "Get field 'productId' is messing.", "error": "Get Field is messing"}, status=400)
    try: uuid.UUID(str(productId))
    except ValueError: return Response({"status": False, "message": "Invalid product id"}, status=400)
    qs = m.Products.objects.filter(id=productId)
    if not qs.exists(): return Response({"status": False, "message": f"Product with id '{productId} not found"}, status=404)
    serializer = GetProductSerializer(qs, many=True)
    return Response({"status": True, "data": serializer.data})

class AddProductAPIView(APIView):
  #permission_classes = [permissions.IsAuthenticated]
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
  permission_classes = [permissions.AllowAny]
  #permission_classes = [permissions.IsAuthenticated]
  def delete(self, request):
    productId = request.GET.get("productId", "")
    if not productId: return Response({"status": True, "message": "Get field 'productId' is messing.", "error": "Get Field is messing"}, status=400)
    qs = m.Products.objects.filter(id=productId)
    if not qs.exists(): return Response({"status": False, "message": f"Product with id '{productId}' isn't exists!"}, status=404)
    productName = qs.first().name
    qs.delete()
    return Response({"status": True, "message": f"Product '{productName}' has been deleted."})

class EditProductAPIView(APIView):
  permission_classes = [permissions.AllowAny]
  def patch(self, request):
    productId = request.GET.get("productId", "")
    if not productId: return Response({"status": True, "message": "Get field 'productId' is messing.", "error": "Get Field is messing"}, status=400)
    try: uuid.UUID(str(productId))
    except ValueError: return Response({"status": False, "message": "Invalid product id"}, status=400)
    product = m.Products.objects.filter(id=productId).first()
    if not product: return Response({"status": False, "message": f"Product with id '{productId}' doesn't exist!"}, status=404)
    updated, notFound = {}, []
    ALLOWED_FIELDS = ["name", "barcode", "category", "discription", "buy_price", "sell_price", "quantity", "min_quantity", "active", "monitor"]
    for key, value in request.data.items():
      if not value: continue
      if str(key) == "category":
        cat = m.Category.objects.filter(id=value).first()
        if not cat: return Response({"status": False, "message": f"Category with id '{value}' doesn't exist!"}, status=404)
        value = cat
      if key not in ALLOWED_FIELDS:
        notFound.append(key)
        continue
      before = getattr(product, key)
      setattr(product, key, value)
      if str(key) != "category": updated[key] = {"before": before, "after": value}
      else: updated[key] = {"before": before.name, "after": value.name}
    product.save()
    return Response({"status": True, "message": "Product updated successfully!", "updated": updated, "notFound": notFound})
