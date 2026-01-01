from django.db import models
from django.utils import timezone
import uuid

class OTPVerification(models.Model):
  """Model to store OTP verification data for customers and suppliers"""
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=True)
  phone = models.CharField(max_length=30)
  otp_code = models.CharField(max_length=6)
  is_verified = models.BooleanField(default=False)
  created_at = models.DateTimeField(default=timezone.now)
  expires_at = models.DateTimeField()
  partner_type = models.CharField(max_length=20, choices=[('customer', 'Customer'), ('supplier', 'Supplier')])
  
  # Store registration data temporarily
  temp_data = models.JSONField(default=dict, blank=True)
  
  class Meta:
    ordering = ['-created_at']
  
  def __str__(self): return f"OTP for {self.phone} - {self.partner_type}"
  
  def is_expired(self):
    return timezone.now() > self.expires_at
  
  def is_valid(self, otp):
    return self.otp_code == otp and not self.is_expired() and not self.is_verified


class Customers(models.Model):
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=True)
  name = models.TextField()
  phone = models.CharField(max_length=30, blank=True, null=True)
  address = models.TextField(blank=True, null=True)
  blocked = models.BooleanField(default=False)
  vip = models.BooleanField(default=False)
  notes = models.TextField(blank=True, null=True)
  is_verified = models.BooleanField(default=False)
  created_at = models.DateTimeField(default=timezone.now)
  updated_at = models.DateTimeField(auto_now=True)
  def __str__(self): return f"Customer: {self.name}"


class Suppliers(models.Model):
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=True)
  person_name = models.CharField(max_length=255)
  company_name = models.CharField(max_length=255, blank=True, null=True)
  phone = models.CharField(max_length=30, blank=True, null=True)
  address = models.TextField(blank=True, null=True)
  active = models.BooleanField(default=True)
  notes = models.TextField(blank=True, null=True)
  is_verified = models.BooleanField(default=False)
  created_at = models.DateTimeField(default=timezone.now)
  updated_at = models.DateTimeField(auto_now=True)
  def __str__(self): return f"Supplier: {self.person_name} ({self.company_name})"
