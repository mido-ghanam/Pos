from django.db import models
from django.contrib.auth import get_user_model

Users = get_user_model()

class Store(models.Model):
	STORE_PHARMACY = 'pharmacy'
	STORE_RESTAURANT = 'restaurant'
	STORE_OTHER = 'other'
	STORE_TYPES = (("supermarket", 'Supermarket'),
		(STORE_PHARMACY, 'Pharmacy'),
		(STORE_RESTAURANT, 'Restaurant'),
		(STORE_OTHER, 'Other'),
	)

	name = models.CharField(max_length=255)
	type = models.CharField(max_length=50, choices=STORE_TYPES, default=STORE_OTHER)
	owner = models.ForeigenKey(Users, on_delete=models.CASCAD)
	address = models.TextField(blank=True)
	created_at = models.DateTimeField(auto_now_add=True)

	class Meta: ordering = ('-created_at',)
	def __str__(self): return f"{self.name} ({self.get_type_display()})"
