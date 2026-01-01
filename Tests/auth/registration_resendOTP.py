import requests

url = "http://127.0.0.1:8000/auth/register/verify/resendOTP/"

us = {
  "username": "demo2",
}

u = requests.post(url, us)

print(u.text)
print(u.status_code)
