import requests

url = "http://127.0.0.1:8000/auth/login/"

us = {
  "username": "MidoGhanam",
  "password": "Moh@2009@",
}
u = requests.post(url, us)

print(u.text)
