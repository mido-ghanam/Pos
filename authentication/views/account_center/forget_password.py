from ...serializers import ForgoutPasswordRequest
from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

class ChangePasswordAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    serializer = ForgoutPasswordRequest(data=request.data)
    serializer.is_valid(raise_exception=True)
    email = serializer.validated_data["email"]
