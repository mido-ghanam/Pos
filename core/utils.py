from rest_framework_simplejwt.tokens import RefreshToken
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.conf import settings
import hashlib, secrets

def getUserTokens(user):
  refresh = RefreshToken.for_user(user)
  return {"refresh": str(refresh), "access": str(refresh.access_token)}

def generate_secure_token(): 
  token = secrets.token_urlsafe(32)
  hashed = hashlib.sha256(token.encode()).hexdigest()
  return token, hashed
