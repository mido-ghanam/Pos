import 'package:flutter/material.dart';

class SuppliersTableHeader extends StatelessWidget {
  const SuppliersTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        );

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: DefaultTextStyle(
        style: style ?? const TextStyle(),
        child: Row(
          children: const [
            Expanded(flex: 3, child: Text('المورد')),
            Expanded(flex: 2, child: Text('الشركة')),
            Expanded(flex: 2, child: Text('التليفون')),
            Expanded(flex: 3, child: Text('العنوان')),
            Expanded(flex: 2, child: Text('الحالة')),
            Expanded(flex: 2, child: Text('التوثيق')),
            Expanded(flex: 2, child: Text('تاريخ الإنشاء')),
            Expanded(flex: 2, child: Text('إجراءات')),
          ],
        ),
      ),
    );
  }
}
