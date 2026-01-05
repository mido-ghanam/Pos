import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/products/logic/product/products_states.dart';

class PosProductsGrid extends StatelessWidget {
  final String searchQuery;
  final String? selectedCategory;
  final Function(ProductModel) onProductTap;

  /// ✅ NEW: Allow selecting products even if stock = 0 (for Purchases)
  final bool allowZeroStock;

  const PosProductsGrid({
    super.key,
    required this.searchQuery,
    this.selectedCategory,
    required this.onProductTap,
    this.allowZeroStock = false, // ✅ default for Sales
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.value(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
          );
        }

        if (state is ProductsLoaded) {
          final cubit = context.read<ProductsCubit>();
          final products = cubit.products;

          final list = products.where((p) {
            final q = searchQuery.toLowerCase();

            final matchesSearch = searchQuery.isEmpty ||
                (p.name ?? '').toLowerCase().contains(q) ||
                (p.barcode?.toString() ?? '').contains(q);

            final matchesCategory = selectedCategory == null ||
                selectedCategory!.isEmpty ||
                p.categoryName.toLowerCase() ==
                    selectedCategory!.toLowerCase();

            /// ✅ هنا مش هنفلتر المنتجات اللي كميتها صفر
            /// لأن المبيعات هي اللي بتعمل disable
            return matchesSearch && matchesCategory && (p.active ?? true);
          }).toList();

          if (list.isEmpty) {
            return Center(
              child: Text(
                'لا توجد منتجات مطابقة',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return Container(
            color: const Color(0xFFF9FAFB),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.78,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final product = list[index];

                return _ProductCard(
                  product: product,
                  allowZeroStock: allowZeroStock,
                  onTap: () => onProductTap(product),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  /// ✅ NEW
  final bool allowZeroStock;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.allowZeroStock,
  });

  @override
  Widget build(BuildContext context) {
    final stock = (product.quantity ?? 0).toInt();
    final isLow = stock <= 5;
    final price = (product.sellPrice ?? 0).toDouble();

    /// ✅ لو شراء allowZeroStock = true يبقى دايمًا clickable
    final canTap = allowZeroStock ? true : stock > 0;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: canTap ? 1 : 0.55, // ✅ Disabled effect
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.08),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    size: 46,
                    color: stock <= 0
                        ? Colors.grey
                        : const Color(0xFF7C3AED),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${price.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: stock <= 0
                                  ? Colors.grey.withOpacity(0.15)
                                  : isLow
                                      ? Colors.orange.withOpacity(0.15)
                                      : Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              stock <= 0 ? 'نفذ' : '$stock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: stock <= 0
                                    ? Colors.grey
                                    : isLow
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ CartItem الحقيقي اللي هيشتغل في Sales/Purchases
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get saleTotal => (product.sellPrice ?? 0) * quantity;
  double get buyTotal => (product.buyPrice ?? 0) * quantity;
}
