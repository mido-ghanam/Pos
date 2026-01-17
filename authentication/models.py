from django.contrib.auth.models import AbstractUser
from django.utils import timezone
from django.db import models
import uuid

class Users(AbstractUser):
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
  phone = models.CharField(max_length=30, unique=True)
  created_at = models.DateTimeField(auto_now_add=True)
  def __str__(self): return self.username

import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone
from datetime import timedelta

class ForgotPasswordRequests(models.Model):
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
  user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,related_name='forgot_password_requests')
  token_hash = models.CharField(max_length=128, unique=True)
  is_used = models.BooleanField(default=False)
  ip_address = models.GenericIPAddressField(null=True, blank=True)
  user_agent = models.TextField(null=True, blank=True)
  expires_at = models.DateTimeField()
  created_at = models.DateTimeField(auto_now_add=True)
  class Meta: indexes = [models.Index(fields=['user']), models.Index(fields=['token_hash']), models.Index(fields=['expires_at']),]
  def is_valid(self): return (not self.is_used) and timezone.now() < self.expires_at
  