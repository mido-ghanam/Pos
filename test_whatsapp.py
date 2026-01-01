#!/usr/bin/env python
"""
اختبار إرسال رسائل الواتس
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pos.settings')
django.setup()

from core.MainVariables import send_meta_message, wa
from core.utils import otp, text_message, send_whatsapp_in_background
import logging

# تفعيل logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

print("=" * 60)
print("🧪 اختبار إرسال الواتس")
print("=" * 60)

phone = "201122716875"
name = "رانيا احمد"
code = "123456"

print(f"\n📱 رقم الهاتف: {phone}")
print(f"👤 الاسم: {name}")
print(f"🔐 الكود: {code}")

# اختبار 1: send_meta_message مباشرة
print("\n" + "=" * 60)
print("✅ اختبار 1: send_meta_message")
print("=" * 60)
result = send_meta_message(phone, f"رسالة اختبار للرقم {phone}")
print(f"النتيجة: {result}\n")

# اختبار 2: otp function
print("=" * 60)
print("✅ اختبار 2: otp function")
print("=" * 60)
result = otp(phone, name, code, "registration")
print(f"النتيجة: {result}\n")

# اختبار 3: text_message function
print("=" * 60)
print("✅ اختبار 3: text_message function")
print("=" * 60)
result = text_message(phone, "رسالة اختبار من text_message")
print(f"النتيجة: {result}\n")

# اختبار 4: send_whatsapp_in_background مع OTP
print("=" * 60)
print("✅ اختبار 4: send_whatsapp_in_background")
print("=" * 60)
send_whatsapp_in_background(phone, name, code, template="otp_registration")
print("تم استدعاء الدالة\n")

print("=" * 60)
print("✅ انتهى الاختبار")
print("=" * 60)
