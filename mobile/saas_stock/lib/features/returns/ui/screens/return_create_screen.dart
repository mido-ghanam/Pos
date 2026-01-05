import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/customers/logic/states.dart';
import 'package:saas_stock/features/returns/data/models/create_refund_request.dart';
import 'package:saas_stock/features/returns/logic/cubit.dart';
import 'package:saas_stock/features/returns/logic/states.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/logic/states.dart';
import '../widgets/return_invoice_dialog.dart';

// ✅ انت هتستورد model ده من الملف اللي عملناه: partner_invoices_model.dart
// فيه: PartnerInvoicesResponse + InvoiceModel + InvoiceItemModel
import 'package:saas_stock/features/returns/data/models/partner_invoices_model.dart';

class ReturnCreateScreen extends StatefulWidget {
  const ReturnCreateScreen({super.key});

  @override
  State<ReturnCreateScreen> createState() => _ReturnCreateScreenState();
}

class _ReturnCreateScreenState extends State<ReturnCreateScreen> {
  String returnType = "sale"; // sale / purchase
  String? partyId;

  InvoiceModel? selectedInvoice;

  /// ✅ productId => qty
  final Map<String, int> returnQty = {};

  bool _invoiceShown = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ أول ما الشاشة تفتح
      context.read<CustomersCubit>().fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReturnsCubit, ReturnsState>(
      listenWhen: (p, c) => c is CreateRefundSuccess || c is CreateRefundError,
      listener: (context, state) async {
        if (state is CreateRefundSuccess) {
          // ✅ منع تكرار فتح الفاتورة بسبب refresh
          if (_invoiceShown) return;
          _invoiceShown = true;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ReturnInvoiceDialog(invoice: state.invoice),
          ).then((_) {
            Navigator.pop(context, true);
          });
        }

        if (state is CreateRefundError) {
          _toast(context, state.message);
        }
      },
      builder: (context, state) {
        final loading = state is CreateRefundLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text("إنشاء مرتجع"),
            backgroundColor: const Color(0xFFFB7185),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _typeSelector(),
                const SizedBox(height: 16),
                _partySelector(),
                const SizedBox(height: 16),
                _invoicesSection(),
                _invoiceItemsSection(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : () => _submit(context),
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(loading ? "جاري الحفظ..." : "تأكيد المرتجع"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB7185),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ ================= TYPE SELECTOR =================

  Widget _typeSelector() {
    return Row(
      children: [
        Expanded(child: _typeChip("sale", "مرتجع مبيعات")),
        const SizedBox(width: 10),
        Expanded(child: _typeChip("purchase", "مرتجع مشتريات")),
      ],
    );
  }

  Widget _typeChip(String value, String label) {
    final selected = returnType == value;
    return InkWell(
      onTap: () {
        setState(() {
          returnType = value;
          partyId = null;
          selectedInvoice = null;
          returnQty.clear();
          _invoiceShown = false;
        });

        if (value == "sale") {
          context.read<CustomersCubit>().fetchCustomers();
        } else {
          context.read<SuppliersCubit>().fetchSuppliers();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFB7185) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFFB7185) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ ================= PARTY SELECTOR =================

  Widget _partySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(returnType == "sale" ? "العميل" : "المورد",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (returnType == "sale")
          BlocBuilder<CustomersCubit, CustomersState>(
            builder: (context, state) {
              final customers = context.read<CustomersCubit>().customers;

              if (state is CustomersLoading) {
                return _box("جاري تحميل العملاء...", loading: true);
              }
              if (state is CustomersError) {
                return _box("خطأ: ${state.message}", isError: true);
              }
              if (customers.isEmpty) {
                return _box("لا يوجد عملاء", isError: true);
              }

              return DropdownButtonFormField<String>(
                value: partyId,
                decoration: _decoration("اختر العميل"),
                items: customers.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text("${c.name ?? "-"}  (${c.phone ?? ""})"),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    partyId = v;
                    selectedInvoice = null;
                    returnQty.clear();
                  });

                  context.read<ReturnsCubit>().loadPartnerInvoices(
                        type: returnType,
                        partyId: v,
                      );
                },
              );
            },
          )
        else
          BlocBuilder<SuppliersCubit, SuppliersState>(
            builder: (context, state) {
              final suppliers = context.read<SuppliersCubit>().suppliers;

              if (state is SuppliersLoading) {
                return _box("جاري تحميل الموردين...", loading: true);
              }
              if (state is SuppliersError) {
                return _box("خطأ: ${state.message}", isError: true);
              }
              if (suppliers.isEmpty) {
                return _box("لا يوجد موردين", isError: true);
              }

              return DropdownButtonFormField<String>(
                value: partyId,
                decoration: _decoration("اختر المورد"),
                items: suppliers.map((s) {
                  final name = (s.companyName?.isNotEmpty == true)
                      ? s.companyName!
                      : (s.personName ?? "-");
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text("$name  (${s.phone ?? ""})"),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    partyId = v;
                    selectedInvoice = null;
                    returnQty.clear();
                  });

                  context.read<ReturnsCubit>().loadPartnerInvoices(
                        type: returnType,
                        partyId: v,
                      );
                },
              );
            },
          ),
      ],
    );
  }

  // ✅ ================= INVOICES SECTION =================

  Widget _invoicesSection() {
    if (partyId == null) return const SizedBox.shrink();

    return BlocBuilder<ReturnsCubit, ReturnsState>(
      builder: (context, state) {
        final data = context.read<ReturnsCubit>().partnerInvoices;

        if (state is PartnerInvoicesLoading) {
          return _box("جاري تحميل الفواتير...", loading: true);
        }

        if (state is PartnerInvoicesError) {
          return _box("خطأ: ${state.message}", isError: true);
        }

        if (data == null || data.invoices.isEmpty) {
          return _box("لا توجد فواتير لهذا الطرف.", isError: true);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("الفواتير",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...data.invoices.map((inv) {
              final selected = selectedInvoice?.id == inv.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    selectedInvoice = inv;
                    returnQty.clear();

                    for (final it in inv.items) {
                      returnQty[it.productId] = 0;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFB7185).withOpacity(0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFB7185)
                          : Colors.grey[200]!,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            const Color(0xFFFB7185).withOpacity(0.15),
                        child: const Icon(Icons.receipt_long,
                            color: Color(0xFFFB7185)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("فاتورة #${inv.id}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "الإجمالي: ${inv.total} ج.م  -  ${inv.paymentMethod}",
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected ? Icons.check_circle : Icons.arrow_forward_ios,
                        size: 18,
                        color: selected ? const Color(0xFFFB7185) : Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // ✅ ================= INVOICE ITEMS SECTION =================

  Widget _invoiceItemsSection() {
    if (selectedInvoice == null) return const SizedBox.shrink();

    if (selectedInvoice!.items.isEmpty) {
      return _box("هذه الفاتورة لا تحتوي على منتجات.", isError: true);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text("منتجات الفاتورة",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...selectedInvoice!.items.map((it) {
          final current = returnQty[it.productId] ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        "الكمية: ${it.quantity} | سعر: ${it.unitPrice}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                      onPressed: current > 0
                          ? () => setState(
                              () => returnQty[it.productId] = current - 1)
                          : null,
                    ),
                    Text("$current",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                      onPressed: current < it.quantity
                          ? () => setState(
                              () => returnQty[it.productId] = current + 1)
                          : null,
                    ),
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // ✅ ================= SUBMIT =================

  void _submit(BuildContext context) {
    if (partyId == null || partyId!.isEmpty) {
      _toast(context, "اختار العميل/المورد الأول");
      return;
    }

    if (selectedInvoice == null) {
      _toast(context, "اختار فاتورة الأول");
      return;
    }

    final products = returnQty.entries
        .where((e) => e.value > 0)
        .map((e) => CreateRefundProduct(productId: e.key, quantity: e.value))
        .toList();

    if (products.isEmpty) {
      _toast(context, "حدد كميات المرتجع");
      return;
    }

    final apiReturnType = returnType == "sale" ? "sales" : "purchase";

    final req = CreateRefundRequest(
      returnType: apiReturnType,
      partyId: partyId!,
      products: products,
    );

    context.read<ReturnsCubit>().createRefund(req);
  }

  // ✅ ================= UI HELPERS =================

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _box(String text, {bool isError = false, bool loading = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withOpacity(0.08) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(isError ? Icons.error_outline : Icons.info_outline,
                color: isError ? Colors.red : Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isError ? Colors.red : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }
}
