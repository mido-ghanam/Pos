// core/routing/routers.dart

class Routers {
  // ===== Auth Routes =====
  static const String splashScreen = '/';
  static const String login = '/login';
  static const String register = '/register';

  // ===== OTP Verification =====
  static const String otp = '/otp';

  // ===== Navigation Routes =====
  static const String home = '/home';

  // ===== Dashboard =====
  static const String dashboard = '/dashboard';

  // ===== Products Management =====
  static const String products = '/products';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';

  // ===== Sales & Invoices =====
  static const String sales = '/sales';
  static const String createInvoice = '/sales/create-invoice';
  static const String salesInvoices = '/salesInvoices';


  // ===== Purchases =====
  static const String purchases = '/purchases';

  // ===== Returns =====
  static const String returns = '/returns';

  static const String suppliers = '/suppliers';
  static const String addSupplier = '/suppliers/add';
  // ===== Barcode =====
  static const String barcode = '/barcode';

  // ===== Reports =====
  static const String reports = '/reports';

  // ===== Customers & Suppliers =====
  static const String customers = '/customers';

  // ===== Inventory Management =====
  static const String inventory = '/inventory';

  // ===== Cash Register =====
  static const String cashRegister = '/cash-register';

  // ===== Expenses =====
  static const String expenses = '/expenses';

  // ===== Users Management =====
  static const String users = '/users';

  // ===== Settings =====
  static const String settings = '/settings';

  // ===== Backup =====
  static const String backup = '/backup';
}
