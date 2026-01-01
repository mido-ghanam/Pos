from ..serializers import CategoriesSerializer, AddCategoriesSerializer
from rest_framework import status, permissions
from rest_framework.parsers import JSONParser
from rest_framework.response import Response
from rest_framework.views import APIView
from core import utils, models as core_m
import uuid, random, threading
from .. import models as m

temp = {
  "whatsapp": {}
}

def add_otp_to_temp(otp, categoryId, userId):
  if "whatsapp" not in temp: temp["whatsapp"] = {}
  temp["whatsapp"][otp] = {"categoryId": categoryId, "userId": userId}

class AllCategoriesAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  parser_classes = [JSONParser]
  def get(self, request):
    qs = m.Category.objects.all()
    serializer = CategoriesSerializer(qs, many=True)
    return Response({"status": True, "data": serializer.data})

class GetCategoryAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  parser_classes = [JSONParser]
  def get(self, request):
    categoryId = request.GET.get("categoryId", "")
    if not categoryId: return Response({"status": True, "message": "Get field 'categoryId' is messing.", "error": "Get Field is messing"}, status=400)
    try: uuid.UUID(str(categoryId))
    except ValueError: return Response({"status": False, "message": "Invalid category id"}, status=400)
    qs = m.Category.objects.filter(id=categoryId)
    serializer = CategoriesSerializer(qs, many=True)
    return Response({"status": True, "data": serializer.data})

class AddCategoryAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  def post(self, request):
    serializer = AddCategoriesSerializer(data=request.data)
    if not serializer.is_valid(): return Response({"status": False, "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
    category = m.Category.objects.create(name=serializer.validated_data['name'])
    return Response({"status": True, "message": "Category created successfully.", "category_id": category.id}, status=status.HTTP_201_CREATED)

class DeleteCategoryAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  def delete(self, request):
    categoryId = request.GET.get("categoryId", "")
    if not categoryId: return Response({"status": True, "message": "Get field 'categoryId' is messing.", "error": "Get Field is messing"}, status=400)
    user, otp = request.user, str(random.randint(100000, 999999))
    core_m.OTPs.objects.create(user=user, code=otp, otp_type="category_delete")
    utils.send_whatsapp_in_background(to=user.phone, full_name=user.get_full_name(), code=otp, template=f"otp_category delete")
    threading.Thread(target=add_otp_to_temp, args=(otp, categoryId, user.id)).start()
    return Response({"status": True, "message": f"OTP sent!"})

class ConfirmDeleteCategoryAPIView(APIView):
  permission_classes = [permissions.IsAuthenticated]
  def post(self, request):
    otp = str(request.data.get("otp"))
    otp_obj = core_m.OTPs.objects.filter(user=request.user, code=otp, otp_type="category_delete", is_used=False).first()
    if not otp_obj or otp_obj.is_expired(): return Response({"status": False, "message": "Invalid or expired OTP"}, status=400)
    otp_obj.is_used = True
    otp_obj.save()
    otp_obj = temp["whatsapp"].get(otp, {})
    if not otp_obj: return Response({"status": False, "message": "Error at getting OTP details"}, status=400)
    if str(request.user.id) != str(otp_obj.get("userId", "")): return Response({"status": False, "message": "Not Authorized"}, status=400) 
    categoryId = otp_obj.get("categoryId", "")
    try: uuid.UUID(str(categoryId))
    except ValueError: return Response({"status": False, "message": "Invalid category id"}, status=400)
    qs = m.Category.objects.filter(id=categoryId)
    if not qs.exists(): return Response({"status": False, "message": f"Category with id '{categoryId}' isn't exists!"}, status=404)
    categoryName = qs.first().name
    qs.delete()
    return Response({"status": True, "message": f"Category '{categoryName}' has been deleted."})

class EditCategoryAPIView(APIView):
  permission_classes = [permissions.AllowAny]
  def patch(self, request):
    categoryId = request.GET.get("categoryId", "")
    if not categoryId: return Response({"status": True, "message": "Get field 'categoryId' is messing.", "error": "Get Field is messing"}, status=400)
    try: uuid.UUID(str(categoryId))
    except ValueError: return Response({"status": False, "message": "Invalid category id"}, status=400)
    category = m.Category.objects.filter(id=categoryId).first()
    if not category: return Response({"status": False, "message": f"Category with id '{categoryId}' doesn't exist!"}, status=404)
    updated, notFound = {}, []
    ALLOWED_FIELDS = ["name"]
    for key, value in request.data.items():
      if key not in ALLOWED_FIELDS:
        notFound.append(key)
        continue
      before = getattr(category, key)
      setattr(category, key, value)
      updated[key] = {"before": before, "after": value}
    category.save()
    return Response({"status": True, "message": "Category updated successfully!", "updated": updated, "notFound": notFound})
