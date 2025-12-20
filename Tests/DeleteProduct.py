import requests

url = "http://127.0.0.1:8000/products/delete/6834d4ba-336e-4d6a-9553-0e260a13b3eb/"

u = requests.get(url, headers={"Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY2MjMxODY2LCJpYXQiOjE3NjYyMzE1NjYsImp0aSI6ImQ3OWZmMzUzNWJhYzRlMzM5ZjA4NDljY2FmNDJhOTE4IiwidXNlcl9pZCI6ImU2MDdlYmQ5LWExYTEtNGFhNi05YjY5LTQxYjRjYzg1N2I0OCJ9.y68fcKHuIjxZ75juctnTSlm-DlXCo4xONp_bPs6iylI"})

print(u.text)