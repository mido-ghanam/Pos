import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/features/purchases/logic/cubit.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/purchases/ui/screens/purchases_invoices_screen.dart';
import 'package:saas_stock/features/purchases/ui/widgets/purchase_cart_panel.dart';
import 'package:saas_stock/features/sales/ui/widgets/pos_products_grid.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';
import '../widgets/purchase_checkout_dialog.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final List<CartItem> cartItems = [];
  String search = '';
  String? category;

  void addToCart(ProductModel product) {
    setState(() {
      final idx = cartItems.indexWhere((e) => e.product.id == product.id);
      if (idx != -1) {
        cartItems[idx].quantity++;
      } else {
        cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void removeItem(int index) => setState(() => cartItems.removeAt(index));

  void updateQty(int index, int qty) {
    setState(() {
      if (qty <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index].quantity = qty;
      }
    });
  }

  void clearCart() => setState(() => cartItems.clear());

  double total() => cartItems.fold(0, (sum, e) => sum + e.buyTotal);

  bool get isMobile => MediaQuery.of(context).size.width < 900;

  @override
  Widget build(BuildContext context) {
    final purchasesCubit = context.read<PurchasesCubit>();
    final productsCubit = context.read<ProductsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقطة شراء'),
        backgroundColor: const Color(0xFF7C3AED),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => productsCubit.getAllProducts(),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: "فواتير المشتريات",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PurchasesInvoicesScreen()),
              );
            },
          ),
        ],
      ),

      // ✅ Floating Button للموبايل فقط
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text("السلة (${cartItems.length})"),
              onPressed: cartItems.isEmpty
                  ? null
                  : () => _openCartBottomSheet(context, purchasesCubit),
            )
          : null,

      body: Column(
        children: [
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: UniversalFormField(
              hintText: 'ابحث بالاسم أو الباركود...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => setState(() => search = value),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: isMobile
                ? _mobileLayout(purchasesCubit) // ✅ Mobile UI
                : _desktopLayout(purchasesCubit), // ✅ Desktop UI
          ),
        ],
      ),
    );
  }

  // ===========================
  // ✅ Desktop Layout (زي ما هو)
  // ===========================
  Widget _desktopLayout(PurchasesCubit purchasesCubit) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: PosProductsGrid(
            searchQuery: search,
            selectedCategory: category,
            onProductTap: addToCart,
            allowZeroStock: true,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 4,
          child: PosCartPanel<CartItem>(
            cartItems: cartItems,
            getName: (item) => item.product.name ?? '-',
            getPrice: (item) => (item.product.buyPrice ?? 0).toDouble(),
            getQuantity: (item) => item.quantity,
            getTotal: (item) => item.buyTotal,
            onRemoveItem: removeItem,
            onUpdateQuantity: updateQty,
            onClearCart: clearCart,
            checkoutLabel: 'إتمام الشراء',
            checkoutIcon: Icons.inventory_2_outlined,
            onCheckoutPressed: () {
              if (cartItems.isEmpty) return;

              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: purchasesCubit,
                  child: PurchaseCheckoutDialog(
                    cartItems: cartItems,
                    total: total(),
                    onSuccessClearCart: clearCart,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================
  // ✅ Mobile Layout
  // ===========================
  Widget _mobileLayout(PurchasesCubit purchasesCubit) {
    return PosProductsGrid(
      searchQuery: search,
      selectedCategory: category,
      onProductTap: addToCart,
      allowZeroStock: true,
    );
  }

  // ===========================
  // ✅ Cart BottomSheet للموبايل
  // ===========================
  void _openCartBottomSheet(BuildContext context, PurchasesCubit purchasesCubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return Column(
                children: [
                  // ✅ handle
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  Expanded(
                    child: PosCartPanel<CartItem>(
                      cartItems: cartItems,
                      getName: (item) => item.product.name ?? '-',
                      getPrice: (item) => (item.product.buyPrice ?? 0).toDouble(),
                      getQuantity: (item) => item.quantity,
                      getTotal: (item) => item.buyTotal,
                      onRemoveItem: removeItem,
                      onUpdateQuantity: updateQty,
                      onClearCart: clearCart,
                      checkoutLabel: 'إتمام الشراء',
                      checkoutIcon: Icons.inventory_2_outlined,
                      onCheckoutPressed: () {
                        if (cartItems.isEmpty) return;

                        Navigator.pop(context); // ✅ اقفل الـ sheet

                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: purchasesCubit,
                            child: PurchaseCheckoutDialog(
                              cartItems: cartItems,
                              total: total(),
                              onSuccessClearCart: clearCart,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
