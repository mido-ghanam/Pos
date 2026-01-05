import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/features/purchases/data/models/create_purchase_request.dart';
import 'package:saas_stock/features/purchases/logic/cubit.dart';
import 'package:saas_stock/features/purchases/logic/states.dart';
import 'package:saas_stock/features/purchases/ui/widgets/purchase_invoice_dialog.dart';
import 'package:saas_stock/features/suppliers/data/models/supplier_model.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/logic/states.dart';
import 'package:saas_stock/features/sales/ui/widgets/pos_products_grid.dart';

class PurchaseCheckoutDialog extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;
  final VoidCallback onSuccessClearCart;

  const PurchaseCheckoutDialog({
    super.key,
    required this.cartItems,
    required this.total,
    required this.onSuccessClearCart,
  });

  @override
  State<PurchaseCheckoutDialog> createState() => _PurchaseCheckoutDialogState();
}

class _PurchaseCheckoutDialogState extends State<PurchaseCheckoutDialog> {
  String payment = 'Visa';
  SupplierModel? selectedSupplier;

  bool _invoiceShown = false;

  @override
  void initState() {
    super.initState();

    // ✅ fetch suppliers بعد اول frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final suppliersCubit = context.read<SuppliersCubit>();
      if (suppliersCubit.suppliers.isEmpty) {
        suppliersCubit.fetchSuppliers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 560 : 420,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocConsumer<PurchasesCubit, PurchasesState>(
            listenWhen: (p, c) =>
                c is CreatePurchaseSuccess || c is CreatePurchaseError,
            listener: (context, state) async {
  if (state is CreatePurchaseSuccess) {
    if (!mounted) return;

    if (_invoiceShown) return;
    _invoiceShown = true;

    final rootCtx = Navigator.of(context, rootNavigator: true).context;

    Navigator.of(context, rootNavigator: true).pop();

    await Future.delayed(const Duration(milliseconds: 120));

    widget.onSuccessClearCart();

    if (!rootCtx.mounted) return;

    showDialog(
      context: rootCtx,
      barrierDismissible: false,
      builder: (_) => PurchaseInvoiceDialog(invoice: state.invoice),
    );
  }

  if (state is CreatePurchaseError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: Colors.red,
      ),
    );
  }
},

            builder: (context, state) {
              final loading = state is CreatePurchaseLoading;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(context),
                    const Divider(height: 28),
                    _totalBox(),
                    const SizedBox(height: 14),
                    _supplierDropdownSection(),
                    const SizedBox(height: 14),
                    _paymentMethods(),
                    const SizedBox(height: 18),
                    _itemsPreview(),
                    const SizedBox(height: 18),

                    // ✅ actions responsive safe
                    _actions(isDesktop, loading),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.inventory_2, color: Color(0xFF7C3AED)),
        ),
        const SizedBox(width: 10),
        const Text(
          'إتمام عملية الشراء',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ],
    );
  }

  Widget _totalBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('الإجمالي'),
          Text(
            '${widget.total.toStringAsFixed(2)} ج.م',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supplierDropdownSection() {
    return BlocBuilder<SuppliersCubit, SuppliersState>(
      builder: (context, state) {
        final cubit = context.read<SuppliersCubit>();
        final suppliers = cubit.suppliers;

        if (state is SuppliersLoading) {
          return _infoBox('جاري تحميل الموردين...', loading: true);
        }

        if (state is SuppliersError) {
          return _errorBox(state.message, onRetry: cubit.fetchSuppliers);
        }

        if (suppliers.isEmpty) {
          return _infoBox('لا يوجد موردين في النظام.', warning: true);
        }

        // ✅ لو selectedSupplier مش في القائمة
        if (selectedSupplier != null &&
            !suppliers.any((s) => s.id == selectedSupplier!.id)) {
          selectedSupplier = null;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('المورد', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<SupplierModel>(
              value: selectedSupplier,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'اختر المورد',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: suppliers.map((s) {
                final name = (s.companyName?.isNotEmpty == true)
                    ? s.companyName!
                    : (s.personName ?? '-');
                return DropdownMenuItem(
                  value: s,
                  child: Text(
                    "$name  (${s.phone ?? ""})",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedSupplier = v),
            ),
          ],
        );
      },
    );
  }

  Widget _paymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('طريقة الدفع',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip('Cash', Icons.money),
            _chip('Visa', Icons.credit_card),
            _chip('Transfer', Icons.account_balance),
            _chip('Credit', Icons.schedule),
          ],
        ),
      ],
    );
  }

  Widget _chip(String value, IconData icon) {
    final selected = payment == value;
    return InkWell(
      onTap: () => setState(() => payment = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7C3AED)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF7C3AED)
                : Colors.grey.withOpacity(0.25),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18, color: selected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('المنتجات', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: widget.cartItems.map((e) {
              return ListTile(
                dense: true,
                title: Text(e.product.name ?? '-'),
                subtitle: Text('x${e.quantity}'),
                trailing: Text(
                  '${e.buyTotal.toStringAsFixed(2)} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _actions(bool isDesktop, bool loading) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: AppTextButton(
              buttonText: 'تأكيد الشراء',
              isLoading: loading,
              textStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              backgroundColor: const Color(0xFF7C3AED),
              icon: Icons.check_circle,
              onPressed: loading ? () {} : () => _submit(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppTextButton(
              buttonText: 'إلغاء',
              textStyle: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold),
              backgroundColor: Colors.grey[200],
              icon: Icons.close,
              onPressed:
                  loading ? () {} : () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AppTextButton(
            buttonText: 'تأكيد الشراء',
            isLoading: loading,
            textStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            backgroundColor: const Color(0xFF7C3AED),
            icon: Icons.check_circle,
            onPressed: loading ? () {} : () => _submit(context),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: AppTextButton(
            buttonText: 'إلغاء',
            textStyle: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold),
            backgroundColor: Colors.grey[200],
            icon: Icons.close,
            onPressed:
                loading ? () {} : () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ),
      ],
    );
  }

  // ================= ACTIONS =================

  void _submit(BuildContext context) {
    if (selectedSupplier == null || (selectedSupplier!.id ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختار المورد الأول'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final products = widget.cartItems.map((item) {
      return CreatePurchaseProduct(
        productId: item.product.id!,
        quantity: item.quantity,
      );
    }).toList();

    final req = CreatePurchaseRequest(
      supplierId: selectedSupplier!.id!,
      paymentMethod: payment,
      products: products,
    );

    context.read<PurchasesCubit>().createPurchase(req);
  }

  void _showInvoiceDialog(BuildContext context, invoice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('✅ تم إنشاء فاتورة شراء'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم الفاتورة: ${invoice.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('الإجمالي: ${invoice.total}'),
                const SizedBox(height: 6),
                Text('طريقة الدفع: ${invoice.paymentMethod}'),
                const SizedBox(height: 12),
                const Divider(),
                ...invoice.items.map<Widget>((i) {
                  return ListTile(
                    dense: true,
                    title: Text(i.productName),
                    subtitle: Text('x${i.quantity}'),
                    trailing: Text(i.subtotal),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('تمام'),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _infoBox(String text, {bool loading = false, bool warning = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warning ? Colors.orange.withOpacity(0.08) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(warning ? Icons.warning_amber : Icons.info_outline,
                color: warning ? Colors.orange : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _errorBox(String text, {required VoidCallback onRetry}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.red))),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
