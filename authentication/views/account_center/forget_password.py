from ...serializers import ForgoutPasswordRequest
from django.contrib.auth import get_user_model
from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

User = get_user_model()

class ForgotPasswordAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    serializer = ForgoutPasswordRequest(data=request.data)
    serializer.is_valid(raise_exception=True)
    email = serializer.validated_data["email"]
    user = User.objects.filter(email=email).first()
    if not user: return Response({"status": False, "error": f"Email: {email} isn't exists'" })
    
