import 'package:saas_stock/features/products/data/models/product_model.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}
class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  ProductsLoaded(this.products);
}

class ProductsError extends ProductsState {
  final String error;
  ProductsError(this.error);
}

// Add Product States
class AddProductLoading extends ProductsState {}

class ProductAdded extends ProductsState {
  final String productId;
  final String message;
  ProductAdded({required this.productId, required this.message});
}

class AddProductError extends ProductsState {
  final String error;
  AddProductError(this.error);
}

// Product Details States
class ProductDetailsLoading extends ProductsState {}

class ProductDetailsLoaded extends ProductsState {
  final ProductModel product;
  ProductDetailsLoaded(this.product);
}

class ProductDetailsError extends ProductsState {
  final String error;
  ProductDetailsError(this.error);
}

// Delete Product States
class ProductDeleting extends ProductsState {}

class ProductDeleted extends ProductsState {
  final String message;
  ProductDeleted(this.message);
}

class ProductDeleteError extends ProductsState {
  final String error;
  ProductDeleteError(this.error);
}

// ✅ Edit Product States (NEW)
class EditProductLoading extends ProductsState {}

class ProductUpdated extends ProductsState {
  final String message;
  final Map<String, dynamic>? updated;
  ProductUpdated({required this.message, this.updated});
}

class EditProductError extends ProductsState {
  final String error;
  EditProductError(this.error);
}

// =================== Delete OTP Flow States ===================
class DeleteOtpSending extends ProductsState {}

class DeleteOtpSent extends ProductsState {
  final String message;
  DeleteOtpSent(this.message);
}

class DeleteOtpSendError extends ProductsState {
  final String error;
  DeleteOtpSendError(this.error);
}

class DeleteConfirmLoading extends ProductsState {}

class DeleteConfirmed extends ProductsState {
  final String message;
  final String productId;
  DeleteConfirmed({required this.message, required this.productId});
}

class DeleteConfirmError extends ProductsState {
  final String error;
  DeleteConfirmError(this.error);
}
