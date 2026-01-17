from django.utils import timezone
from django.db import models
import uuid

class Category(models.Model): 
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=True)
  name = models.TextField()
  updated_at = models.DateTimeField(auto_now=True)
  created_at = models.DateTimeField(default=timezone.now)
  def __str__(self): return f"Category: {self.name}"

class Products(models.Model):
  id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=True)
  name = models.TextField()
  barcode = models.IntegerField()
  large_count = models.FloatField(default=0)
  category = models.ForeignKey(Category, on_delete=models.CASCADE)
  discription = models.TextField(blank=True, null=True)
  buy_price = models.FloatField()
  sell_price = models.FloatField()
  quantity = models.FloatField(default=0)
  min_quantity = models.FloatField(default=0)
  active = models.BooleanField(default=True)
  monitor = models.BooleanField(default=False)
  updated_at = models.DateTimeField(auto_now=True)
  created_at = models.DateTimeField(default=timezone.now)
  def __str__(self): return f"Product: {self.name} - Remain quantity: {self.quantity}"
