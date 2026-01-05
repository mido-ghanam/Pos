import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/products/logic/product/products_states.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/sales/logic/states.dart';
import 'package:saas_stock/features/sales/ui/widgets/pos_cart_panel.dart';
import 'package:saas_stock/features/sales/ui/widgets/pos_products_grid.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<CartItem> _cartItems = [];
  String _searchQuery = '';
  String? _selectedCategory;
  void _addToCart(ProductModel product) {
    setState(() {
      final existingIndex =
          _cartItems.indexWhere((item) => item.product.id == product.id);

      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  double _calculateTotal() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + item.saleTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final salesCubit = context.read<SalesCubit>();
    final productsCubit = context.read<ProductsCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: productsCubit),
        BlocProvider.value(value: salesCubit),
      ],
      child: BlocListener<SalesCubit, SalesState>(
        listener: (context, state) {
          if (state is CreateSaleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is CreateSaleSuccess) {
            _clearCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ تم إنشاء الفاتورة بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('نقطة البيع'),
            backgroundColor: const Color(0xFF7C3AED),
            actions: [
              IconButton(
                onPressed: () {
                  productsCubit.getAllProducts();
                  salesCubit.loadSales();
                },
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long),
                tooltip: 'فواتير المبيعات',
                onPressed: () {
                  Navigator.pushNamed(context, Routers.salesInvoices);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 8),
              UniversalFormField(
                hintText: 'ابحث بالاسم أو الباركود...',
                prefixIcon: const Icon(Icons.search),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isDesktop || ResponsiveHelper.isTablet(context)
                    ? _buildDesktopLayout()
                    : _buildMobileLayout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              return PosProductsGrid(
                searchQuery: _searchQuery,
                selectedCategory: _selectedCategory,
                onProductTap: _addToCart,
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 4,
          child: PosCartPanel(
            cartItems: _cartItems,
            onRemoveItem: _removeFromCart,
            onUpdateQuantity: _updateQuantity,
            onClearCart: _clearCart,
            total: _calculateTotal(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: PosProductsGrid(
            searchQuery: _searchQuery,
            selectedCategory: _selectedCategory,
            onProductTap: _addToCart,
          ),
        ),

        // Bottom Cart bar
        Container(
          height: 85,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: InkWell(
            onTap: _cartItems.isEmpty ? null : _showCartBottomSheet,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Color(0xFF7C3AED),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _cartItems.isEmpty
                              ? 'السلة فارغة'
                              : 'السلة (${_cartItems.length} منتجات)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_calculateTotal().toStringAsFixed(2)} ج.م',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _cartItems.isEmpty ? Icons.lock : Icons.keyboard_arrow_up,
                    color: Colors.grey,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: PosCartPanel(
            cartItems: _cartItems,
            onRemoveItem: _removeFromCart,
            onUpdateQuantity: _updateQuantity,
            onClearCart: _clearCart,
            total: _calculateTotal(),
            isBottomSheet: true,
          ),
        ),
      ),
    );
  }
}
