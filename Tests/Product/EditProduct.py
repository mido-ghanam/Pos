import requests

Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY2NzE1NTY0LCJpYXQiOjE3NjY2OTM5NjQsImp0aSI6Ijk3ZWNhNzZlMmZjYjRjZDBhMzJlMjdmYjk2NDNjMzIyIiwidXNlcl9pZCI6ImU2MDdlYmQ5LWExYTEtNGFhNi05YjY5LTQxYjRjYzg1N2I0OCJ9.rg2I1ThZMePBaYcevQ15GRdSWcYeUwsY49KUlTp3urw"

productId = "4dfdc66e-4f04-452b-9c21-7b5878fee6d8"

url = f"http://127.0.0.1:8000/products/edit/?productId={productId}"

us = {
  "name": "Product2",
  "barcode": 9772977297,
  "category": "dbb9cb73-525d-465a-8c69-3aff4761c201",
  "discription": "",
  "buy_price": 78.5,
  "sell_price": 66.8,
  "quantity": 10,
  "min_quantity": 5,
  "active": True,
  "monitor": True,
  
}

u = requests.patch(url, json=us, headers={"Authorization": f"Bearer {Token}"})

print(u.text)
print(u.status_code)
