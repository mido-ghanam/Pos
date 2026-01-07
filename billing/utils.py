import threading
from core.MainVariables import wa  # WhatsApp integration
from datetime import datetime
import requests
from io import BytesIO
import logging

logger = logging.getLogger(__name__)

def send_invoice_whatsapp(phone, invoice_type, partner_name, total, items, 
                         invoice_id=None, paid_amount=None, remaining_amount=None, 
                         payment_status=None, return_amount=None, original_invoice_id=None):
    """
    Send WhatsApp message with invoice details in English
    Includes professional invoice image
    """
    def _send():
        try:
            # Format phone number
            formatted_phone = ''.join(filter(str.isdigit, phone))
            if not formatted_phone.startswith("2"):
                formatted_phone = "2" + formatted_phone

            # Prepare items details with professional formatting
            items_text = ""
            for item in items:
                items_text += f"Item: {item['product_name']}\n"
                items_text += f"Quantity: {item['quantity']}\n"
                items_text += f"Price: USD {item['subtotal']:.2f}\n\n"

            # Current date
            date_str = datetime.now().strftime("%d-%m-%Y %H:%M")
            separator = "━━━━━━━━━━━━━━━━━━━━━━"

            # Return message
            if "return" in invoice_type.lower():
                msg = (
                    f"RETURN NOTIFICATION\n"
                    f"{separator}\n\n"
                    f"Dear {partner_name},\n\n"
                    f"We are writing to confirm that the following items have been\n"
                    f"successfully returned and processed in our system. Your account\n"
                    f"has been credited with the return amount.\n\n"
                    f"{separator}\n"
                    f"RETURNED ITEMS\n"
                    f"{separator}\n"
                    f"{items_text}\n"
                    f"{separator}\n"
                    f"RETURN SUMMARY\n"
                    f"{separator}\n"
                    f"Total Return Amount: USD {return_amount:.2f}\n"
                )
                if original_invoice_id:
                    msg += f"Original Invoice Number: {original_invoice_id}\n"
                msg += (
                    f"\nReturn Date: {date_str}\n"
                    f"Status: PROCESSED\n\n"
                    f"The credit has been applied to your account. You may use this\n"
                    f"credit towards future purchases or request a refund according to\n"
                    f"your preferred payment method.\n\n"
                    f"If you have any questions regarding this return, please contact\n"
                    f"our customer service team.\n\n"
                    f"Thank you for your business.\n\n"
                    f"Best regards,\n"
                    f"NEXOR POS System\n"
                    f"{separator}"
                )
            # Payment status message
            elif paid_amount is not None and payment_status:
                msg = (
                    f"PAYMENT CONFIRMATION & INVOICE UPDATE\n"
                    f"{separator}\n\n"
                    f"Dear {partner_name},\n\n"
                    f"Thank you for your payment. We are pleased to inform you that\n"
                    f"your payment has been successfully received and recorded. Below\n"
                    f"are the updated invoice details for your reference:\n\n"
                    f"{separator}\n"
                    f"INVOICE DETAILS\n"
                    f"{separator}\n"
                    f"{items_text}\n"
                    f"{separator}\n"
                    f"PAYMENT SUMMARY\n"
                    f"{separator}\n"
                    f"Total Invoice Amount: USD {total:.2f}\n"
                    f"Amount Paid: USD {paid_amount:.2f}\n"
                )
                if remaining_amount and remaining_amount > 0:
                    msg += f"Outstanding Balance: USD {remaining_amount:.2f}\n\n"
                    msg += f"{separator}\n"
                    msg += f"NEXT STEPS\n"
                    msg += f"{separator}\n"
                    msg += f"The remaining balance of USD {remaining_amount:.2f} is due on\n"
                    msg += f"the agreed payment date. A reminder notification will be sent\n"
                    msg += f"prior to the due date.\n"
                else:
                    msg += f"\nInvoice Status: FULLY PAID\n\n"
                
                msg += (
                    f"\nPayment Date: {date_str}\n"
                    f"Invoice Number: {invoice_id}\n\n"
                    f"If you have any questions or require further assistance, please\n"
                    f"feel free to contact us.\n\n"
                    f"Thank you for choosing NEXOR POS System.\n"
                    f"We appreciate your trust and look forward to serving you again.\n\n"
                    f"Best regards,\n"
                    f"NEXOR POS System\n"
                    f"{separator}"
                )
            # Main invoice message
            else:
                msg = (
                    f"SALES INVOICE\n"
                    f"{separator}\n\n"
                    f"Dear {partner_name},\n\n"
                    f"Thank you for your business. We are pleased to provide you with\n"
                    f"the following invoice for the goods/services delivered. Please\n"
                    f"review the details carefully to ensure all information is correct.\n\n"
                    f"{separator}\n"
                    f"INVOICE DETAILS\n"
                    f"{separator}\n"
                    f"{items_text}\n"
                    f"{separator}\n"
                    f"INVOICE SUMMARY\n"
                    f"{separator}\n"
                    f"Total Invoice Amount: USD {total:.2f}\n"
                )
                
                # If payment information is available
                if paid_amount is not None and paid_amount > 0 and payment_status:
                    msg += f"Amount Paid: USD {paid_amount:.2f}\n"
                    if remaining_amount and remaining_amount > 0:
                        msg += f"Balance Due: USD {remaining_amount:.2f}\n\n"
                        msg += f"Payment Status: PARTIAL\n"
                        msg += f"This invoice has been partially paid. The remaining balance\n"
                        msg += f"of USD {remaining_amount:.2f} is due on the agreed payment terms.\n"
                    else:
                        msg += f"\nPayment Status: FULLY PAID\n\n"
                else:
                    msg += f"\nPayment Terms: NET 30 DAYS\n"
                    msg += f"Please arrange payment according to the agreed payment terms.\n"
                
                msg += (
                    f"\n{separator}\n"
                    f"PAYMENT INSTRUCTIONS\n"
                    f"{separator}\n"
                    f"Please ensure payment is made by the due date. If you have any\n"
                    f"questions regarding payment methods or terms, please contact us\n"
                    f"immediately.\n\n"
                    f"Invoice Date: {date_str}\n"
                    f"Invoice Number: {invoice_id}\n\n"
                    f"For any inquiries or clarifications about this invoice, please\n"
                    f"reach out to our customer service team.\n\n"
                    f"Thank you for your prompt attention to this matter.\n\n"
                    f"Best regards,\n"
                    f"NEXOR POS System\n"
                    f"{separator}"
                )
            
            # Send message
            print(f"[DEBUG] Attempting to send WhatsApp to {formatted_phone}")
            if wa:
                wa.send_message(to=formatted_phone, text=msg)
                print(f"[SUCCESS] WhatsApp message sent to {formatted_phone}")
                logger.info(f"WhatsApp message sent to {formatted_phone}")
            else:
                print(f"[WARNING] WhatsApp service not configured")
                logger.warning("WhatsApp service not configured - message not sent")
                
        except Exception as e:
            print(f"[ERROR] WhatsApp sending failed: {e}")
            logger.error(f"WhatsApp sending failed: {e}", exc_info=True)

    threading.Thread(target=_send).start()


