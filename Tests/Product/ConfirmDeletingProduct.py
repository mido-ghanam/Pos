import requests

Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY3MTkzNzkzLCJpYXQiOjE3NjcxNzIxOTMsImp0aSI6ImNmYWI3ZDk0NmE5NzRiN2E5ODJmMThkMTNhNmJiYzJmIiwidXNlcl9pZCI6ImY0ZWJkNmYyLTVjYTktNDlhNy04ZWJjLWNmZDZlNmM3Mzg3MiJ9.1ygBC3Na_-dQW6NYop7Mm27dsav-f3b8zXPtmPVGYw4"

url = f"http://127.0.0.1:8000/products/delete/confirm/"

us = {
  "otp": 894179,
}

u = requests.post(url, headers={"Authorization": f"Bearer {Token}"}, json=us)
    
print(u.text)
