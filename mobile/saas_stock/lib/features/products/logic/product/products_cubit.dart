import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/products/data/models/add_product_request_body.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';
import 'package:saas_stock/features/products/data/repositories/products_repo.dart';
import 'package:saas_stock/features/products/logic/product/products_states.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepo productsRepo;

  ProductsCubit(this.productsRepo) : super(ProductsInitial());

  // =================== Data Lists ===================
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];

  // =================== Controllers ===================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController buyPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // =================== State Variables ===================
  String? selectedCategoryId;
  bool isActive = true;
  bool trackStock = true;

  // =================== عرض كل المنتجات ===================
  Future<void> getAllProducts() async {
    emit(ProductsLoading());

    final response = await productsRepo.getAllProducts();

    response.when(
      success: (productsResponse) {
        products = productsResponse.data ?? [];
        filteredProducts = List.from(products);
        emit(ProductsLoaded(filteredProducts));
      },
      failure: (error) {
        emit(ProductsError(
          error.apiErrorModel.message ?? 'حدث خطأ في تحميل المنتجات',
        ));
      },
    );
  }

  // =================== البحث في المنتجات ===================
  void searchProducts(String query) {
    if (query.isEmpty) {
      filteredProducts = List.from(products);
    } else {
      filteredProducts = products.where((product) {
        final name = product.name?.toLowerCase() ?? '';
        final category = product.categoryName.toLowerCase();
        final barcode = product.barcode?.toString() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            category.contains(searchQuery) ||
            barcode.contains(searchQuery);
      }).toList();
    }
    emit(ProductsLoaded(filteredProducts));
  }

  // =================== فلترة المنتجات قليلة المخزون ===================
  void filterLowStock() {
    filteredProducts = products.where((product) {
      final qty = product.quantity ?? 0;
      final minQty = product.minQuantity ?? 0;
      return qty <= minQty;
    }).toList();
    emit(ProductsLoaded(filteredProducts));
  }

  // =================== فلترة المنتجات الموقوفة ===================
  void filterInactive() {
    filteredProducts = products.where((product) {
      return product.active == false;
    }).toList();
    emit(ProductsLoaded(filteredProducts));
  }

  // =================== فلترة حسب الفئة ===================
  void filterByCategory(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) {
      filteredProducts = List.from(products);
    } else {
      filteredProducts = products.where((product) {
        return product.categoryName.toLowerCase() == categoryName.toLowerCase();
      }).toList();
    }
    emit(ProductsLoaded(filteredProducts));
  }

  // =================== إعادة تعيين الفلاتر ===================
  void clearFilters() {
    filteredProducts = List.from(products);
    emit(ProductsLoaded(filteredProducts));
  }

// ✅ إضافة في ProductsCubit class