def send_customer_payment_whatsapp(customer, paid_amount, remaining_balance, payment_details, payment_method):
    """
    Send WhatsApp message for customer account payment
    Shows paid amount and remaining balance
    """
    def _send():
        try:
            if not customer.phone:
                print(f"Customer {customer.name} has no phone number")
                return
                
            formatted_phone = ''.join(filter(str.isdigit, customer.phone))
            if not formatted_phone.startswith("2"):
                formatted_phone = "2" + formatted_phone
            
            date_str = datetime.now().strftime("%d-%m-%Y | %H:%M")
            separator = "━━━━━━━━━━━━━━━━━━━━━━"
            
            # Build invoice list
            invoice_list = ""
            for detail in payment_details:
                invoice_list += f"Invoice #{detail['invoice_id']:8} | Paid: USD {detail['amount_paid']:8.2f} | {detail['status']}\n"
            
            msg = (
                f"PAYMENT RECEIVED & ACCOUNT UPDATE\n"
                f"{separator}\n\n"
                f"Dear {customer.name},\n\n"
                f"Thank you for your prompt payment. We are pleased to confirm that\n"
                f"your payment has been successfully received and applied to your account.\n\n"
                f"{separator}\n"
                f"PAYMENT DETAILS\n"
                f"{separator}\n"
                f"Amount Paid: USD {paid_amount:.2f}\n"
                f"Payment Method: {payment_method}\n"
                f"Transaction Date: {date_str}\n\n"
                f"{separator}\n"
                f"INVOICES UPDATED\n"
                f"{separator}\n"
                f"{invoice_list}\n"
                f"{separator}\n"
                f"ACCOUNT SUMMARY\n"
                f"{separator}\n"
            )
            
            if remaining_balance > 0:
                msg += (
                    f"Current Outstanding Balance: USD {remaining_balance:.2f}\n\n"
                    f"You still have an outstanding balance on your account. We will\n"
                    f"send you a reminder regarding the next payment due date. If you\n"
                    f"would like to settle this balance immediately, please contact our\n"
                    f"billing department.\n"
                )
            else:
                msg += (
                    f"Account Status: FULLY PAID\n\n"
                    f"Congratulations! Your account is now fully settled. All invoices\n"
                    f"have been paid in full. We appreciate your prompt payment and look\n"
                    f"forward to continuing our business relationship.\n"
                )
            
            msg += (
                f"\n{separator}\n"
                f"If you have any questions regarding this payment or your account\n"
                f"balance, please do not hesitate to contact our customer service team.\n"
                f"We are always ready to assist you.\n\n"
                f"Thank you for your business and continued support.\n\n"
                f"Best regards,\n"
                f"NEXOR POS System\n"
                f"{separator}"
            )
            
            # Send message
            wa.send_message(to=formatted_phone, text=msg)
            
        except Exception as e:
            print("WhatsApp customer payment notification failed:", e)
    
    threading.Thread(target=_send).start()


