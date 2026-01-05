import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/products/data/models/add_category_request_body.dart';
import 'package:saas_stock/features/products/data/repositories/category_repo.dart';
import 'package:saas_stock/features/products/logic/category/states.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepo categoryRepo;

  CategoryCubit(this.categoryRepo) : super(CategoryInitial());

  final TextEditingController categoryNameController = TextEditingController();

  // ✅ قائمة الفئات مع الـ IDs
  Map<String, String> categoriesMap = {
    // 'category_id': 'category_name'
  };

  // ✅ Helper للحصول على الأسماء فقط
  List<String> get categoryNames => categoriesMap.values.toList();

  // ✅ Helper للحصول على ID
  String? getCategoryId(String categoryName) {
    return categoriesMap.entries
        .firstWhere(
          (entry) => entry.value == categoryName,
          orElse: () => const MapEntry('', ''),
        )
        .key;
  }

  // ✅ دالة جلب كل الفئات
  Future<void> getAllCategories() async {
    emit(CategoryLoading());

    final response = await categoryRepo.getAllCategories();

    response.when(
      success: (categories) {
        // ✅ تحديث الـ Map
        categoriesMap.clear();
        for (var cat in categories) {
          if (cat.id != null && cat.name != null) {
            categoriesMap[cat.id!] = cat.name!;
          }
        }
        emit(CategoriesLoaded(categories)); // ✅ حالة جديدة
      },
      failure: (error) {
        emit(CategoryError(error.apiErrorModel.message ?? 'فشل تحميل الفئات'));
      },
    );
  }


  Future<void> addCategory(String categoryName) async {
    if (state is CategoryLoading) return;

    emit(CategoryLoading());

    final name = categoryName.trim();

    if (name.isEmpty) {
      emit(CategoryError('اسم الفئة مطلوب'));
      return;
    }

    if (name.length < 2) {
      emit(CategoryError('اسم الفئة يجب أن يكون حرفين على الأقل'));
      return;
    }

    // ✅ التحقق من عدم التكرار
    if (categoryNames.any((cat) => cat.toLowerCase() == name.toLowerCase())) {
      emit(CategoryError('هذه الفئة موجودة بالفعل'));
      return;
    }

    final response = await categoryRepo.addCategory(
      AddCategoryRequestBody(name: name),
    );

    response.when(
      success: (categoryResponse) {
        final categoryId = categoryResponse.categoryId ?? '';
        final message = categoryResponse.message ?? 'تمت إضافة الفئة بنجاح';

        // ✅ إضافة للـ Map
        categoriesMap[categoryId] = name;

        emit(CategoryAdded(
          categoryId: categoryId,
          categoryName: name,
          message: message,
        ));

        categoryNameController.clear();
      },
      failure: (error) {
        emit(CategoryError(
          error.apiErrorModel.message ?? 'حدث خطأ في إضافة الفئة',
        ));
      },
    );
  }

  @override
  Future<void> close() {
    categoryNameController.dispose();
    return super.close();
  }
}
