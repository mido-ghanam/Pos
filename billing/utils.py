import threading
from core import utils  # WhatsApp integration

def send_invoice_whatsapp(phone, invoice_type, partner_name, total, items):
    import threading
    from datetime import datetime

    def _send():
        try:
            # تنسيق رقم الهاتف
            formatted_phone = ''.join(filter(str.isdigit, phone))
            if not formatted_phone.startswith("2"):
                formatted_phone = "2" + formatted_phone

            # تجهيز تفاصيل كل منتج
            text_items = "\n".join([
                f"• {item['product_name']} x {item['quantity']} = {item['subtotal']} EGP"
                for item in items
            ])

            # التاريخ الحالي
            date_str = datetime.now().strftime("%d-%m-%Y")

            # نص الرسالة النهائي
            msg = (
                f"🛒 Welcome to pos team \n"
                f"Hello {partner_name} 👋\n"
                f"We are pleased to inform you that your purchase has been successfully completed.\n\n"
                f"Thank you for visiting our store! We're always happy to serve you \n\n"
                f" Invoice Details:\n"
                f"--------------------------------\n"
                f"{text_items}\n"
                f"--------------------------------\n"
                f" Total: {total} EGP\n\n"
                f" Invoice Type: {invoice_type}\n"
                f" Date: {date_str}\n\n"
                f" Thank you for choosing us.\n"
                f"We truly appreciate your trust and look forward to serving you again.\n\n"

                f"Best regards,\n"
                f"Nexor Pos system\n\n"
                f"We hope to see you again soon 🌸"
            )

            # إرسال الرسالة
            utils.wa.send_message(to=formatted_phone, text=msg)
        except Exception as e:
            print("WhatsApp sending failed:", e)

    threading.Thread(target=_send).start()
