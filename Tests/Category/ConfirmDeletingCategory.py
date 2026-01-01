import requests

Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY3MTk4Njg2LCJpYXQiOjE3NjcxNzcwODYsImp0aSI6IjY4OGRhYmJhM2I0ODQ2ZGJiMGYzNDFhYTcyYzI2OWI0IiwidXNlcl9pZCI6ImY0ZWJkNmYyLTVjYTktNDlhNy04ZWJjLWNmZDZlNmM3Mzg3MiJ9.WAgMJhT5x2h8WWm3WDT-PZSMeTJ9ZI3uyyM0d-O1GlI"

url = f"http://127.0.0.1:8000/products/categories/delete/confirm/"

us = {
  "otp": 474638,
}

u = requests.post(url, headers={"Authorization": f"Bearer {Token}"}, json=us)
    
print(u.text)
