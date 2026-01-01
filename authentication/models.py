from django.contrib.auth.models import AbstractUser
from django.utils import timezone
from django.db import models
import uuid

class Users(AbstractUser):
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
  phone = models.CharField(max_length=30, unique=True)
  verified = models.BooleanField(default=False)
  created_at = models.DateTimeField(auto_now_add=True)
  def __str__(self): return self.username
