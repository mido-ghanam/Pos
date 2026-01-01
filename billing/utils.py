import threading
from core import utils  # WhatsApp integration

def send_invoice_whatsapp(phone, invoice_type, partner_name, total, items):
    def _send():
        try:
            formatted_phone = ''.join(filter(str.isdigit, phone))
            if not formatted_phone.startswith("2"):
                formatted_phone = "2" + formatted_phone

            text_items = "\n".join([f"{item['product_name']} x{item['quantity']} = {item['subtotal']}" for item in items])
            msg = f"{invoice_type} Invoice\nHello {partner_name}!\n\nItems:\n{text_items}\n\nTotal: {total}\nThank you!"
            utils.wa.send_message(to=formatted_phone, text=msg)
        except Exception as e:
            print("WhatsApp sending failed:", e)

    threading.Thread(target=_send).start()