// =================== حذف منتج ===================
  Future<void> deleteProduct(String productId, String productName) async {
    emit(ProductDeleting());

    final response = await productsRepo.deleteProduct(productId);

    response.when(
      success: (data) {
        final message = data['message'] ?? 'تم حذف المنتج بنجاح';

        // ✅ حذف المنتج من القائمة المحلية
        products.removeWhere((p) => p.id == productId);
        filteredProducts.removeWhere((p) => p.id == productId);

        emit(ProductDeleted(message));

        // ✅ تحديث القائمة
        emit(ProductsLoaded(filteredProducts));
      },
      failure: (error) {
        emit(ProductDeleteError(
          error.apiErrorModel.message ?? 'حدث خطأ في حذف المنتج',
        ));
      },
    );
  }

  // =================== تعديل منتج ===================
  Future<void> editProduct(String productId) async {
    if (state is EditProductLoading) return;

    emit(EditProductLoading());

    final name = nameController.text.trim();
    final barcodeText = barcodeController.text.trim();
    final buyPriceText = buyPriceController.text.trim();
    final sellPriceText = sellPriceController.text.trim();
    final quantityText = quantityController.text.trim();
    final minQuantityText = minQuantityController.text.trim();

    // ✅ Validation (مختصر وواضح)
    if (name.isEmpty) {
      emit(EditProductError('اسم المنتج مطلوب'));
      return;
    }

    final barcode = int.tryParse(barcodeText);
    if (barcodeText.isEmpty || barcode == null) {
      emit(EditProductError('الباركود يجب أن يكون رقم صحيح'));
      return;
    }

    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      emit(EditProductError('التصنيف مطلوب'));
      return;
    }

    final buyPrice = double.tryParse(buyPriceText);
    if (buyPriceText.isEmpty || buyPrice == null || buyPrice <= 0) {
      emit(EditProductError('سعر الشراء يجب أن يكون رقم صحيح أكبر من صفر'));
      return;
    }

    final sellPrice = double.tryParse(sellPriceText);
    if (sellPriceText.isEmpty || sellPrice == null || sellPrice <= 0) {
      emit(EditProductError('سعر البيع يجب أن يكون رقم صحيح أكبر من صفر'));
      return;
    }

    if (sellPrice < buyPrice) {
      emit(EditProductError('سعر البيع يجب أن يكون أكبر من سعر الشراء'));
      return;
    }

    final quantity = double.tryParse(quantityText);
    if (quantityText.isEmpty || quantity == null || quantity < 0) {
      emit(EditProductError('الكمية يجب أن تكون رقم صحيح'));
      return;
    }

    final minQuantity = double.tryParse(minQuantityText);
    if (minQuantityText.isEmpty || minQuantity == null || minQuantity < 0) {
      emit(EditProductError('الحد الأدنى يجب أن يكون رقم صحيح'));
      return;
    }

    // ✅ Build request body
    final request = AddProductRequestBody(
      name: name,
      discription: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      category: selectedCategoryId!,
      barcode: barcode,
      quantity: quantity,
      minQuantity: minQuantity,
      sellPrice: sellPrice,
      buyPrice: buyPrice,
      monitor: trackStock,
      active: isActive,
    );

    final response = await productsRepo.editProduct(productId, request);

    response.when(
      success: (data) async {
        final message = data['message'] ?? 'تم تحديث المنتج بنجاح';
        final updated = data['updated'] as Map<String, dynamic>?;

        // ✅ refresh list بعد التعديل
        await getAllProducts();

        emit(ProductUpdated(message: message, updated: updated));
      },
      failure: (error) {
        emit(EditProductError(
          error.apiErrorModel.message ?? 'حدث خطأ في تحديث المنتج',
        ));
      },
    );
  }

  // =================== إضافة منتج ===================
  Future<void> addProduct() async {
    // ✅ منع إرسال طلبات متعددة
    if (state is AddProductLoading) return;

    emit(AddProductLoading());

    // =================== Validation =================== (نفس الكود)
    final name = nameController.text.trim();
    final barcodeText = barcodeController.text.trim();
    final buyPriceText = buyPriceController.text.trim();
    final sellPriceText = sellPriceController.text.trim();
    final quantityText = quantityController.text.trim();
    final minQuantityText = minQuantityController.text.trim();

    if (name.isEmpty) {
      emit(AddProductError('اسم المنتج مطلوب'));
      return;
    }

    if (name.length < 2) {
      emit(AddProductError('اسم المنتج يجب أن يكون حرفين على الأقل'));
      return;
    }

    if (barcodeText.isEmpty) {
      emit(AddProductError('الباركود مطلوب'));
      return;
    }

    final barcode = int.tryParse(barcodeText);
    if (barcode == null) {
      emit(AddProductError('الباركود يجب أن يكون رقم صحيح'));
      return;
    }

    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      emit(AddProductError('التصنيف مطلوب'));
      return;
    }

    if (buyPriceText.isEmpty) {
      emit(AddProductError('سعر الشراء مطلوب'));
      return;
    }

    final buyPrice = double.tryParse(buyPriceText);
    if (buyPrice == null) {
      emit(AddProductError('سعر الشراء يجب أن يكون رقم صحيح'));
      return;
    }

    if (buyPrice <= 0) {
      emit(AddProductError('سعر الشراء يجب أن يكون أكبر من صفر'));
      return;
    }

    if (sellPriceText.isEmpty) {
      emit(AddProductError('سعر البيع مطلوب'));
      return;
    }

    final sellPrice = double.tryParse(sellPriceText);
    if (sellPrice == null) {
      emit(AddProductError('سعر البيع يجب أن يكون رقم صحيح'));
      return;
    }

    if (sellPrice <= 0) {
      emit(AddProductError('سعر البيع يجب أن يكون أكبر من صفر'));
      return;
    }

    if (sellPrice < buyPrice) {
      emit(AddProductError('سعر البيع يجب أن يكون أكبر من سعر الشراء'));
      return;
    }

    if (quantityText.isEmpty) {
      emit(AddProductError('الكمية مطلوبة'));
      return;
    }

    final quantity = double.tryParse(quantityText);
    if (quantity == null) {
      emit(AddProductError('الكمية يجب أن تكون رقم صحيح'));
      return;
    }

    if (quantity < 0) {
      emit(AddProductError('الكمية لا يمكن أن تكون سالبة'));
      return;
    }

    if (minQuantityText.isEmpty) {
      emit(AddProductError('الحد الأدنى للمخزون مطلوب'));
      return;
    }

    final minQuantity = double.tryParse(minQuantityText);
    if (minQuantity == null) {
      emit(AddProductError('الحد الأدنى يجب أن يكون رقم صحيح'));
      return;
    }

    if (minQuantity < 0) {
      emit(AddProductError('الحد الأدنى لا يمكن أن يكون سالب'));
      return;
    }

    // =================== إرسال الطلب ===================
    final response = await productsRepo.addProduct(
      AddProductRequestBody(
        name: name,
        barcode: barcode,
        category: selectedCategoryId!,
        buyPrice: buyPrice,
        sellPrice: sellPrice,
        quantity: quantity,
        minQuantity: minQuantity,
        active: isActive,
        monitor: trackStock,
        discription: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      ),
    );

    response.when(
      success: (addProductResponse) async {
        final productId = addProductResponse.productId ?? '';
        final message = addProductResponse.message ?? 'تمت إضافة المنتج بنجاح';

        // ✅ 1. مسح الـ Controllers أولاً
        clearControllers();

        // ✅ 2. إعادة تحميل المنتجات (بدون await عشان ما تكتبش فوق ProductAdded)
        getAllProducts();

        // ✅ 3. بعدين emit للنجاح (الترتيب مهم!)
        emit(ProductAdded(productId: productId, message: message));
      },
      failure: (error) {
        emit(AddProductError(
          error.apiErrorModel.message ?? 'حدث خطأ في إضافة المنتج',
        ));
      },
    );
  }

  // =================== عرض تفاصيل منتج ===================
  Future<void> getProductDetails(String productId) async {
    emit(ProductDetailsLoading());

    final response = await productsRepo.getProductDetails(productId);

    response.when(
      success: (productResponse) {
        if (productResponse.data != null && productResponse.data!.isNotEmpty) {
          final product = productResponse.data!.first;

          // ✅ تعبئة الـ Controllers للتعديل
          _fillControllersWithProduct(product);

          emit(ProductDetailsLoaded(product));
        } else {
          emit(ProductDetailsError('لم يتم العثور على المنتج'));
        }
      },
      failure: (error) {
        emit(ProductDetailsError(
          error.apiErrorModel.message ?? 'حدث خطأ في تحميل التفاصيل',
        ));
      },
    );
  }

 // =================== Delete OTP Flow ===================

