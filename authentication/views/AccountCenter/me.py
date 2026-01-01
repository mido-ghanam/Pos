from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from authentication.serializers import UserSerializer

class MeAPIView(APIView):
  permission_classes = (permissions.IsAuthenticated,)
  def get(self, request): return Response({"status": True, "user": UserSerializer(request.user).data})
