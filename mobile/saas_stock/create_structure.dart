// import 'dart:io';

// void main() {
//   createFolderStructure();
// }

// void createFolderStructure() {
//   final basePath = 'lib';

//   final folders = [
//     // ============================================
//     // CORE - الأساسيات المشتركة
//     // ============================================
//     'core/database',              // SQLite setup & migrations
//     'core/di',                    // Dependency Injection (GetIt)
//     'core/widgets',               // Shared widgets
//     'core/theme',                 // App theme & colors
//     'core/utils',                 // Helpers, constants, extensions
//     'core/errors',                // Error handling
//     'core/routing',               // App routes
//     'core/services',              // Shared services (API, storage, etc.)

//     // ============================================
//     // FEATURES - الميزات الرئيسية
//     // ============================================
    
//     // Dashboard - الصفحة الرئيسية
//     'features/dashboard/data/models',
//     'features/dashboard/data/datasources',
//     'features/dashboard/data/repositories',
//     'features/dashboard/logic',
//     'features/dashboard/ui/screens',
//     'features/dashboard/ui/widgets',

//     // Auth - تسجيل الدخول والمصادقة
//     'features/auth/data/models',
//     'features/auth/data/datasources',
//     'features/auth/data/repositories',
//     'features/auth/logic',
//     'features/auth/ui/screens',
//     'features/auth/ui/widgets',

//     // Products - المنتجات
//     'features/products/data/models',
//     'features/products/data/datasources',
//     'features/products/data/repositories',
//     'features/products/logic',
//     'features/products/ui/screens',
//     'features/products/ui/widgets',

//     // Sales - المبيعات والفواتير
//     'features/sales/data/models',
//     'features/sales/data/datasources',
//     'features/sales/data/repositories',
//     'features/sales/logic',
//     'features/sales/ui/screens',
//     'features/sales/ui/widgets',

//     // Purchases - المشتريات
//     'features/purchases/data/models',
//     'features/purchases/data/datasources',
//     'features/purchases/data/repositories',
//     'features/purchases/logic',
//     'features/purchases/ui/screens',
//     'features/purchases/ui/widgets',

//     // Returns - المرتجعات
//     'features/returns/data/models',
//     'features/returns/data/datasources',
//     'features/returns/data/repositories',
//     'features/returns/logic',
//     'features/returns/ui/screens',
//     'features/returns/ui/widgets',

//     // Barcode - طباعة الباركود
//     'features/barcode/data/models',
//     'features/barcode/data/datasources',
//     'features/barcode/data/repositories',
//     'features/barcode/logic',
//     'features/barcode/ui/screens',
//     'features/barcode/ui/widgets',

//     // Reports - التقارير والأرباح
//     'features/reports/data/models',
//     'features/reports/data/datasources',
//     'features/reports/data/repositories',
//     'features/reports/logic',
//     'features/reports/ui/screens',
//     'features/reports/ui/widgets',

//     // Customers - العملاء والموردين
//     'features/customers/data/models',
//     'features/customers/data/datasources',
//     'features/customers/data/repositories',
//     'features/customers/logic',
//     'features/customers/ui/screens',
//     'features/customers/ui/widgets',

//     // Inventory - إدارة المخزون والجرد
//     'features/inventory/data/models',
//     'features/inventory/data/datasources',
//     'features/inventory/data/repositories',
//     'features/inventory/logic',
//     'features/inventory/ui/screens',
//     'features/inventory/ui/widgets',

//     // Cash Register - الخزينة وحركة النقد
//     'features/cash_register/data/models',
//     'features/cash_register/data/datasources',
//     'features/cash_register/data/repositories',
//     'features/cash_register/logic',
//     'features/cash_register/ui/screens',
//     'features/cash_register/ui/widgets',

//     // Expenses - المصروفات
//     'features/expenses/data/models',
//     'features/expenses/data/datasources',
//     'features/expenses/data/repositories',
//     'features/expenses/logic',
//     'features/expenses/ui/screens',
//     'features/expenses/ui/widgets',

//     // Users - إدارة المستخدمين والصلاحيات
//     'features/users/data/models',
//     'features/users/data/datasources',
//     'features/users/data/repositories',
//     'features/users/logic',
//     'features/users/ui/screens',
//     'features/users/ui/widgets',

//     // Settings - الإعدادات
//     'features/settings/data/models',
//     'features/settings/data/datasources',
//     'features/settings/data/repositories',
//     'features/settings/logic',
//     'features/settings/ui/screens',
//     'features/settings/ui/widgets',

//     // Backup - النسخ الاحتياطي
//     'features/backup/data/models',
//     'features/backup/data/datasources',
//     'features/backup/data/repositories',
//     'features/backup/logic',
//     'features/backup/ui/screens',
//     'features/backup/ui/widgets',
//   ];

//   print('🚀 Starting folder structure creation...\n');

//   int createdCount = 0;
//   int existedCount = 0;

//   for (var folder in folders) {
//     final dir = Directory('$basePath/$folder');
//     if (!dir.existsSync()) {
//       dir.createSync(recursive: true);
//       print('✅ Created: ${dir.path}');
//       createdCount++;
//     } else {
//       print('⚠️  Already exists: ${dir.path}');
//       existedCount++;
//     }
//   }

//   print('\n' + '='*50);
//   print('✨ Folder structure creation completed!');
//   print('📁 Created: $createdCount folders');
//   print('📂 Already existed: $existedCount folders');
//   print('📊 Total: ${folders.length} folders');
//   print('='*50);
  
//   print('\n💡 Next steps:');
//   print('   1. Create main.dart');
//   print('   2. Setup routing in core/routing/');
//   print('   3. Create theme files in core/theme/');
//   print('   4. Start building UI screens');
// }
