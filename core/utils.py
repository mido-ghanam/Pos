from rest_framework_simplejwt.tokens import RefreshToken
import random

def generate_code(length=8): return ''.join(str(random.randint(0, 9)) for _ in range(length))

def getUserTokens(user):
  refresh = RefreshToken.for_user(user)
  return {"refresh": str(refresh), "access": str(refresh.access_token)}
