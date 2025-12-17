from django.contrib.auth.models import AbstractUser
from django.db import models

class Users(AbstractUser):
  phone = models.CharField(max_length=30, blank=True, null=True)
  #role = 
  def __str__(self): return self.username
