from rest_framework_simplejwt.tokens import RefreshToken
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.conf import settings

def getUserTokens(user):
  refresh = RefreshToken.for_user(user)
  return {"refresh": str(refresh), "access": str(refresh.access_token)}

def send_email(subject, receiver_email, from_email, from_name, reply_to=None, context={}, html_page_path=None):
  html_content = render_to_string(html_page_path, context)
  email = EmailMultiAlternatives(subject=subject, body=html_content, from_email=f"{from_name} <{from_email}>", to=[receiver_email], reply_to=[reply_to or from_email],)
  email.attach_alternative(html_content, "text/html")
  email.send()
