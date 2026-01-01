import requests

Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY3MTkzNzkzLCJpYXQiOjE3NjcxNzIxOTMsImp0aSI6ImNmYWI3ZDk0NmE5NzRiN2E5ODJmMThkMTNhNmJiYzJmIiwidXNlcl9pZCI6ImY0ZWJkNmYyLTVjYTktNDlhNy04ZWJjLWNmZDZlNmM3Mzg3MiJ9.1ygBC3Na_-dQW6NYop7Mm27dsav-f3b8zXPtmPVGYw4"

productId = "9a258bea-d0d1-4afa-bc13-01f429d1dba8"

url = f"http://127.0.0.1:8000/products/delete/?productId={productId}"

u = requests.delete(url, headers={"Authorization": f"Bearer {Token}"})

print(u.text)