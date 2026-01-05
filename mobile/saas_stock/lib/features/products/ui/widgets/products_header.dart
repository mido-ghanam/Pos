import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';

class ProductsHeader extends StatelessWidget {
  const ProductsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelper.cardPadding(context),
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة المنتجات',
            style: TextStyle(
              fontSize: ResponsiveHelper.heading2(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'عرض، إضافة، تعديل، وحذف المنتجات في المخزن.',
            style: TextStyle(
              fontSize: ResponsiveHelper.bodyMedium(context),
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
