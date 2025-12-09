
from django.db import models
from django.contrib.auth.models import AbstractUser


class Store(models.Model):
	"""Represents a store/organization using this POS backend.

	Type examples: supermarket, pharmacy, restaurant, etc.
	"""

	STORE_SUPERMARKET = 'supermarket'
	STORE_PHARMACY = 'pharmacy'
	STORE_RESTAURANT = 'restaurant'
	STORE_OTHER = 'other'

	STORE_TYPES = (
		(STORE_SUPERMARKET, 'Supermarket'),
		(STORE_PHARMACY, 'Pharmacy'),
		(STORE_RESTAURANT, 'Restaurant'),
		(STORE_OTHER, 'Other'),
	)

	name = models.CharField(max_length=255)
	type = models.CharField(max_length=50, choices=STORE_TYPES, default=STORE_OTHER)
	address = models.TextField(blank=True)
	created_at = models.DateTimeField(auto_now_add=True)

	class Meta:
		ordering = ('-created_at',)

	def __str__(self):
		return f"{self.name} ({self.get_type_display()})"


class User(AbstractUser):
	"""Custom user model extending Django's AbstractUser.

	Add extra fields here as needed for the POS system.
	"""

	phone = models.CharField(max_length=30, blank=True, null=True)
	store = models.ForeignKey(Store, null=True, blank=True, on_delete=models.SET_NULL, related_name='users')

	def __str__(self):
		return self.username
