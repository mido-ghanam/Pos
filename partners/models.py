from django.utils import timezone
from django.db import models
import uuid

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
