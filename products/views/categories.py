from ..serializers import CategoriesSerializer, AddCategoriesSerializer
from rest_framework import status, permissions
from rest_framework.parsers import JSONParser
from rest_framework.response import Response
from rest_framework.views import APIView
from .. import models as m

class AllCategoriesAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  parser_classes = [JSONParser]
  def get(self, request):
    qs = m.Category.objects.all()
    serializer = CategoriesSerializer(qs, many=True)
    return Response({"status": True, "data": serializer.data})

class GetCategoryAPIView(APIView):
  permission_classes = [permissions.AllowAny] #[permissions.IsAuthenticated]
  parser_classes = [JSONParser]
  def get(self, request, categoryId):
    qs = m.Category.objects.filter(id=categoryId)
    serializer = CategoriesSerializer(qs, many=True)
    return Response({"status": True, "data": serializer.data})

class AddCategoryAPIView(APIView):
  permission_classes = [permissions.AllowAny] #[permissions.IsAuthenticated]
  def post(self, request):
    serializer = AddCategoriesSerializer(data=request.data)
    if not serializer.is_valid(): return Response({"status": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
    category = m.Category.objects.create(name=serializer.name)
    return Response({"status": True, "message": "Category created successfully.", "category_id": category.id}, status=status.HTTP_201_CREATED)

class DeleteCategoryAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  def delete(self, request, productId):
    qs = m.Category.objects.filter(id=productId)
    if not qs.exists():
      return Response({"status": False, "message": f"Product with id '{productId}' isn't exists!"}, status=404)
    productName = qs.first().name
    qs.delete()
    return Response({"status": True, "message": f"Product '{productName}' has been deleted."})

class EditCategoryAPIView(APIView):
  permission_classes = [permissions.AllowAny]
  def patch(self, request, productId):
    product = m.Products.objects.filter(id=productId).first()
    if not product: return Response({"status": False, "message": f"Product with id '{productId}' doesn't exist!"}, status=404)
    updated, notFound = {}, []
    ALLOWED_FIELDS = ["name", "barcode", "category", "discription", "buy_price", "sell_price", "quantity", "min_quantity", "active", "monitor"]
    for key, value in request.data.items():
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

