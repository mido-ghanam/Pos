import requests

url = "http://127.0.0.1:8000/auth/login/verify/"

us = {
  "username": "MidoGhanam",
  "otp": 109244,
}
u = requests.post(url, us)

print(u.text)
