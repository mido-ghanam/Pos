"""
اختبار شامل لـ Customers API
Test Customers Registration, CRUD, Search, Filter, Block
"""

import requests
import json
import time

BASE_URL = "http://127.0.0.1:8000"

# ============================================
# Test Data
# ============================================

TEST_DATA = {
    "step1_register": {
        "step": 1,
        "name": "محمد احمد",
        "phone": "201234567890",
        "email": "ahmed@example.com",
        "address": "القاهرة"
    },
    "step2_verify": {
        "step": 2,
        "phone": "201234567890",
        "otp": "123456"
    },
    "update_full": {
        "name": "محمد احمد محمد",
        "email": "ahmed.updated@example.com",
        "address": "الجيزة"
    },
    "update_partial": {
        "address": "الساحل الشمالي"
    },
    "block": {
        "blocked": True
    }
}

# ============================================
# Helper Functions
# ============================================

def print_test(test_name, method, url, status_code, response_text):
    """Print test result"""
    status = "✅ PASS" if status_code in [200, 201] else "❌ FAIL"
    print(f"\n{status} [{method}] {test_name}")
    print(f"   URL: {url}")
    print(f"   Status: {status_code}")
    print(f"   Response: {response_text[:200]}...")

def test_register_customer_step1():
    """Test: Register Customer (Step 1) - Send OTP"""
    url = f"{BASE_URL}/partners/customers/register/"
    response = requests.post(url, json=TEST_DATA["step1_register"])
    
    print_test(
        "Register Customer Step 1",
        "POST",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code in [200, 201]:
        print("   ✅ OTP sent successfully")
        print(f"   📱 Check WhatsApp for OTP")
        return response.json()
    else:
        print(f"   ❌ Error: {response.json()}")
        return None

def test_register_customer_step2(otp="123456"):
    """Test: Register Customer (Step 2) - Verify OTP"""
    url = f"{BASE_URL}/partners/customers/register/"
    data = TEST_DATA["step2_verify"].copy()
    data["otp"] = otp
    
    response = requests.post(url, json=data)
    
    print_test(
        "Register Customer Step 2",
        "POST",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code in [200, 201]:
        result = response.json()
        customer_id = result.get("data", {}).get("id")
        print(f"   ✅ Customer registered successfully")
        print(f"   🆔 Customer ID: {customer_id}")
        return customer_id
    else:
        print(f"   ❌ Error: {response.json()}")
        return None

def test_get_all_customers():
    """Test: Get All Customers"""
    url = f"{BASE_URL}/partners/customers/"
    response = requests.get(url)
    
    print_test(
        "Get All Customers",
        "GET",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        count = result.get("count", 0)
        print(f"   ✅ Found {count} customers")
        return result.get("data", [])
    else:
        print(f"   ❌ Error: {response.json()}")
        return []

def test_get_customer_detail(customer_id):
    """Test: Get Customer Details"""
    url = f"{BASE_URL}/partners/customers/{customer_id}/"
    response = requests.get(url)
    
    print_test(
        "Get Customer Details",
        "GET",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        customer = result.get("data", {})
        print(f"   ✅ Customer: {customer.get('name')}")
        return customer
    else:
        print(f"   ❌ Error: {response.json()}")
        return None

def test_update_customer_full(customer_id):
    """Test: Update Customer (Full Update)"""
    url = f"{BASE_URL}/partners/customers/{customer_id}/"
    response = requests.put(url, json=TEST_DATA["update_full"])
    
    print_test(
        "Update Customer (Full)",
        "PUT",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        customer = result.get("data", {})
        print(f"   ✅ Updated: {customer.get('name')}")
        return True
    else:
        print(f"   ❌ Error: {response.json()}")
        return False

def test_update_customer_partial(customer_id):
    """Test: Update Customer (Partial Update)"""
    url = f"{BASE_URL}/partners/customers/{customer_id}/"
    response = requests.patch(url, json=TEST_DATA["update_partial"])
    
    print_test(
        "Update Customer (Partial)",
        "PATCH",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        customer = result.get("data", {})
        print(f"   ✅ Address updated: {customer.get('address')}")
        return True
    else:
        print(f"   ❌ Error: {response.json()}")
        return False

def test_block_customer(customer_id):
    """Test: Block Customer"""
    url = f"{BASE_URL}/partners/customers/{customer_id}/block/"
    response = requests.patch(url, json=TEST_DATA["block"])
    
    print_test(
        "Block Customer",
        "PATCH",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        blocked = result.get("data", {}).get("blocked")
        print(f"   ✅ Customer blocked: {blocked}")
        return True
    else:
        print(f"   ❌ Error: {response.json()}")
        return False

def test_search_customers(search_term="محمد"):
    """Test: Search Customers"""
    url = f"{BASE_URL}/partners/customers/?search={search_term}"
    response = requests.get(url)
    
    print_test(
        f"Search Customers ('{search_term}')",
        "GET",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        count = result.get("count", 0)
        print(f"   ✅ Found {count} matching customers")
        return result.get("data", [])
    else:
        print(f"   ❌ Error: {response.json()}")
        return []

def test_filter_customers(blocked="false"):
    """Test: Filter Customers by Status"""
    url = f"{BASE_URL}/partners/customers/?blocked={blocked}"
    response = requests.get(url)
    
    print_test(
        f"Filter Customers (blocked={blocked})",
        "GET",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        count = result.get("count", 0)
        print(f"   ✅ Found {count} customers")
        return result.get("data", [])
    else:
        print(f"   ❌ Error: {response.json()}")
        return []

def test_delete_customer(customer_id):
    """Test: Delete Customer"""
    url = f"{BASE_URL}/partners/customers/{customer_id}/"
    response = requests.delete(url)
    
    print_test(
        "Delete Customer",
        "DELETE",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        message = result.get("message", "")
        print(f"   ✅ {message}")
        return True
    else:
        print(f"   ❌ Error: {response.json()}")
        return False

# ============================================
# Main Test Suite
# ============================================

def run_tests():
    """Run all customer tests"""
    print("=" * 60)
    print("🧪 CUSTOMERS API TEST SUITE")
    print("=" * 60)
    
    customer_id = None
    
    # Test 1: Register Step 1
    print("\n📝 REGISTRATION TESTS")
    print("-" * 60)
    test_register_customer_step1()
    print("\n⚠️  أدخل OTP من الرسالة في WhatsApp")
    
    # Test 2: Register Step 2
    otp = input("أدخل OTP: ").strip()
    customer_id = test_register_customer_step2(otp)
    
    if not customer_id:
        print("\n❌ Failed to register customer. Stopping tests.")
        return
    
    # Test 3: Get All Customers
    print("\n📋 READ TESTS")
    print("-" * 60)
    test_get_all_customers()
    
    # Test 4: Get Customer Details
    test_get_customer_detail(customer_id)
    
    # Test 5: Update Full
    print("\n✏️  UPDATE TESTS")
    print("-" * 60)
    test_update_customer_full(customer_id)
    
    # Test 6: Update Partial
    test_update_customer_partial(customer_id)
    
    # Test 7: Search
    print("\n🔍 SEARCH & FILTER TESTS")
    print("-" * 60)
    test_search_customers()
    
    # Test 8: Filter
    test_filter_customers()
    
    # Test 9: Block
    print("\n🚫 BLOCK TESTS")
    print("-" * 60)
    test_block_customer(customer_id)
    
    # Test 10: Delete
    print("\n🗑️  DELETE TESTS")
    print("-" * 60)
    test_delete_customer(customer_id)
    
    print("\n" + "=" * 60)
    print("✅ TEST SUITE COMPLETED")
    print("=" * 60)

if __name__ == "__main__":
    run_tests()
