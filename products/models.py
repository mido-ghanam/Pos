from django.db import models

class Category(models.Model): 
  name = models.TextField()

  def __str__(self): return f"Category: {self.name}"

class Products(models.Model):
  name = models.TextField()
  barcode = models.NumberFields()
  category = models.ForeigenKey(Category, on_delete=models.CASCAD)
  discription = models.TextField(blank=True, null=True)
  buy_price = models.FloatField()
  sell_price models.FloatField()
  quantity = models.FloatField(default=0)
  min_quantity = models.FloatField(default=0)
  active = models.BooleanField(default=True)
  monitor = models.BooleanField(default=False)
  
  def __str__(self): return f"Product: {self.name} - Remain quantity: {self.quantity}"
