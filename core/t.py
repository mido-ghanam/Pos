import requests

APP_ID = "2323794244752311"
APP_SECRET = "010d8911221807e47ea648f37bd29eb0"
TEMP_TOKEN = "EAAhBeoJ9U7cBQTRHIGy5ID5Q2TiQmsO22upLY5rgK4ZAVomi5L4xuzgHeOHUATO3ymf19ZCmDu8B1yJXiiZAc0jvQAJhuVhhSRTT3JMS26VfbjSFpZCmdpeXOATodJJ8LDMXLMxtH9Dhtr3gHreuMHLmpA5ZARvtBkZAQNlnVfBvx6LFo6ZCO0skoMvxrY8HlyS5iaWRDWg2JEXbZA3PL7Nm1H7TdVpS3tUi2qbfdQwDn9CKy5OaQgZDZD"

url = (
  f"https://graph.facebook.com/v22.0/oauth/access_token?"
  f"grant_type=fb_exchange_token&"
  f"client_id={APP_ID}&"
  f"client_secret={APP_SECRET}&"
  f"fb_exchange_token={TEMP_TOKEN}"
)

try:
  response = requests.get(url, timeout=10)
  response.raise_for_status()  # يرفع خطأ لو حصل خطأ في الطلب
  data = response.json()

  if "access_token" in data:
    long_token = data["access_token"]
    print("✅ تم الحصول على توكن طويل الأمد:")
    print(long_token)
  else:
    print("❌ فشل الحصول على توكن طويل الأمد:")
    print(data)

except requests.exceptions.RequestException as e:
  print("❌ حدث خطأ أثناء الاتصال بـ Facebook API:")
  print(e)
