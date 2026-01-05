import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/products/logic/product/products_states.dart';
import 'package:saas_stock/features/products/ui/widgets/products_table_card.dart';
import 'package:saas_stock/features/products/ui/widgets/table_header.dart';
import 'package:saas_stock/features/products/ui/widgets/table_row.dart';

class ProductsTable extends StatelessWidget {
  const ProductsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        // ✅ Loading State
        if (state is ProductsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF7C3AED),
            ),
          );
        }

        // ✅ Empty State
        if (state is ProductsLoaded && state.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد منتجات',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ابدأ بإضافة منتج جديد',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // ✅ Success State
        if (state is ProductsLoaded) {
          final products = state.products;

          if (isMobile) {
            // عرض كروت للموبايل
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(
                ResponsiveHelper.value(
                  context: context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
              ),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return ProductsTableCard(product: products[index]);
              },
            );
          }

          // عرض جدول للديسكتوب/تابلت
          return Padding(
            padding: EdgeInsets.all(
              ResponsiveHelper.value(
                context: context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    const ProductsTableHeader(),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ProductsTableRow(product: products[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ✅ Default
        return const SizedBox.shrink();
      },
    );
  }
}
