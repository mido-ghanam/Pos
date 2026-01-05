class ApiConstants {
  static const String apiBaseUrl = 'https://pos.tests.midoghanam.site';

  // Auth
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String me = '/auth/me/';
  static const String changePassword = '/auth/change-password/';
  static const String refreshToken = '/auth/token/refresh/';

  // OTP
  static const String loginVerify = '/auth/login/verify/';
  static const String registerVerify = '/auth/register/verify/';
  static const String loginResendOtp = '/auth/login/verify/resendOTP/';
  static const String registerResendOtp = '/auth/register/verify/resendOTP/';

  // ================= Customers =================
  static const String customers = '/partners/customers/';
  static const String registerCustomer = '/partners/customers/register/';
  static const String verifyCustomerOtp =
      '/partners/customers/register_verify/';
  static String updateCustomer(String id) => '/partners/customers/update/$id/';

  // Suppliers
  static const String getAllSuppliers = '/partners/suppliers/';
  static const String registerSupplier = '/partners/suppliers/register/';
  static const String registerSupplierVerify =
      '/partners/suppliers/register_verify/';
  static const String updateSupplier =
      '/partners/suppliers/update/'; // + id + '/'

  // Categories
  static const String getAllCategories = '/products/categories/get/all/';
  static const String addCategory = '/products/categories/add/';
  static const String deleteCategory = '/products/categories/delete/';

  // Products
  static const String addProduct = '/products/add/';
  static const String getAllProducts = '/products/get/all/';
  static const String getProductDetails = '/products/get/';
  static const String deleteProduct = '/products/delete/';
  static const String deleteProductConfirm =
      '/products/delete/confirm/'; // ✅ NEW
  static const String editProduct = '/products/edit/';
  // Products


  // =================== Billing / Sales ===================
  static const String createSale = '/billing/sales/create/';
  static const String getSales = '/billing/sales/';
  static String getSaleDetails(int id) => '/billing/sales/$id/';

  // Purchases
  static const String purchasesList = '/billing/purchases/';
  static const String createPurchase = '/billing/purchases/create/';
  static String purchaseDetails(int id) => '/billing/purchases/$id/';

  static const String refundsList = '/billing/returns/';
  static const String createRefund = '/billing/returns/create/';
  // Sales invoices by customer
  static String salesByCustomer(String id) => "/billing/sales/customer/$id/";

// Purchases invoices by supplier
  static String purchasesBySupplier(String id) =>
      "/billing/purchases/supplier/$id/";
  static const String billingDashboard = '/billing/dashboard/';

// =================== Billing Stats ===================
  static const String salesStats = '/billing/sales/stats/';
  static const String purchasesStats = '/billing/purchases/stats/';
}

class ApiErrors {
  static const String badRequestError = "badRequestError";
  static const String noContent = "noContent";
  static const String forbiddenError = "forbiddenError";
  static const String unauthorizedError = "unauthorizedError";
  static const String notFoundError = "notFoundError";
  static const String conflictError = "conflictError";
  static const String internalServerError = "internalServerError";
  static const String unknownError = "unknownError";
  static const String timeoutError = "timeoutError";
  static const String defaultError = "defaultError";
  static const String cacheError = "cacheError";
  static const String noInternetError = "noInternetError";
  static const String loadingMessage = "loading_message";
  static const String retryAgainMessage = "retry_again_message";
  static const String ok = "Ok";
}
