import requests

url = "http://127.0.0.1:8000/auth/me/"

Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY3MDUwOTIxLCJpYXQiOjE3NjcwMjkzMjEsImp0aSI6IjVhN2IyZjQ4YzU4ODRkZDZhM2YwM2RiMzY1Y2M3NGJiIiwidXNlcl9pZCI6ImQ3ZjIxYmU0LWM1ZWItNGQxYi04ZTI2LTViMzEyOGI3ZmU4OSJ9.PLJfGy51v-aAYYLWJVMQEG27uEZHg-ELz7LnAAeTcus"

u = requests.get(url, headers={"Authorization": f"Bearer {Token}"})

print(u.text)