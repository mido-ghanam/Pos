from django.contrib.auth.models import AbstractUser
from authentication.models import Users
from django.utils import timezone
from django.db import models
import uuid

class OTPs(models.Model):
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
  OTP_CHOICES = (("login", "Login"),("register", "Register"), ("change_password", "Change Password"),)
  user = models.ForeignKey(Users, on_delete=models.CASCADE, related_name="otps")
  code = models.CharField(max_length=6)
  otp_type = models.CharField(max_length=20, choices=OTP_CHOICES)
  created_at = models.DateTimeField(auto_now_add=True)
  is_used = models.BooleanField(default=False)
  attempts = models.PositiveSmallIntegerField(default=0)
  class Meta: ordering = ["-created_at"]
  def is_expired(self): return (timezone.now() - self.created_at).total_seconds() > 300
  def increase_attempts(self):
    self.attempts += 1
    self.save(update_fields=["attempts"])
