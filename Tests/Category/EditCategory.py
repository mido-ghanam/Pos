import requests

Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY2NzE1NTY0LCJpYXQiOjE3NjY2OTM5NjQsImp0aSI6Ijk3ZWNhNzZlMmZjYjRjZDBhMzJlMjdmYjk2NDNjMzIyIiwidXNlcl9pZCI6ImU2MDdlYmQ5LWExYTEtNGFhNi05YjY5LTQxYjRjYzg1N2I0OCJ9.rg2I1ThZMePBaYcevQ15GRdSWcYeUwsY49KUlTp3urw"

categoryId = "09063758-8556-4614-b317-dcd0e3b23d74"

url = f"http://127.0.0.1:8000/products/categories/edit/?categoryId={categoryId}"

us = {
  "name": "Category2",
}

u = requests.patch(url, json=us, headers={"Authorization": f"Bearer {Token}"})

print(u.text)
print(u.status_code)