// 1) Request OTP
Future<void> requestDeleteOtp(String productId) async {
  emit(DeleteOtpSending());

  final res = await productsRepo.requestDeleteOtp(productId);

  res.when(
    success: (data) {
      emit(DeleteOtpSent(data["message"] ?? "تم إرسال OTP"));
    },
    failure: (err) {
      emit(DeleteOtpSendError(
        err.apiErrorModel.message ?? "فشل إرسال OTP",
      ));
    },
  );
}

// 2) Confirm Delete
Future<void> confirmDeleteProduct({
  required String productId,
  required String otp,
}) async {
  emit(DeleteConfirmLoading());

  final res = await productsRepo.confirmDeleteOtp(
    productId: productId,
    otp: otp,
  );

  res.when(
    success: (data) async {
      final msg = data["message"] ?? "تم حذف المنتج بنجاح";

      // ✅ امسح المنتج محليًا بعد الحذف الحقيقي فقط
      products.removeWhere((p) => p.id == productId);
      filteredProducts.removeWhere((p) => p.id == productId);

      emit(DeleteConfirmed(message: msg, productId: productId));

      // ✅ حدث واجهة المنتجات
      emit(ProductsLoaded(filteredProducts));
    },
    failure: (err) {
      emit(DeleteConfirmError(
        err.apiErrorModel.message ?? "فشل تأكيد الحذف",
      ));
    },
  );
}

  // =================== تعبئة Controllers للتعديل ===================
  void _fillControllersWithProduct(ProductModel product) {
    nameController.text = product.name ?? '';
    barcodeController.text = product.barcode?.toString() ?? '';
    categoryController.text = product.categoryName;
    buyPriceController.text = product.buyPrice?.toString() ?? '';
    sellPriceController.text = product.sellPrice?.toString() ?? '';
    quantityController.text = product.quantity?.toString() ?? '';
    minQuantityController.text = product.minQuantity?.toString() ?? '';
    descriptionController.text = product.discription ?? '';

    selectedCategoryId = product.categoryId;
    isActive = product.active ?? true;
    trackStock = product.monitor ?? true;
  }

  // =================== Toggle Functions ===================
  void toggleActive(bool value) {
    isActive = value;
    // ✅ لا داعي لـ emit هنا، الـ UI هيستخدم setState
  }

  void toggleTrackStock(bool value) {
    trackStock = value;
    // ✅ لا داعي لـ emit هنا، الـ UI هيستخدم setState
  }

  // =================== مسح Controllers ===================
  void clearControllers() {
    nameController.clear();
    barcodeController.clear();
    categoryController.clear();
    buyPriceController.clear();
    sellPriceController.clear();
    quantityController.clear();
    minQuantityController.clear();
    descriptionController.clear();

    selectedCategoryId = null;
    isActive = true;
    trackStock = true;
  }

  // =================== Statistics Helpers ===================
  int get totalProducts => products.length;

  int get activeProducts => products.where((p) => p.active == true).length;

  int get inactiveProducts => products.where((p) => p.active == false).length;

  int get lowStockProducts => products.where((p) {
        final qty = p.quantity ?? 0;
        final minQty = p.minQuantity ?? 0;
        return qty <= minQty;
      }).length;

  double get totalInventoryValue => products.fold(
        0.0,
        (sum, p) => sum + ((p.buyPrice ?? 0) * (p.quantity ?? 0)),
      );

  double get totalSaleValue => products.fold(
        0.0,
        (sum, p) => sum + ((p.sellPrice ?? 0) * (p.quantity ?? 0)),
      );

  double get expectedProfit => totalSaleValue - totalInventoryValue;

  // =================== Dispose ===================
  @override
  Future<void> close() {
    nameController.dispose();
    barcodeController.dispose();
    categoryController.dispose();
    buyPriceController.dispose();
    sellPriceController.dispose();
    quantityController.dispose();
    minQuantityController.dispose();
    descriptionController.dispose();
    return super.close();
  }
}
