import requests

url = "http://127.0.0.1:8000/auth/register/"

us = {
  "username": "mG",
  "password": "Moh@2009@",
  'email': "test@er.cf",
  'first_name': "mG",
  'last_name': "fg",
  'phone': "+201101023681",
}

u = requests.post(url, us)

print(u.text)
print("\n")
print(u.status_code)