def send_supplier_payment_whatsapp(supplier, paid_amount, remaining_balance, payment_details, payment_method):
    """
    Send WhatsApp message for supplier account payment
    Shows paid amount and remaining balance
    """
    def _send():
        try:
            if not supplier.phone:
                print(f"Supplier {supplier.company_name} has no phone number")
                return
                
            formatted_phone = ''.join(filter(str.isdigit, supplier.phone))
            if not formatted_phone.startswith("2"):
                formatted_phone = "2" + formatted_phone
            
            date_str = datetime.now().strftime("%d-%m-%Y | %H:%M")
            separator = "━━━━━━━━━━━━━━━━━━━━━━"
            
            # Build invoice list
            invoice_list = ""
            for detail in payment_details:
                invoice_list += f"Invoice #{detail['invoice_id']:8} | Paid: USD {detail['amount_paid']:8.2f} | {detail['status']}\n"
            
            msg = (
                f"PAYMENT PROCESSED & ACCOUNT UPDATE\n"
                f"{separator}\n\n"
                f"Dear {supplier.person_name},\n\n"
                f"We are writing to confirm that we have successfully processed your\n"
                f"payment. The payment has been applied to your supplier account and\n"
                f"all relevant invoices have been updated accordingly.\n\n"
                f"{separator}\n"
                f"PAYMENT DETAILS\n"
                f"{separator}\n"
                f"Amount Paid: USD {paid_amount:.2f}\n"
                f"Payment Method: {payment_method}\n"
                f"Processing Date: {date_str}\n\n"
                f"{separator}\n"
                f"INVOICES UPDATED\n"
                f"{separator}\n"
                f"{invoice_list}\n"
                f"{separator}\n"
                f"SUPPLIER ACCOUNT STATUS\n"
                f"{separator}\n"
            )
            
            if remaining_balance > 0:
                msg += (
                    f"Outstanding Balance: USD {remaining_balance:.2f}\n\n"
                    f"You still have an outstanding balance on your account. Please\n"
                    f"ensure that the remaining amount is paid by the agreed due date.\n"
                    f"If you have any questions regarding your account balance or\n"
                    f"payment terms, please contact us as soon as possible.\n"
                )
            else:
                msg += (
                    f"Account Status: FULLY SETTLED\n\n"
                    f"All outstanding invoices have been paid in full. Your account\n"
                    f"with us is now fully settled. We appreciate your prompt payment\n"
                    f"and your continued partnership with our organization.\n"
                )
            
            msg += (
                f"\n{separator}\n"
                f"For any clarifications or if you need further assistance regarding\n"
                f"this payment or your supplier account, please feel free to reach out\n"
                f"to our accounting department. We are always ready to help.\n\n"
                f"Thank you for your business and continued cooperation.\n\n"
                f"Best regards,\n"
                f"NEXOR POS System\n"
                f"{separator}"
            )
            
            # Send message
            wa.send_message(to=formatted_phone, text=msg)
            
        except Exception as e:
            print("WhatsApp supplier payment notification failed:", e)
    
    threading.Thread(target=_send).start()


