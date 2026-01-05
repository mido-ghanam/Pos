import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';

class ReturnCartItem {
  final ProductModel product;
  int quantity;

  ReturnCartItem({required this.product, required this.quantity});
}

class ReturnCartPanel extends StatelessWidget {
  final String returnType;
  final List<ReturnCartItem> cartItems;
  final Function(int) onRemoveItem;
  final Function(int, int) onUpdateQuantity;
  final VoidCallback onClearCart;
  final double total;
  final VoidCallback onCheckoutPressed;

  const ReturnCartPanel({
    super.key,
    required this.returnType,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    required this.onClearCart,
    required this.total,
    required this.onCheckoutPressed,
  });

  double _price(ReturnCartItem item) {
    return returnType == "sale"
        ? (item.product.sellPrice ?? 0).toDouble()
        : (item.product.buyPrice ?? 0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(),
        Expanded(
          child: cartItems.isEmpty ? _empty() : _list(),
        ),
        if (cartItems.isNotEmpty) ...[
          const Divider(height: 1),
          _totals(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: AppTextButton(
              buttonText: 'إتمام المرتجع (${total.toStringAsFixed(2)} ج.م)',
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              backgroundColor: const Color(0xFFFB7185),
              icon: Icons.undo,
              onPressed: onCheckoutPressed,
            ),
          ),
        ],
      ],
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFB7185).withOpacity(0.08),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Text(
            "سلة المرتجع",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: onClearCart,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('مسح'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.undo, size: 70, color: Colors.grey[350]),
          const SizedBox(height: 12),
          Text('السلة فارغة', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _list() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB7185).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_bag, color: Color(0xFFFB7185)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_price(item).toStringAsFixed(2)} ج.م',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => onUpdateQuantity(index, item.quantity - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                    ),
                    Text('${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => onUpdateQuantity(index, item.quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => onRemoveItem(index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.grey,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _totals() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "الإجمالي",
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          Text(
            '${total.toStringAsFixed(2)} ج.م',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFB7185),
            ),
          ),
        ],
      ),
    );
  }
}
