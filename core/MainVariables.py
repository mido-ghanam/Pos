import requests
import logging
import json
from pywa import WhatsApp

logger = logging.getLogger(__name__)

MetaDevs = {
  "access": "EAAhBeoJ9U7cBQSGXhT7TqYOgsGt2OqtZA0iVWr6uV2iZCZAn2iWnrve5glBZA2Rl5OLWVcP4EwHbVrgPzT4R0Hq2mhTsExWFuODQP9z8OU7Hj2UafmZBLnPDX14xUdkKjRDKFZC70xNXCprcGpzZBlFJjCT9kvMcaErluXrzBGzBR12d8IDuKg6SGZBAtTDu",
  "messageAPI": "https://graph.facebook.com/v22.0/918394781357288/messages",
}

wa = WhatsApp(token=MetaDevs.get("access", ""), phone_id="918394781357288")

def send_meta_message(to, message):
    """
    دالة لإرسال رسالة واتساب باستخدام Meta Graph API
    """
    try:
        # تنسيق رقم الهاتف بدون +
        phone = str(to).replace("+", "").strip()
        
        logger.info(f"📨 Attempting to send message to {phone} via Meta API")
        
        headers = {
            "Authorization": f"Bearer {MetaDevs['access']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": phone,
            "type": "text",
            "text": {
                "body": message
            }
        }
        
        logger.debug(f"📦 Sending to phone: {phone}")
        
        response = requests.post(
            MetaDevs["messageAPI"],
            headers=headers,
            json=payload,
            timeout=10
        )
        
        logger.info(f"📡 API Response Status: {response.status_code}")
        logger.debug(f"📡 API Response: {response.text}")
        
        if response.status_code in [200, 201]:
            logger.info(f"✅ Message sent successfully to {phone}")
            return True
        else:
            logger.error(f"❌ Failed to send message to {phone}. Status: {response.status_code}, Response: {response.text}")
            return False
            
    except Exception as e:
        logger.error(f"❌ Exception sending message to {to}: {str(e)}", exc_info=True)
        return False
