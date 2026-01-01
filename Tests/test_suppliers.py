"""
اختبار شامل لـ Suppliers API
Test Suppliers Registration, CRUD, Search, Filter, Toggle Active
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
        "person_name": "علي احمد",
        "company_name": "شركة التوريد العربية",
        "phone": "201234567891",
        "email": "ali@supplier.com",
        "address": "الإسكندرية"
    },
    "step2_verify": {
        "step": 2,
        "phone": "201234567891",
        "otp": "123456"
    },
    "update_full": {
        "person_name": "علي احمد محمد",
        "company_name": "شركة التوريد العربية المحدودة",
        "email": "ali.updated@supplier.com",
        "address": "الإسكندرية"
    },
    "update_partial": {
        "company_name": "شركة التوريد الجديدة"
    },
    "toggle_active": {
        "active": False
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

def test_register_supplier_step1():
    """Test: Register Supplier (Step 1) - Send OTP"""
    url = f"{BASE_URL}/partners/suppliers/register/"
    response = requests.post(url, json=TEST_DATA["step1_register"])
    
    print_test(
        "Register Supplier Step 1",
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

def test_register_supplier_step2(otp="123456"):
    """Test: Register Supplier (Step 2) - Verify OTP"""
    url = f"{BASE_URL}/partners/suppliers/register/"
    data = TEST_DATA["step2_verify"].copy()
    data["otp"] = otp
    
    response = requests.post(url, json=data)
    
    print_test(
        "Register Supplier Step 2",
        "POST",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code in [200, 201]:
        result = response.json()
        supplier_id = result.get("data", {}).get("id")
        print(f"   ✅ Supplier registered successfully")
        print(f"   🆔 Supplier ID: {supplier_id}")
        return supplier_id
    else:
        print(f"   ❌ Error: {response.json()}")
        return None

def test_get_all_suppliers():
    """Test: Get All Suppliers"""
    url = f"{BASE_URL}/partners/suppliers/"
    response = requests.get(url)
    
    print_test(
        "Get All Suppliers",
        "GET",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        count = result.get("count", 0)
        print(f"   ✅ Found {count} suppliers")
        return result.get("data", [])
    else:
        print(f"   ❌ Error: {response.json()}")
        return []

def test_get_supplier_detail(supplier_id):
    """Test: Get Supplier Details"""
    url = f"{BASE_URL}/partners/suppliers/{supplier_id}/"
    response = requests.get(url)
    
    print_test(
        "Get Supplier Details",
        "GET",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        supplier = result.get("data", {})
        print(f"   ✅ Supplier: {supplier.get('person_name')}")
        return supplier
    else:
        print(f"   ❌ Error: {response.json()}")
        return None

def test_update_supplier_full(supplier_id):
    """Test: Update Supplier (Full Update)"""
    url = f"{BASE_URL}/partners/suppliers/{supplier_id}/"
    response = requests.put(url, json=TEST_DATA["update_full"])
    
    print_test(
        "Update Supplier (Full)",
        "PUT",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        supplier = result.get("data", {})
        print(f"   ✅ Updated: {supplier.get('person_name')}")
        return True
    else:
        print(f"   ❌ Error: {response.json()}")
        return False

def test_update_supplier_partial(supplier_id):
    """Test: Update Supplier (Partial Update)"""
    url = f"{BASE_URL}/partners/suppliers/{supplier_id}/"
    response = requests.patch(url, json=TEST_DATA["update_partial"])
    
    print_test(
        "Update Supplier (Partial)",
        "PATCH",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        supplier = result.get("data", {})
        print(f"   ✅ Company name updated: {supplier.get('company_name')}")
        return True
    else:
        print(f"   ❌ Error: {response.json()}")
        return False

def test_toggle_supplier_active(supplier_id):
    """Test: Toggle Supplier Active Status"""
    url = f"{BASE_URL}/partners/suppliers/{supplier_id}/toggle/"
    response = requests.patch(url, json=TEST_DATA["toggle_active"])
    
    print_test(
        "Toggle Supplier Active Status",
        "PATCH",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        active = result.get("data", {}).get("active")
        print(f"   ✅ Supplier active status: {active}")
        return True
    else:
        print(f"   ❌ Error: {response.json()}")
        return False

def test_search_suppliers(search_term="علي"):
    """Test: Search Suppliers"""
    url = f"{BASE_URL}/partners/suppliers/?search={search_term}"
    response = requests.get(url)
    
    print_test(
        f"Search Suppliers ('{search_term}')",
        "GET",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        count = result.get("count", 0)
        print(f"   ✅ Found {count} matching suppliers")
        return result.get("data", [])
    else:
        print(f"   ❌ Error: {response.json()}")
        return []

def test_filter_suppliers(active="true"):
    """Test: Filter Suppliers by Active Status"""
    url = f"{BASE_URL}/partners/suppliers/?active={active}"
    response = requests.get(url)
    
    print_test(
        f"Filter Suppliers (active={active})",
        "GET",
        url,
        response.status_code,
        response.text
    )
    
    if response.status_code == 200:
        result = response.json()
        count = result.get("count", 0)
        print(f"   ✅ Found {count} suppliers")
        return result.get("data", [])
    else:
        print(f"   ❌ Error: {response.json()}")
        return []

def test_delete_supplier(supplier_id):
    """Test: Delete Supplier"""
    url = f"{BASE_URL}/partners/suppliers/{supplier_id}/"
    response = requests.delete(url)
    
    print_test(
        "Delete Supplier",
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
    """Run all supplier tests"""
    print("=" * 60)
    print("🧪 SUPPLIERS API TEST SUITE")
    print("=" * 60)
    
    supplier_id = None
    
    # Test 1: Register Step 1
    print("\n📝 REGISTRATION TESTS")
    print("-" * 60)
    test_register_supplier_step1()
    print("\n⚠️  أدخل OTP من الرسالة في WhatsApp")
    
    # Test 2: Register Step 2
    otp = input("أدخل OTP: ").strip()
    supplier_id = test_register_supplier_step2(otp)
    
    if not supplier_id:
        print("\n❌ Failed to register supplier. Stopping tests.")
        return
    
    # Test 3: Get All Suppliers
    print("\n📋 READ TESTS")
    print("-" * 60)
    test_get_all_suppliers()
    
    # Test 4: Get Supplier Details
    test_get_supplier_detail(supplier_id)
    
    # Test 5: Update Full
    print("\n✏️  UPDATE TESTS")
    print("-" * 60)
    test_update_supplier_full(supplier_id)
    
    # Test 6: Update Partial
    test_update_supplier_partial(supplier_id)
    
    # Test 7: Search
    print("\n🔍 SEARCH & FILTER TESTS")
    print("-" * 60)
    test_search_suppliers()
    
    # Test 8: Filter
    test_filter_suppliers()
    
    # Test 9: Toggle Active
    print("\n🔄 TOGGLE TESTS")
    print("-" * 60)
    test_toggle_supplier_active(supplier_id)
    
    # Test 10: Delete
    print("\n🗑️  DELETE TESTS")
    print("-" * 60)
    test_delete_supplier(supplier_id)
    
    print("\n" + "=" * 60)
    print("✅ TEST SUITE COMPLETED")
    print("=" * 60)

if __name__ == "__main__":
    run_tests()
