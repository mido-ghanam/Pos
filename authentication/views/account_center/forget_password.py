from core.utils import generate_secure_token, send_email
from ...serializers import ForgoutPasswordRequest
from django.contrib.auth import get_user_model
from rest_framework import status, permissions
from rest_framework.response import Response
from ...models import ForgotPasswordRequests
from rest_framework.views import APIView
from django.utils import timezone
from datetime import timedelta

User = get_user_model()

class ForgotPasswordAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    serializer = ForgoutPasswordRequest(data=request.data)
    serializer.is_valid(raise_exception=True)
    email = serializer.validated_data["email"]
    user = User.objects.filter(email=email).first()
    if not user: return Response({"status": False, "error": f"Email: {email} isn't exists" })
    ForgotPasswordRequests.objects.filter(user=user).delete()
    token, token_hash = generate_secure_token()
    ForgotPasswordRequests.objects.create(user=user, token_hash=token_hash, expires_at=timezone.now() + timedelta(hours=1))
    ## Sending E-mail to user
    
    return Response({"status": True, "message": "Password reset request sent successfully" })
