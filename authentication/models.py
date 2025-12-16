from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
  phone = models.CharField(max_length=30, blank=True, null=True)
  role = models.CharField(max_length=50, blank=True, null=True)
  def __str__(self): return self.username