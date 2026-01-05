import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/products/logic/category/cubit.dart';
import 'package:saas_stock/features/products/logic/category/states.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/products/logic/product/products_states.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final ProductsCubit productsCubit;
  late final CategoryCubit categoryCubit;

  @override
  void initState() {
    super.initState();

    productsCubit = context.read<ProductsCubit>(); // ✅ global من main
    categoryCubit = getIt<CategoryCubit>(); // ✅ local للصفحة

    categoryCubit.getAllCategories();

    if (widget.productId != null) {
      productsCubit.getProductDetails(widget.productId!);
    } else {
      productsCubit.clearControllers();
    }
  }

  @override
  void dispose() {
    categoryCubit.close(); // ✅ مهم عشان ده local
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: productsCubit),
        BlocProvider.value(value: categoryCubit),
      ],
      child: BlocListener<ProductsCubit, ProductsState>(
        listenWhen: (prev, curr) {
          return curr is AddProductError ||
              curr is ProductAdded ||
              curr is ProductUpdated ||
              curr is EditProductError ||
              curr is ProductDetailsLoaded;
        },
        listener: (context, state) {
          // ✅ Errors
          if (state is AddProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state is EditProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // ✅ Add Success
          if (state is ProductAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            productsCubit.getAllProducts();

            Future.delayed(const Duration(milliseconds: 250), () {
              if (mounted) {
                Navigator.pop(context, true);
              }
            });
          }

          // ✅ Update Success
          if (state is ProductUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            productsCubit.getAllProducts();

            Future.delayed(const Duration(milliseconds: 250), () {
              if (mounted) Navigator.pop(context, true);
            });
          }

          // ✅ Fill controllers on details loaded
          if (state is ProductDetailsLoaded) {
            // controllers already filled inside cubit (your _fillControllersWithProduct)
            setState(() {});
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? 'تعديل المنتج' : 'إضافة منتج جديد'),
          ),
          body: BlocBuilder<ProductsCubit, ProductsState>(
            buildWhen: (prev, curr) {
              return curr is ProductDetailsLoading ||
                  curr is ProductDetailsLoaded ||
                  curr is ProductDetailsError ||
                  curr is AddProductLoading ||
                  curr is EditProductLoading;
            },
            builder: (context, state) {
              if (state is ProductDetailsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                );
              }

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.pagePadding(context),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveHelper.maxContentWidth(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionCard(
                            title: 'المعلومات الأساسية',
                            icon: Icons.info_outline,
                            child: isDesktop
                                ? _buildBasicInfoDesktop()
                                : _buildBasicInfoMobile(),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: 'الأسعار والمخزون',
                            icon: Icons.attach_money,
                            child: isDesktop
                                ? _buildPricingDesktop()
                                : _buildPricingMobile(),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: 'إعدادات إضافية',
                            icon: Icons.settings,
                            child: _buildSettings(),
                          ),
                          const SizedBox(height: 24),
                          _buildActionButtons(isEdit),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =================== Basic Info Mobile ===================
  Widget _buildBasicInfoMobile() {
    return Column(
      children: [
        UniversalFormField(
          controller: productsCubit.nameController,
          hintText: 'اسم المنتج',
          prefixIcon: const Icon(Icons.shopping_bag),
          validator: (value) => (value == null || value.isEmpty)
              ? 'من فضلك أدخل اسم المنتج'
              : null,
        ),
        const SizedBox(height: 12),
        UniversalFormField(
          controller: productsCubit.barcodeController,
          hintText: 'الباركود',
          prefixIcon: const Icon(Icons.barcode_reader),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'من فضلك أدخل الباركود';
            if (int.tryParse(value) == null) return 'الباركود يجب أن يكون رقم';
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: UniversalFormField(
                controller: productsCubit.categoryController,
                hintText: 'التصنيف',
                prefixIcon: const Icon(Icons.category),
                readOnly: true,
                onTap: () => _showCategoriesDialog(),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'من فضلك اختر التصنيف'
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF7C3AED)),
                onPressed: () => _showAddCategoryDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        UniversalFormField(
          controller: productsCubit.descriptionController,
          hintText: 'وصف المنتج (اختياري)',
          prefixIcon: const Icon(Icons.description),
          maxLines: 3,
        ),
      ],
    );
  }

  // =================== Basic Info Desktop ===================
  Widget _buildBasicInfoDesktop() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: UniversalFormField(
                controller: productsCubit.nameController,
                hintText: 'اسم المنتج',
                prefixIcon: const Icon(Icons.shopping_bag),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'من فضلك أدخل اسم المنتج'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UniversalFormField(
                controller: productsCubit.barcodeController,
                hintText: 'الباركود',
                prefixIcon: const Icon(Icons.barcode_reader),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل الباركود';
                  if (int.tryParse(value) == null) return 'الباركود رقم فقط';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: UniversalFormField(
                      controller: productsCubit.categoryController,
                      hintText: 'التصنيف',
                      prefixIcon: const Icon(Icons.category),
                      readOnly: true,
                      onTap: () => _showCategoriesDialog(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'اختر التصنيف'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF7C3AED)),
                      onPressed: () => _showAddCategoryDialog(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        UniversalFormField(
          controller: productsCubit.descriptionController,
          hintText: 'وصف المنتج (اختياري)',
          prefixIcon: const Icon(Icons.description),
          maxLines: 3,
        ),
      ],
    );
  }

  // =================== Pricing Mobile ===================
  Widget _buildPricingMobile() {
    return Column(
      children: [
        UniversalFormField(
          controller: productsCubit.buyPriceController,
          hintText: 'سعر الشراء',
          prefixIcon: const Icon(Icons.shopping_cart),
          suffixText: 'ج.م',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'أدخل سعر الشراء';
            if (double.tryParse(value) == null) return 'رقم صحيح فقط';
            return null;
          },
        ),
        const SizedBox(height: 12),
        UniversalFormField(
          controller: productsCubit.sellPriceController,
          hintText: 'سعر البيع',
          prefixIcon: const Icon(Icons.sell),
          suffixText: 'ج.م',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'أدخل سعر البيع';
            if (double.tryParse(value) == null) return 'رقم صحيح فقط';
            return null;
          },
        ),
        const SizedBox(height: 12),
        UniversalFormField(
          controller: productsCubit.quantityController,
          hintText: 'الكمية الحالية',
          prefixIcon: const Icon(Icons.inventory),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'أدخل الكمية';
            if (double.tryParse(value) == null) return 'رقم صحيح فقط';
            return null;
          },
        ),
        const SizedBox(height: 12),
        UniversalFormField(
          controller: productsCubit.minQuantityController,
          hintText: 'الحد الأدنى للمخزون',
          prefixIcon: const Icon(Icons.warning_amber),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'أدخل الحد الأدنى';
            if (double.tryParse(value) == null) return 'رقم صحيح فقط';
            return null;
          },
        ),
      ],
    );
  }

  // =================== Pricing Desktop ===================
  Widget _buildPricingDesktop() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: UniversalFormField(
                controller: productsCubit.buyPriceController,
                hintText: 'سعر الشراء',
                prefixIcon: const Icon(Icons.shopping_cart),
                suffixText: 'ج.م',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل سعر الشراء';
                  if (double.tryParse(value) == null) return 'رقم صحيح فقط';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UniversalFormField(
                controller: productsCubit.sellPriceController,
                hintText: 'سعر البيع',
                prefixIcon: const Icon(Icons.sell),
                suffixText: 'ج.م',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل سعر البيع';
                  if (double.tryParse(value) == null) return 'رقم صحيح فقط';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: UniversalFormField(
                controller: productsCubit.quantityController,
                hintText: 'الكمية الحالية',
                prefixIcon: const Icon(Icons.inventory),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل الكمية';
                  if (double.tryParse(value) == null) return 'رقم صحيح فقط';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UniversalFormField(
                controller: productsCubit.minQuantityController,
                hintText: 'الحد الأدنى للمخزون',
                prefixIcon: const Icon(Icons.warning_amber),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل الحد الأدنى';
                  if (double.tryParse(value) == null) return 'رقم صحيح فقط';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('منتج نشط'),
          subtitle: const Text('هل المنتج متاح للبيع؟'),
          value: productsCubit.isActive,
          activeColor: const Color(0xFF7C3AED),
          onChanged: (v) => setState(() => productsCubit.toggleActive(v)),
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('تتبع المخزون'),
          subtitle: const Text('تفعيل تتبع الكمية المتاحة'),
          value: productsCubit.trackStock,
          activeColor: const Color(0xFF7C3AED),
          onChanged: (v) => setState(() => productsCubit.toggleTrackStock(v)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isEdit) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      buildWhen: (prev, curr) =>
          curr is AddProductLoading ||
          curr is EditProductLoading ||
          curr is AddProductError ||
          curr is EditProductError ||
          curr is ProductAdded ||
          curr is ProductUpdated,
      builder: (context, state) {
        final isLoading =
            state is AddProductLoading || state is EditProductLoading;

        return Row(
          children: [
            Expanded(
              child: AppTextButton(
                buttonText: isEdit ? 'حفظ التعديلات' : 'إضافة المنتج',
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: const Color(0xFF7C3AED),
                isLoading: isLoading,
                onPressed: isLoading
                    ? () {}
                    : () {
                        if (_formKey.currentState!.validate()) {
                          if (isEdit) {
                            productsCubit.editProduct(widget.productId!);
                          } else {
                            productsCubit.addProduct();
                          }
                        }
                      },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextButton(
                buttonText: 'إلغاء',
                textStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.grey[200],
                onPressed: isLoading ? () {} : () => Navigator.pop(context),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCategoriesDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: categoryCubit,
          child: BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              final isLoading = state is CategoryLoading &&
                  categoryCubit.categoryNames.isEmpty;

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('اختر التصنيف'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: categoryCubit.categoryNames.length,
                          itemBuilder: (context, index) {
                            final categoryName =
                                categoryCubit.categoryNames[index];
                            return ListTile(
                              title: Text(categoryName),
                              onTap: () {
                                setState(() {
                                  productsCubit.categoryController.text =
                                      categoryName;
                                  productsCubit.selectedCategoryId =
                                      categoryCubit.getCategoryId(categoryName);
                                });
                                Navigator.pop(dialogContext);
                              },
                            );
                          },
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: categoryCubit,
          child: BlocConsumer<CategoryCubit, CategoryState>(
            listener: (context, state) {
              if (state is CategoryAdded) {
                setState(() {
                  productsCubit.categoryController.text = state.categoryName;
                  productsCubit.selectedCategoryId = state.categoryId;
                });
                Navigator.pop(dialogContext);
              }
            },
            builder: (context, state) {
              final isLoading = state is CategoryLoading;

              return AlertDialog(
                title: const Text('إضافة فئة جديدة'),
                content: TextField(
                  controller: categoryCubit.categoryNameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'اسم الفئة',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isLoading ? null : () => Navigator.pop(dialogContext),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final name = categoryCubit
                                .categoryNameController.text
                                .trim();
                            if (name.isNotEmpty) {
                              categoryCubit.addCategory(name);
                            }
                          },
                    child: Text(isLoading ? 'جاري...' : 'إضافة'),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF7C3AED)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
