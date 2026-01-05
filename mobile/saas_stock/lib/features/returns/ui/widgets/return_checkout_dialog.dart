import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/customers/logic/states.dart';
import 'package:saas_stock/features/returns/logic/states.dart';
import 'package:saas_stock/features/returns/ui/widgets/return_invoice_dialog.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/logic/states.dart';
import 'package:saas_stock/features/returns/logic/cubit.dart';
import 'package:saas_stock/features/returns/data/models/create_refund_request.dart';
import 'return_cart_panel.dart';

class ReturnCheckoutDialog extends StatefulWidget {
  final String returnType; // sale/purchase
  final List<ReturnCartItem> cartItems;
  final double total;
  final dynamic selectedParty;
  final Function(dynamic) onSelectParty;

  const ReturnCheckoutDialog({
    super.key,
    required this.returnType,
    required this.cartItems,
    required this.total,
    required this.selectedParty,
    required this.onSelectParty,
  });

  @override
  State<ReturnCheckoutDialog> createState() => _ReturnCheckoutDialogState();
}

class _ReturnCheckoutDialogState extends State<ReturnCheckoutDialog> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReturnsCubit, ReturnsState>(
      listenWhen: (p, c) => c is CreateRefundSuccess || c is CreateRefundError,
      listener: (context, state) async {
        if (state is CreateRefundSuccess) {
          // ✅ اقفل الـ checkout dialog بأمان
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          // ✅ اعرض الفاتورة بعد ما يقفل
          await Future.delayed(const Duration(milliseconds: 150));

          if (!context.mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ReturnInvoiceDialog(invoice: state.invoice),
          );
        }

        if (state is CreateRefundError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is CreateRefundLoading;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 560,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _header(context),
                  const Divider(height: 28),
                  _totalBox(),
                  const SizedBox(height: 14),
                  widget.returnType == "sale"
                      ? _customerSection()
                      : _supplierSection(),
                  const SizedBox(height: 18),
                  _itemsPreview(),
                  const SizedBox(height: 18),
                  AppTextButton(
                    buttonText: "تأكيد المرتجع",
                    textStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    backgroundColor: const Color(0xFFFB7185),
                    icon: Icons.check_circle,
                    onPressed: () => _submit(context),
                  ),
                  const SizedBox(height: 10),
                  AppTextButton(
                    buttonText: "إلغاء",
                    textStyle: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                    backgroundColor: Colors.grey[200],
                    icon: Icons.close,
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFB7185).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.undo, color: Color(0xFFFB7185)),
        ),
        const SizedBox(width: 10),
        Text(
          widget.returnType == "sale" ? "مرتجع مبيعات" : "مرتجع مشتريات",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        color: const Color(0xFFFB7185).withOpacity(0.08),
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
              color: Color(0xFFFB7185),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerSection() {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final cubit = context.read<CustomersCubit>();

        if (state is CustomersLoading) {
          return _infoBox("جاري تحميل العملاء...", loading: true);
        }
        if (state is CustomersError) {
          return _errorBox(state.message.toString(),
              onRetry: cubit.fetchCustomers);
        }

        final customers = cubit.customers;
        if (customers.isEmpty) {
          return _infoBox("لا يوجد عملاء.", warning: true);
        }

        return DropdownButtonFormField<dynamic>(
          value: widget.selectedParty,
          decoration: InputDecoration(
            hintText: "اختر العميل",
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: customers.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(c.name ?? '-'),
            );
          }).toList(),
          onChanged: (v) => widget.onSelectParty(v),
        );
      },
    );
  }

  Widget _supplierSection() {
    return BlocBuilder<SuppliersCubit, SuppliersState>(
      builder: (context, state) {
        final cubit = context.read<SuppliersCubit>();

        if (state is SuppliersLoading) {
          return _infoBox("جاري تحميل الموردين...", loading: true);
        }
        if (state is SuppliersError) {
          return _errorBox(state.message, onRetry: cubit.fetchSuppliers);
        }

        final suppliers = cubit.suppliers;
        if (suppliers.isEmpty) {
          return _infoBox("لا يوجد موردين.", warning: true);
        }

        return DropdownButtonFormField<dynamic>(
          value: widget.selectedParty,
          decoration: InputDecoration(
            hintText: "اختر المورد",
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: suppliers.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s.companyName ?? s.personName ?? '-'),
            );
          }).toList(),
          onChanged: (v) => widget.onSelectParty(v),
        );
      },
    );
  }

  Widget _itemsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("المنتجات", style: TextStyle(fontWeight: FontWeight.bold)),
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
                subtitle: Text("x${e.quantity}"),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  void _submit(BuildContext context) {
    if (widget.selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("اختار الطرف الأول"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final partyId = widget.selectedParty.id;

    final req = CreateRefundRequest(
      returnType: widget.returnType,
      partyId: partyId,
      products: widget.cartItems
          .map((e) => CreateRefundProduct(
                productId: e.product.id!,
                quantity: e.quantity,
              ))
          .toList(),
    );

    context.read<ReturnsCubit>().createRefund(req);

    // Navigator.of(context, rootNavigator: true).pop(); // close checkout safely
  }

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
                child: CircularProgressIndicator(strokeWidth: 2))
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
          Expanded(
              child: Text(text, style: const TextStyle(color: Colors.red))),
          TextButton(onPressed: onRetry, child: const Text("إعادة المحاولة")),
        ],
      ),
    );
  }
}
