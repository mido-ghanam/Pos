import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/sales/ui/widgets/checkout_dialog.dart';
import 'pos_products_grid.dart';

class PosCartPanel extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(int) onRemoveItem;
  final Function(int, int) onUpdateQuantity;
  final VoidCallback onClearCart;
  final double total;
  final bool isBottomSheet;

  const PosCartPanel({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    required this.onClearCart,
    required this.total,
    this.isBottomSheet = false,
  });

  @override
  State<PosCartPanel> createState() => _PosCartPanelState();
}

class _PosCartPanelState extends State<PosCartPanel> {
  double discountPercentage = 0;
  double taxPercentage = 0;

  double get subtotal =>
      widget.cartItems.fold(0, (sum, item) => sum + item.saleTotal);

  double get discount => subtotal * (discountPercentage / 100);
  double get afterDiscount => subtotal - discount;
  double get tax => afterDiscount * (taxPercentage / 100);
  double get finalTotal => afterDiscount + tax;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: widget.cartItems.isEmpty ? _buildEmpty() : _buildList(),
        ),
        if (widget.cartItems.isNotEmpty) ...[
          const Divider(height: 1),
          _buildTotals(),
          const Divider(height: 1),
          _buildCheckoutButton(),
          if (widget.isBottomSheet) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.08),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Text(
            'سلة المشتريات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (widget.cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: widget.onClearCart,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('مسح'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.grey[350]),
          const SizedBox(height: 12),
          Text('السلة فارغة', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: widget.cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = widget.cartItems[index];
        return _CartItemCard(
          item: item,
          onRemove: () => widget.onRemoveItem(index),
          onQuantityChanged: (qty) => widget.onUpdateQuantity(index, qty),
        );
      },
    );
  }

  Widget _buildTotals() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _row('الإجمالي الفرعي', subtotal),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _row('خصم', -discount)),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '%',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                  onChanged: (v) {
                    setState(
                        () => discountPercentage = double.tryParse(v) ?? 0);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _row('ضريبة', tax)),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '%',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                  onChanged: (v) {
                    setState(() => taxPercentage = double.tryParse(v) ?? 0);
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          _row('الإجمالي النهائي', finalTotal, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: AppTextButton(
        buttonText: 'إتمام البيع (${finalTotal.toStringAsFixed(2)} ج.م)',
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        backgroundColor: const Color(0xFF7C3AED),
        icon: Icons.receipt_long,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<SalesCubit>(),
              child: CheckoutDialog(
                cartItems: widget.cartItems,
                total: finalTotal,
                parentContext: context, // ✅ NEW
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)} ج.م',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF7C3AED) : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final price = (item.product.sellPrice ?? 0).toDouble();

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
                color: const Color(0xFF7C3AED).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag, color: Color(0xFF7C3AED)),
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
                    '${price.toStringAsFixed(2)} ج.م',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => onQuantityChanged(item.quantity - 1),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                ),
                Text('${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => onQuantityChanged(item.quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
