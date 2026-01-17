from rest_framework_simplejwt.tokens import RefreshToken
import random, requests, json, threading

def getUserTokens(user):
  refresh = RefreshToken.for_user(user)
  return {"refresh": str(refresh), "access": str(refresh.access_token)}
