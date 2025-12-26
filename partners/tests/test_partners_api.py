from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from ..models import Suppliers, Customers

User = get_user_model()

class PartnerAPITestCase(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.supplier_list = reverse('supplier-list')
        self.customer_list = reverse('customer-list')

    def test_create_supplier_requires_person_name(self):
        self.client.force_authenticate(user=self.user)
        data = {
            'company_name': 'Test Co',
            'phone': '123456',
            'address': 'Address',
            'active': True
        }
        resp = self.client.post(self.supplier_list, data, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('person_name', resp.data)

    def test_create_update_delete_supplier(self):
        self.client.force_authenticate(user=self.user)
        data = {
            'person_name': 'Ali',
            'company_name': 'Ali Co',
            'phone': '+201234567890',
            'address': 'Cairo',
            'active': True
        }
        resp = self.client.post(self.supplier_list, data, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        supplier_id = resp.data['id']

        detail_url = reverse('supplier-detail', args=[supplier_id])
        # update
        upd = {'person_name': 'Ali Updated'}
        resp2 = self.client.patch(detail_url, upd, format='json')
        self.assertEqual(resp2.status_code, status.HTTP_200_OK)
        self.assertEqual(resp2.data['person_name'], 'Ali Updated')

        # delete
        resp3 = self.client.delete(detail_url)
        self.assertEqual(resp3.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Suppliers.objects.filter(id=supplier_id).exists())

    def test_supplier_search_and_active_filter(self):
        self.client.force_authenticate(user=self.user)
        s1 = {
            'person_name': 'Ahmed',
            'company_name': 'Alpha',
            'phone': '111',
            'active': True
        }
        s2 = {
            'person_name': 'Salma',
            'company_name': 'Beta',
            'phone': '222',
            'active': False
        }
        self.client.post(self.supplier_list, s1, format='json')
        self.client.post(self.supplier_list, s2, format='json')

        # search by name
        resp = self.client.get(self.supplier_list + '?search=Ahmed')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp.data), 1)

        # filter active=false
        resp2 = self.client.get(self.supplier_list + '?active=false')
        self.assertEqual(resp2.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp2.data), 1)

    def test_create_update_delete_customer(self):
        self.client.force_authenticate(user=self.user)
        c = {
            'name': 'Mona',
            'phone': '+20111222',
            'address': 'Giza',
            'blocked': False,
            'vip': False
        }
        resp = self.client.post(self.customer_list, c, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        customer_id = resp.data['id']

        detail = reverse('customer-detail', args=[customer_id])
        upd = {'name': 'Mona Updated'}
        resp2 = self.client.patch(detail, upd, format='json')
        self.assertEqual(resp2.status_code, status.HTTP_200_OK)
        self.assertEqual(resp2.data['name'], 'Mona Updated')

        resp3 = self.client.delete(detail)
        self.assertEqual(resp3.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Customers.objects.filter(id=customer_id).exists())

    def test_customer_search_and_blocked_filter(self):
        self.client.force_authenticate(user=self.user)
        c1 = {'name': 'A', 'phone': '10', 'blocked': False}
        c2 = {'name': 'B', 'phone': '20', 'blocked': True}
        self.client.post(self.customer_list, c1, format='json')
        self.client.post(self.customer_list, c2, format='json')

        resp = self.client.get(self.customer_list + '?search=A')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp.data), 1)

        resp2 = self.client.get(self.customer_list + '?blocked=true')
        self.assertEqual(resp2.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp2.data), 1)
