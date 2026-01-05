import 'package:saas_stock/features/products/data/models/get_all_categories_response.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}
class CategoryLoading extends CategoryState {}

// ✅ حالة التحميل الناجح
class CategoriesLoaded extends CategoryState {
  final List<CategoryModel> categories;
  CategoriesLoaded(this.categories);
}

class CategoryAdded extends CategoryState {
  final String categoryId;
  final String categoryName;
  final String message;

  CategoryAdded({
    required this.categoryId,
    required this.categoryName,
    required this.message,
  });
}

class CategoryError extends CategoryState {
  final String error;
  CategoryError(this.error);
}
