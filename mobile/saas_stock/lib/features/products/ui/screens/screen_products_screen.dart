import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/routing/routers.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/products/logic/product/products_states.dart';
import 'package:saas_stock/features/products/ui/widgets/products_header.dart';
import 'package:saas_stock/features/products/ui/widgets/products_table.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    // final salesCubit = context.read<SalesCubit>();
    final productsCubit = context.read<ProductsCubit>();
    return BlocProvider.value(
      value: productsCubit, // ✅ استخدام الـ Singleton
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المنتجات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                productsCubit.getAllProducts();
              },
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: BlocListener<ProductsCubit, ProductsState>(
          listener: (context, state) {
            // ✅ معالجة أخطاء Products
            if (state is DeleteOtpSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is DeleteOtpSendError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is DeleteConfirmError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is DeleteConfirmed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Row(
            children: [
              if (isDesktop) const SizedBox(width: 0),
              Expanded(
                child: Column(
                  children: [
                    const ProductsHeader(),
                    const SizedBox(height: 12),
                    // ProductsToolbar(),
                    UniversalFormField(
                      hintText: 'ابحث باسم المنتج، الباركود، أو الصنف...',
                      prefixIcon: const Icon(Icons.search),
                      onChanged: (value) {
                        context.read<ProductsCubit>().searchProducts(value);
                      },
                    ),
                    const Divider(height: 1),
                    const Expanded(child: ProductsTable()),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, Routers.addProduct);
            // ✅ مش محتاج await لأن الـ Cubit Singleton هيتحدث تلقائياً
          },
          backgroundColor: const Color(0xFF7C3AED),
          icon: const Icon(Icons.add),
          label: const Text('إضافة منتج'),
        ),
      ),
    );
  }
}
