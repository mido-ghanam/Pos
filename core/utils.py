from rest_framework_simplejwt.tokens import RefreshToken
#from django.utils.translation import gettext as _
from pywa.listeners import ListenerTimeout
import random, requests, json, threading, logging
from .MainVariables import MetaDevs, wa, send_meta_message
from pywa.types import Button

logger = logging.getLogger(__name__)

def generate_code(length=8): return ''.join(str(random.randint(0, 9)) for _ in range(length))

def getUserTokens(user):
  refresh = RefreshToken.for_user(user)
  return {"refresh": str(refresh), "access": str(refresh.access_token)}

def text_message(to, msg):
  """إرسال رسالة نصية عادية"""
  if not to or not msg:
    logger.warning("Invalid parameters: to or msg is empty")
    return False
  
  logger.info(f"Sending text message to {to}")
  success = send_meta_message(to, msg)
  if not success:
    logger.warning(f"Meta API failed, trying pywa...")
    try:
      phone = str(to).replace("+", "").strip()
      wa.send_message(to=phone, text=msg)
      logger.info(f"✓ Message sent to {to} via pywa")
      return True
    except Exception as e:
      logger.error(f"✗ pywa failed for {to}: {str(e)}", exc_info=True)
      return False
  return True

def otp(to, full_name, code, otp_type, lang="en"):
  """إرسال رسالة OTP مع زر"""
  if not to or not code:
    logger.warning("Invalid parameters: to or code is empty")
    return False
  
  msg = f"""{otp_type.replace('_', '').capitalize()} Verification Code
Hello {full_name}!

Your verification code is: *{code}*

This code will expire in 5 minutes.
Please do not share this code with anyone."""
  
  logger.info(f"Sending OTP to {to} with code: {code}")
  
  try:
    phone = str(to).replace("+", "").strip()
    # محاولة إرسال برسالة نصية عادية أولاً (بدون أزرار)
    success = send_meta_message(to, msg)
    if success:
      logger.info(f"✓ OTP sent successfully to {to}")
      return True
  except Exception as e:
    logger.error(f"✗ Failed to send OTP to {to}: {str(e)}", exc_info=True)
  
  return False

def send_whatsapp_in_background(to, full_name=None, code=None, msg=None, template="text_message"):
  """إرسال رسالة واتس في thread منفصل"""
  try:
    logger.info(f"🔔 send_whatsapp_in_background called with to={to}, template={template}")
    
    if template == "text_message":
      if not msg:
        logger.warning("text_message template requires 'msg' parameter")
        return
      fun, args = text_message, (to, msg)
    elif template.startswith("otp_"):
      if not code:
        logger.warning(f"{template} template requires 'code' parameter")
        return
      otp_type = template.replace("otp_", "")
      fun, args = otp, (to, full_name or "User", code, otp_type)
    else:
      logger.warning(f"Unknown template: {template}")
      return
    
    # تشغيل الدالة مباشرة بدون thread في البداية
    logger.info(f"📤 Starting to send message using {fun.__name__}")
    result = fun(*args)
    logger.info(f"✅ Message function completed with result: {result}")
    
  except Exception as e:
    logger.error(f"❌ Failed in send_whatsapp_in_background: {str(e)}", exc_info=True)
  
