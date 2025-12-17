from .serializers import UserSerializer, RegisterSerializer, LoginSerializer, ChangePasswordSerializer
from rest_framework.authtoken.models import Token
from rest_framework import status, permissions
from django.contrib.auth import get_user_model
from django.contrib.auth import authenticate
from rest_framework.response import Response
from rest_framework.views import APIView

User = get_user_model()


class RegisterAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    serializer = RegisterSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.save()
    return Response({"status": True, "message": "User Created Successfully"}, status=status.HTTP_201_CREATED)

class LoginAPIView(APIView):
  permission_classes = (permissions.AllowAny,)
  def post(self, request):
    serializer = LoginSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    username, password = serializer.validated_data['username'], serializer.validated_data['password']
    user = authenticate(request, username=username, password=password)
    if not user: return Response({"status": False, 'error': 'Invalid credentials', "message": "Try checking your e-mail or password"}, status=status.HTTP_401_UNAUTHORIZED)
    token, _ = Token.objects.get_or_create(user=user)
    data = UserSerializer(user).data
    data['token'] = str(token)
    res = {
      "status": True,
      "data": "",
      "tokens": data['token'],
      "message": "Logged in successfully!"
    }
    return Response(res)


class LogoutAPIView(APIView):
  permission_classes = (permissions.IsAuthenticated,)
  def post(self, request):
    Token.objects.filter(user=request.user).delete()
    return Response(status=status.HTTP_204_NO_CONTENT)

class MeAPIView(APIView):
  permission_classes = (permissions.IsAuthenticated,)
  def get(self, request): return Response({"status": True, "user": UserSerializer(request.user).data})
  def put(self, request):
    serializer = UserSerializer(request.user, data=request.data)
    serializer.is_valid(raise_exception=True)
    serializer.save()
    return Response({"status": True, "user": serializer.data})

class ChangePasswordAPIView(APIView):
  permission_classes = (permissions.IsAuthenticated,)
  def post(self, request):
    serializer = ChangePasswordSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = request.user
    if not user.check_password(serializer.validated_data['old_password']): return Response({'old_password': 'Wrong password.'}, status=status.HTTP_400_BAD_REQUEST)
    user.set_password(serializer.validated_data['new_password'])
    user.save()
    Token.objects.filter(user=user).delete()
    token = Token.objects.create(user=user)
    return Response({'token': token.key})

