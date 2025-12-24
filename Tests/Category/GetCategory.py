import requests

url = "http://127.0.0.1:8000/products/categories/get/dbb9cb73-525d-465a-8c69-3aff4761c201/"

u = requests.get(url, headers={"Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY2MjMxODY2LCJpYXQiOjE3NjYyMzE1NjYsImp0aSI6ImQ3OWZmMzUzNWJhYzRlMzM5ZjA4NDljY2FmNDJhOTE4IiwidXNlcl9pZCI6ImU2MDdlYmQ5LWExYTEtNGFhNi05YjY5LTQxYjRjYzg1N2I0OCJ9.y68fcKHuIjxZ75juctnTSlm-DlXCo4xONp_bPs6iylI"})

print(u.text)