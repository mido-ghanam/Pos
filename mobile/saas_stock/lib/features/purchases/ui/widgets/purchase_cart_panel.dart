import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';

/// ✅ Generic Cart Item Interface
/// أي موديل عندك للسلة لازم يوفر:
/// - name
/// - price
/// - quantity
/// - total
///
/// لو عندك CartItem زي بتاعك:
/// class CartItem {
///   final ProductItem product;
///   int quantity;
///   double get total => product.price * quantity;
/// }
///
/// تقدر تمررهم مباشرة هنا لأننا بنستخدم callbacks + getters
class PosCartPanel<T> extends StatefulWidget {
  final List<T> cartItems;

  /// Required getters
  final String Function(T item) getName;
  final double Function(T item) getPrice;
  final int Function(T item) getQuantity;
  final double Function(T item) getTotal;

  /// Actions
  final void Function(int index) onRemoveItem;
  final void Function(int index, int newQty) onUpdateQuantity;
  final VoidCallback onClearCart;

  /// Checkout
  final VoidCallback onCheckoutPressed;
  final String checkoutLabel;
  final IconData checkoutIcon;
  final Color checkoutColor;

  /// Optional UI settings
  final bool enableDiscount;
  final bool enableTax;
  final double initialTaxPercentage;
  final double initialDiscountPercentage;

  /// If you want to hide summary lines
  final bool showSummary;

  const PosCartPanel({
    super.key,
    required this.cartItems,
    required this.getName,
    required this.getPrice,
    required this.getQuantity,
    required this.getTotal,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    required this.onClearCart,
    required this.onCheckoutPressed,
    this.checkoutLabel = "إتمام العملية",
    this.checkoutIcon = Icons.receipt_long,
    this.checkoutColor = const Color(0xFF7C3AED),
    this.enableDiscount = true,
    this.enableTax = true,
    this.initialTaxPercentage = 14,
    this.initialDiscountPercentage = 0,
    this.showSummary = true,
  });

  @override
  State<PosCartPanel<T>> createState() => _PosCartPanelState<T>();
}

class _PosCartPanelState<T> extends State<PosCartPanel<T>> {
  late double _discountPercentage;
  late double _taxPercentage;

  @override
  void initState() {
    super.initState();
    _discountPercentage = widget.initialDiscountPercentage;
    _taxPercentage = widget.initialTaxPercentage;
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = (widget.cartItems.fold<double>(
      0,
      (sum, item) => sum + widget.getTotal(item),
    ) as double);

    final discount = widget.enableDiscount
        ? subtotal * (_discountPercentage / 100)
        : 0.0;

    final afterDiscount = subtotal - discount;

    final tax = widget.enableTax ? afterDiscount * (_taxPercentage / 100) : 0.0;

    final total = afterDiscount + tax;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: widget.cartItems.isEmpty
                ? _buildEmptyCart()
                : _buildItemsList(),
          ),
          if (widget.cartItems.isNotEmpty && widget.showSummary) ...[
            const Divider(height: 1),
            _buildCalculations(subtotal, discount, tax, total),
            const Divider(height: 1),
            _buildCheckoutButton(total),
          ],
        ],
      ),
    );
  }

  // ====================== UI ======================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.checkoutColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "سلة العمليات",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (widget.cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: widget.onClearCart,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text("مسح الكل"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "السلة فارغة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "أضف منتجات لبدء العملية",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = widget.cartItems[index];
        return _CartItemCard(
          name: widget.getName(item),
          price: widget.getPrice(item),
          quantity: widget.getQuantity(item),
          total: widget.getTotal(item),
          accentColor: widget.checkoutColor,
          onRemove: () => widget.onRemoveItem(index),
          onQuantityChanged: (qty) => widget.onUpdateQuantity(index, qty),
        );
      },
    );
  }

  Widget _buildCalculations(
    double subtotal,
    double discount,
    double tax,
    double total,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryRow(label: "الإجمالي الفرعي", value: subtotal),

          const SizedBox(height: 10),

          if (widget.enableDiscount) ...[
            Row(
              children: [
                Expanded(child: _SummaryRow(label: "الخصم", value: -discount)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 90,
                  child: UniversalFormField(
                    hintText: "%",
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _discountPercentage = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          if (widget.enableTax) ...[
            Row(
              children: [
                Expanded(
                  child: _SummaryRow(
                    label: "الضريبة ($_taxPercentage%)",
                    value: tax,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 90,
                  child: UniversalFormField(
                    hintText: "%",
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _taxPercentage = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          const Divider(height: 24),

          _SummaryRow(
            label: "الإجمالي النهائي",
            value: total,
            isTotal: true,
            accentColor: widget.checkoutColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(double total) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppTextButton(
        buttonText:
            "${widget.checkoutLabel} (${total.toStringAsFixed(2)} ج.م)",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        backgroundColor: widget.checkoutColor,
        icon: widget.checkoutIcon,
        onPressed: widget.onCheckoutPressed,
      ),
    );
  }
}

// ====================== Item Card ======================

class _CartItemCard extends StatelessWidget {
  final String name;
  final double price;
  final int quantity;
  final double total;
  final Color accentColor;

  final VoidCallback onRemove;
  final Function(int qty) onQuantityChanged;

  const _CartItemCard({
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.accentColor,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.shopping_bag, color: accentColor),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${price.toStringAsFixed(2)} ج.م",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                IconButton(
                  onPressed: () => onQuantityChanged(quantity - 1),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),

                InkWell(
                  onTap: () async {
                    final newQty =
                        await _showQuantityDialog(context, quantity);
                    if (newQty != null) onQuantityChanged(newQty);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      "$quantity",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () => onQuantityChanged(quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      total.toStringAsFixed(2),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: accentColor,
                      ),
                    ),
                    const Text("ج.م", style: TextStyle(fontSize: 12)),
                  ],
                ),

                const SizedBox(width: 6),

                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _showQuantityDialog(BuildContext context, int currentQty) async {
    final controller = TextEditingController(text: currentQty.toString());

    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تعديل الكمية"),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "الكمية",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed > 0) {
              Navigator.pop(context, parsed);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              if (parsed != null && parsed > 0) {
                Navigator.pop(context, parsed);
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}

// ====================== Summary Row ======================

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;
  final Color? accentColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isTotal ? (accentColor ?? const Color(0xFF7C3AED)) : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          "${value.toStringAsFixed(2)} ج.م",
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? color : Colors.black87,
          ),
        ),
      ],
    );
  }
}
