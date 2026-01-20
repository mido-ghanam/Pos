# ✅ الصيغة الصحيحة للأرباح

## 🎯 المبدأ الأساسي

**الأرباح = الفرق بين سعر البيع والشراء فقط** (لا تتأثر بالمشتريات الإجمالية)

---

## 📊 مثال عملي

### المنتج الواحد:
```
اشتريته بـ: 20ج
بعته بـ: 25ج
الربح = 25 - 20 = 5ج
```

### في فاتورة المبيعات:
```
الفاتورة بها 10 منتجات:
- المنتج أ: باع × 3 = 75ج (اشترى 60ج) → ربح 15ج
- المنتج ب: باع × 2 = 50ج (اشترى 40ج) → ربح 10ج
- إلخ...

الربح الإجمالي من الفاتورة = مجموع الأرباح من كل منتج
```

---

## 💡 الحسابات الجديدة

### في `BillingDashboardView` (الإجمالي):
```python
profit_from_sales = SalesInvoiceItem.objects.aggregate(
    profit=Sum(
        F('subtotal') - (F('product__buy_price') * F('quantity'))
    )
)
```
**يعني:** مجموع (سعر البيع - سعر الشراء) لكل منتج مباع

### في `ProfitStatsView` (بفترة زمنية):
```python
profit_from_sales = SalesInvoiceItem.objects.filter(
    invoice__created_at__gte=start
).aggregate(
    profit=Sum(
        F('subtotal') - (F('product__buy_price') * F('quantity'))
    )
)
```
**يعني:** نفس الحساب لكن في فترة معينة فقط

---

## 🔴 المرتجعات

لما يرجع الزبون منتج:
```
المنتج الأصلي أرباح = 5ج
لو رجعه → نخصم 5ج من الأرباح الكلية
```

```python
profit_lost_from_returns = SalesInvoiceItem.objects.filter(
    invoice__in=ReturnInvoice.objects.filter(partner_type='sale')
).aggregate(
    profit=Sum(
        F('subtotal') - (F('product__buy_price') * F('quantity'))
    )
)
```

---

## 📈 الصيغة النهائية

```
الربح الصافي = 
    أرباح المبيعات الكلية 
    - أرباح المنتجات المرتجعة 
    - المصروفات

Net Profit = Profit_from_Sales - Profit_Lost_from_Returns - Expenses
```

---

## 🏧 الخزنة (منفصلة تماماً)

الخزنة لا تتأثر بهذه الحسابات:
- المشتريات تخرج من الخزنة فقط (دفع نقدي)
- الأرباح تحسب من الفرق بين السعرين فقط

---

## ✅ الفرق من قبل:

### ❌ **القديمة (خطأ):**
```python
profit = (total_sales - sales_returns) - (total_purchases - purchase_returns)
```
هذه تحسب: كل ما دخل - كل ما طلع (غلط!)

### ✅ **الجديدة (صحيح):**
```python
net_profit = profit_from_sales - profit_lost_from_returns - expenses
```
هذه تحسب: الفرق بين البيع والشراء فقط (صحيح!)

---

## 📱 الـ Response الجديد

### GET /api/billing/profit/
```json
{
  "total_sales": 1000,
  "total_purchases": 600,
  "sales_returns": 50,
  "cash_balance": 700,
  "profit_from_sales": 200,
  "profit_from_returns": 10,
  "total_expenses": 30,
  "net_profit": 160
}
```

**شرح:**
- `profit_from_sales`: 200ج من الفرق بين أسعار البيع والشراء
- `profit_from_returns`: 10ج خسارة من المرتجعات
- `net_profit`: 160ج الربح الصافي النهائي

### GET /api/billing/profit-stats/?period=today
```json
{
  "period": "today",
  "sales_total": 500,
  "sales_received": 450,
  "purchases_total": 300,
  "purchases_paid": 300,
  "profit_from_sales": 100,
  "profit_lost_from_returns": 5,
  "expenses": 10,
  "cash_balance": 450,
  "net_profit": 85
}
```

---

## 💯 مثال يومي كامل

```
الصباح:
├─ الخزنة: 1000ج
└─ الأرباح: 0ج

العملية 1: بعت منتج شريته بـ 20 بـ 25
├─ الخزنة: 1025ج ✓ (زادت بـ 25)
├─ الأرباح: 5ج ✓ (ربح الفرق = 5)
└─ ملاحظة: المشتريات ما تأثرت على الأرباح!

العملية 2: اشتريت منتجات بـ 200 ودفعت نقد
├─ الخزنة: 825ج ✓ (قلت بـ 200)
├─ الأرباح: 5ج ✓ (ما تغيرت!)
└─ ملاحظة: الشراء يأثر على الخزنة فقط

العملية 3: المصروفات 50ج
├─ الخزنة: 825ج ✓ (ما تغيرت)
├─ الأرباح: -45ج ✓ (5 - 50 = -45)
└─ ملاحظة: المصروفات من الأرباح فقط

العملية 4: رجع منتج أرباحه 3ج
├─ الخزنة: 797ج ✓ (قلت بـ 28)
├─ الأرباح: -48ج ✓ (-45 - 3 = -48)
└─ ملاحظة: المرتجع يقلل الأرباح والخزنة

النتيجة النهائية:
├─ الخزنة: 797ج (الفلوس الفعلية المتاحة)
└─ الأرباح: -48ج (خسارة من المصروفات والمرتجعات)
```

---

**الملخص:** ✅ الأرباح تحسب من الفرق بين أسعار البيع والشراء فقط!
