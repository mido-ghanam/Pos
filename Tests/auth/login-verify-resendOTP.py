import requests

url = "http://127.0.0.1:8000/auth/login/verify/resendOTP/"

us = {
  "username": "demo",
}
u = requests.post(url, us)

print(u.text)
