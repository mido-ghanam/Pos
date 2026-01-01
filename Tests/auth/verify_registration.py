import requests

url = "http://127.0.0.1:8000/auth/register/verify/"

us = {
  "username": "demo",
  "otp": 548721,
}

u = requests.post(url, us)

print(u.text)
print(u.status_code)
