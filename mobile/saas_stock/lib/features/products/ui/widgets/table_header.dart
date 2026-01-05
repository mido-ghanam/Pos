import 'package:flutter/material.dart';

class ProductsTableHeader extends StatelessWidget {
  const ProductsTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        );

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          _HeaderCell(flex: 2, label: 'الكود'),
          _HeaderCell(flex: 4, label: 'اسم المنتج'),
          _HeaderCell(flex: 3, label: 'التصنيف'),
          _HeaderCell(flex: 3, label: 'الباركود'),
          _HeaderCell(flex: 2, label: 'الكمية'),
          _HeaderCell(flex: 2, label: 'سعر الشراء'),
          _HeaderCell(flex: 2, label: 'سعر البيع'),
          _HeaderCell(flex: 2, label: 'الحالة'),
          _HeaderCell(flex: 2, label: 'إجراءات'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final int flex;
  final String label;

  const _HeaderCell({required this.flex, required this.label});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        );
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: style,
        textAlign: TextAlign.start,
      ),
    );
  }
}
