import requests

Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY2NzE1NTY0LCJpYXQiOjE3NjY2OTM5NjQsImp0aSI6Ijk3ZWNhNzZlMmZjYjRjZDBhMzJlMjdmYjk2NDNjMzIyIiwidXNlcl9pZCI6ImU2MDdlYmQ5LWExYTEtNGFhNi05YjY5LTQxYjRjYzg1N2I0OCJ9.rg2I1ThZMePBaYcevQ15GRdSWcYeUwsY49KUlTp3urw"

productId = "c4c55bb8-1a22-4be7-bcbf-ae4600f8b88f"

url = f"http://127.0.0.1:8000/products/get/?productId={productId}"

u = requests.get(url, headers={"Authorization": f"Bearer {Token}"})

print(u.text)
