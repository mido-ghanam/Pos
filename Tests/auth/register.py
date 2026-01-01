import requests

url = "http://127.0.0.1:8000/auth/register/"

us = {
  "username": "demo2",
  "password": "demo2@2025@",
  'email': "demo2@ex.co",
  'first_name': "Demo",
  'last_name': "Account",
  'phone': "+201063443856",
}

u = requests.post(url, us)

print(u.text)
print(u.status_code)
