import requests

url = "http://127.0.0.1:8000/products/edit/7fbd8863-fca9-4f02-9798-906994db6595/"

us = {
  "name": "Product2",
  "barcode": 9772977297,
  "category": "dbb9cb73-525d-465a-8c69-3aff4761c201",
  #"discription": "",
  "buy_price": 78.5,
  "sell_price": 66.8,
  "quantity": 10,
  "min_quantity": 5,
  "active": True,
  "monitor": True,
  
}

u = requests.patch(url, json=us, headers={"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY2MjMxODY2LCJpYXQiOjE3NjYyMzE1NjYsImp0aSI6ImQ3OWZmMzUzNWJhYzRlMzM5ZjA4NDljY2FmNDJhOTE4IiwidXNlcl9pZCI6ImU2MDdlYmQ5LWExYTEtNGFhNi05YjY5LTQxYjRjYzg1N2I0OCJ9.y68fcKHuIjxZ75juctnTSlm-DlXCo4xONp_bPs6iylI"})

print(u.text)
print(u.status_code)