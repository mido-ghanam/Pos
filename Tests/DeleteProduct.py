import requests

url = "http://127.0.0.1:8000/products/delete/98e1f2cd-947f-4aa8-ac17-6fe143ff7318/"

u = requests.get(url, headers={"Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY2MjMxODY2LCJpYXQiOjE3NjYyMzE1NjYsImp0aSI6ImQ3OWZmMzUzNWJhYzRlMzM5ZjA4NDljY2FmNDJhOTE4IiwidXNlcl9pZCI6ImU2MDdlYmQ5LWExYTEtNGFhNi05YjY5LTQxYjRjYzg1N2I0OCJ9.y68fcKHuIjxZ75juctnTSlm-DlXCo4xONp_bPs6iylI"})

print(u.text)