import 'package:flutter/material.dart';
import 'package:saas_stock/core/services/barcode_print_service.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';

class ProductsTableCard extends StatelessWidget {
  final ProductModel product;

  const ProductsTableCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final qty = product.quantity ?? 0;
    final minQty = product.minQuantity ?? 0;
    final qtyColor = qty <= minQty
        ? Colors.red
        : (qty <= (minQty * 2) ? Colors.orange : Colors.green);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: عرض تفاصيل المنتج
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان مع الحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(isActive: product.active ?? false),
                ],
              ),
              const SizedBox(height: 8),

              // الكود والتصنيف
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.qr_code,
                    label: product.id?.substring(0, 8) ?? '-',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.category_outlined,
                    label: product.categoryName,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // الباركود
              _InfoRow(
                icon: Icons.barcode_reader,
                label: 'الباركود',
                value: product.barcode?.toString() ?? '-',
              ),
              const SizedBox(height: 8),

              // الكمية
              _InfoRow(
                icon: Icons.inventory_2,
                label: 'الكمية',
                value: '${qty.toStringAsFixed(0)}',
                valueColor: qtyColor,
              ),
              const SizedBox(height: 12),

              const Divider(height: 1),
              const SizedBox(height: 12),

              // الأسعار
              Row(
                children: [
                  Expanded(
                    child: _PriceCard(
                      label: 'سعر الشراء',
                      price: product.buyPrice ?? 0,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PriceCard(
                      label: 'سعر البيع',
                      price: product.sellPrice ?? 0,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // الإجراءات
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: تعديل
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('تعديل'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: حذف
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('حذف'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                 
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bg = color.withOpacity(0.1);
    final text = isActive ? 'نشط' : 'موقوف';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String label;
  final double price;
  final Color color;

  const _PriceCard({
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${price.toStringAsFixed(2)} ج.م',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
