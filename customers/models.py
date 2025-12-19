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
  def __str__(self): return f"Customer: {self.name}"