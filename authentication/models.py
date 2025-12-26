from django.contrib.auth.models import AbstractUser
from django.db import models
import uuid

class Users(AbstractUser):
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=True)
  phone = models.CharField(max_length=30, blank=True, null=True)
  def __str__(self): return self.username
