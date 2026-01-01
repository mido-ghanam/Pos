#!/usr/bin/env python
"""
اختبار إرسال الواتس مع تفاصيل أكثر
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pos.settings')
django.setup()

from core.MainVariables import MetaDevs
import requests

phone = "201122716875"
print("=" * 70)
print("🔍 فحص بيانات Meta")
print("=" * 70)
print(f"Phone ID: {MetaDevs.get('phone_id', 'N/A')}")
print(f"API URL: {MetaDevs['messageAPI']}")
print(f"Access Token: {MetaDevs['access'][:50]}...")
print(f"\nرقم الهاتف للاختبار: {phone}")

# اختبار صيغ مختلفة من أرقام الهاتف
phone_formats = [
    "201122716875",      # الصيغة الحالية
    "+201122716875",     # مع +
    "1122716875",        # بدون 20
    "20 1122716875",     # مع مسافة
]

print("\n" + "=" * 70)
print("📞 اختبار صيغ مختلفة من رقم الهاتف")
print("=" * 70)

for phone_format in phone_formats:
    print(f"\n🔹 صيغة: {phone_format}")
    
    headers = {
        "Authorization": f"Bearer {MetaDevs['access']}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": phone_format.replace("+", "").replace(" ", ""),
        "type": "text",
        "text": {
            "body": f"اختبار - صيغة: {phone_format}"
        }
    }
    
    try:
        response = requests.post(
            MetaDevs["messageAPI"],
            headers=headers,
            json=payload,
            timeout=10
        )
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code in [200, 201]:
            print(f"   ✅ نجحت!")
            resp_data = response.json()
            if 'messages' in resp_data and resp_data['messages']:
                print(f"   Message ID: {resp_data['messages'][0]['id']}")
        else:
            print(f"   ❌ فشلت")
            print(f"   Response: {response.text[:200]}")
            
    except Exception as e:
        print(f"   ❌ خطأ: {str(e)}")

print("\n" + "=" * 70)
print("💡 نصائح مهمة:")
print("=" * 70)
print("""
1. تأكد من أن الرقم مسجل في حساب Meta/WhatsApp:
   - اذهب إلى: https://developers.facebook.com/
   - اختر تطبيقك
   - اذهب إلى WhatsApp > Configuration
   - تأكد من أن الرقم موجود في "Phone Number ID"

2. تحقق من أن الرقم يبدأ ب:
   - 20 للأرقام المصرية (الصحيح)
   - أو بدون + في البداية

3. تأكد من أن حسابك في وضع الاختبار (Test Mode)
   - اذهب إلى App Roles > Test Users
   - أضف رقم الهاتف الذي تختبر معه

4. قد تحتاج إلى استخدام Webhook لتلقي الرسائل الواردة
""")
