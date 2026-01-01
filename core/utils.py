from rest_framework_simplejwt.tokens import RefreshToken
#from django.utils.translation import gettext as _
from pywa.listeners import ListenerTimeout
import random, requests, json, threading
from .MainVariables import MetaDevs, wa
from pywa.types import Button
from .pywa import OTPCode

def generate_code(length=8): return ''.join(str(random.randint(0, 9)) for _ in range(length))

def getUserTokens(user):
  refresh = RefreshToken.for_user(user)
  return {"refresh": str(refresh), "access": str(refresh.access_token)}

def text_message(to, msg):
  try:
    return send_meta_message(to, msg)
  except Exception:
    return wa.send_message(to=str(to).replace("+", ""), text=msg)

def otp(to, full_name, code, otp_type, lang="en"):
  msg = f"""{otp_type.replace('_', '').capitalize()} Verification Code
Hello {full_name}!\n
Your verification code is: *{code}*\n
This code will expire in 5 minutes.
Please do not share this code with anyone."""
  return wa.send_message(to=str(to).replace("+", ""), text=msg, buttons=[Button(title=code, callback_data=OTPCode(code=code))])

def send_whatsapp_in_background(to, full_name=None, code=None, msg=None, template="text_message"):
  if template == "text_message": fun, args = text_message, (to, msg)
  elif template.startswith("otp_"): fun, args = otp, (to, full_name, code, template.replace("otp_", ""))
  threading.Thread(target=fun, args=args).start()