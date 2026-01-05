import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/features/customers/data/models/customer_model.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/customers/logic/states.dart';
import 'package:saas_stock/features/sales/data/models/create_sale_request.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/sales/logic/states.dart';
import 'package:saas_stock/features/sales/ui/widgets/sale_invoice_dialog.dart';
import 'pos_products_grid.dart';

class CheckoutDialog extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;
  final BuildContext parentContext;

  const CheckoutDialog({
    super.key,
    required this.cartItems,
    required this.total,
    required this.parentContext,
  });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  String payment = 'Cash';
  CustomerModel? selectedCustomer;

  bool _invoiceShown = false; // ✅ عشان ما يفتحش invoice مرتين

  @override
  void initState() {
    super.initState();

    /// ✅ fetch بعد أول frame → يمنع rebuild أثناء layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final customersCubit = context.read<CustomersCubit>();
      if (customersCubit.customers.isEmpty) {
        customersCubit.fetchCustomers();
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
          child: BlocConsumer<SalesCubit, SalesState>(
            listenWhen: (p, c) =>
                c is CreateSaleSuccess || c is CreateSaleError,
            listener: (context, state) async {
              if (state is CreateSaleSuccess) {
                // ✅ اقفل checkout dialog
                Navigator.of(context, rootNavigator: true).pop();

                // ✅ بعد ما يقفل افتح invoice من parentContext مش من context الداخلي
                await Future.delayed(const Duration(milliseconds: 120));

                if (!widget.parentContext.mounted) return;

                showDialog(
                  context: widget.parentContext,
                  barrierDismissible: false,
                  builder: (_) => SaleInvoiceDialog(sale: state.sale),
                );
              }

              if (state is CreateSaleError) {
                ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              final loading = state is CreateSaleLoading;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(context),
                    const Divider(height: 28),
                    _totalBox(),
                    const SizedBox(height: 14),
                    _customerDropdownSection(),
                    const SizedBox(height: 14),
                    _paymentMethods(),
                    const SizedBox(height: 18),
                    _itemsPreview(),
                    const SizedBox(height: 18),
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
          child: const Icon(Icons.payment, color: Color(0xFF7C3AED)),
        ),
        const SizedBox(width: 10),
        const Text(
          'إتمام عملية البيع',
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

  Widget _customerDropdownSection() {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final cubit = context.read<CustomersCubit>();
        final customers = cubit.customers;

        if (state is CustomersLoading) {
          return _loadingBox("جاري تحميل العملاء...");
        }

        if (state is CustomersError) {
          return _errorBox(
            state.message.toString(),
            onRetry: cubit.fetchCustomers,
          );
        }

        if (customers.isEmpty) {
          return _warningBox("لا يوجد عملاء في النظام.");
        }

        // ✅ مهم: لو selectedCustomer مش موجود في القائمة بعد refresh
        if (selectedCustomer != null &&
            !customers.any((c) => c.id == selectedCustomer!.id)) {
          selectedCustomer = null;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('العميل', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<CustomerModel>(
              value: selectedCustomer,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'اختر العميل',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: customers.map((c) {
                return DropdownMenuItem<CustomerModel>(
                  value: c,
                  child: Text(
                    "${c.name ?? "-"}  (${c.phone ?? ""})",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCustomer = value),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await _showCustomersPicker(customers);
                if (picked != null) {
                  setState(() => selectedCustomer = picked);
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('بحث واختيار العميل'),
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
            _chip('Card', Icons.credit_card),
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
                  '${(e.saleTotal).toStringAsFixed(2)} ج.م',
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
              buttonText: 'تأكيد البيع',
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: const Color(0xFF7C3AED),
              isLoading: loading,
              icon: Icons.check_circle,
              onPressed: loading ? null : _submit,
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
              icon: Icons.close,
              onPressed: loading
                  ? () {}
                  : () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ),
        ],
      );
    }

    // ✅ Mobile
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AppTextButton(
            buttonText: 'تأكيد البيع',
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: const Color(0xFF7C3AED),
            isLoading: loading,
            icon: Icons.check_circle,
            onPressed: loading ? () {} : _submit,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: AppTextButton(
            buttonText: 'إلغاء',
            textStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.grey[200],
            icon: Icons.close,
            onPressed: loading
                ? () {}
                : () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ),
      ],
    );
  }

  // ================= ACTIONS =================

  void _submit() {
    if (selectedCustomer == null || (selectedCustomer!.id ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختار العميل الأول'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final products = widget.cartItems.map((item) {
      return CreateSaleProduct(
        productId: item.product.id.toString(),
        quantity: item.quantity,
      );
    }).toList();

    final req = CreateSaleRequest(
      customerId: selectedCustomer!.id!,
      paymentMethod: payment,
      products: products,
    );

    context.read<SalesCubit>().createSale(req);
  }

  Future<CustomerModel?> _showCustomersPicker(List<CustomerModel> customers) {
    return showDialog<CustomerModel>(
      context: context,
      builder: (_) => _CustomerSearchDialog(customers: customers),
    );
  }

  void _showInvoiceDialog(BuildContext context, sale) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('✅ تم إنشاء الفاتورة'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم الفاتورة: ${sale.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('العميل: ${sale.customer.name}'),
                const SizedBox(height: 6),
                Text('الإجمالي: ${sale.total}'),
                const SizedBox(height: 6),
                Text('طريقة الدفع: ${sale.paymentMethod}'),
                const SizedBox(height: 12),
                const Divider(),
                ...sale.items.map((i) {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('تمام'),
          ),
        ],
      ),
    );
  }

  // =================== UI Helpers ===================

  Widget _loadingBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _warningBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange),
          const SizedBox(width: 10),
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
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

// =================== Search Dialog ===================
class _CustomerSearchDialog extends StatefulWidget {
  final List<CustomerModel> customers;

  const _CustomerSearchDialog({required this.customers});

  @override
  State<_CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<_CustomerSearchDialog> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers.where((c) {
      final name = (c.name ?? '').toLowerCase();
      final phone = (c.phone ?? '').toLowerCase();
      final q = query.toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('اختيار العميل',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو الهاتف...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 380,
                child: filtered.isEmpty
                    ? const Center(child: Text('لا يوجد نتائج'))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = filtered[i];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF7C3AED),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(c.name ?? '-'),
                            subtitle: Text(c.phone ?? ''),
                            onTap: () => Navigator.pop(context, c),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
