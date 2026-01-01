"""
Quick Test - Customers Registration
بدون input تفاعلي
"""

import requests
import json

BASE_URL = "http://127.0.0.1:8000"

# Test 1: Register Step 1
print("=" * 60)
print("🧪 Test 1: Register Customer Step 1")
print("=" * 60)

test_data = {
    "step": 1,
    "name": "محمد احمد",
    "phone": "201234567890",
    "email": "ahmed@example.com",
    "address": "القاهرة"
}

url = f"{BASE_URL}/partners/customers/register/"
print(f"\n📤 POST {url}")
print(f"📝 Data: {json.dumps(test_data, indent=2, ensure_ascii=False)}")

try:
    response = requests.post(url, json=test_data)
    print(f"\n✅ Status: {response.status_code}")
    print(f"📋 Response:")
    print(json.dumps(response.json(), indent=2, ensure_ascii=False))
except Exception as e:
    print(f"\n❌ Error: {str(e)}")

# Test 2: Get all customers
print("\n" + "=" * 60)
print("🧪 Test 2: Get All Customers")
print("=" * 60)

url = f"{BASE_URL}/partners/customers/"
print(f"\n📤 GET {url}")

try:
    response = requests.get(url)
    print(f"\n✅ Status: {response.status_code}")
    print(f"📋 Response:")
    data = response.json()
    print(json.dumps(data, indent=2, ensure_ascii=False)[:500] + "...")
except Exception as e:
    print(f"\n❌ Error: {str(e)}")

# Test 3: Register Supplier Step 1
print("\n" + "=" * 60)
print("🧪 Test 3: Register Supplier Step 1")
print("=" * 60)

supplier_data = {
    "step": 1,
    "person_name": "علي احمد",
    "company_name": "شركة التوريد العربية",
    "phone": "201234567891",
    "email": "ali@supplier.com",
    "address": "الإسكندرية"
}

url = f"{BASE_URL}/partners/suppliers/register/"
print(f"\n📤 POST {url}")
print(f"📝 Data: {json.dumps(supplier_data, indent=2, ensure_ascii=False)}")

try:
    response = requests.post(url, json=supplier_data)
    print(f"\n✅ Status: {response.status_code}")
    print(f"📋 Response:")
    print(json.dumps(response.json(), indent=2, ensure_ascii=False))
except Exception as e:
    print(f"\n❌ Error: {str(e)}")

# Test 4: Get all suppliers
print("\n" + "=" * 60)
print("🧪 Test 4: Get All Suppliers")
print("=" * 60)

url = f"{BASE_URL}/partners/suppliers/"
print(f"\n📤 GET {url}")

try:
    response = requests.get(url)
    print(f"\n✅ Status: {response.status_code}")
    print(f"📋 Response:")
    data = response.json()
    print(json.dumps(data, indent=2, ensure_ascii=False)[:500] + "...")
except Exception as e:
    print(f"\n❌ Error: {str(e)}")

print("\n" + "=" * 60)
print("✅ QUICK TESTS COMPLETED")
print("=" * 60)
