from django.db import models

class Customers(models.Model):
  name = models.TextField()
  phone = models.CharField(max_length=30, blank=True, null=True)
  address = models.TextField(blank=True, null=True)
  blocked = models.BooleanField(default=False)
  vip = models.BooleanField(default=False)
  notes = models.TextField(blank=True, null=True)
