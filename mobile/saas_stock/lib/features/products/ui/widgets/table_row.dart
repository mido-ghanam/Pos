import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/services/barcode_print_service.dart';
import 'package:saas_stock/features/products/data/models/product_model.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/products/logic/product/products_states.dart';
import 'package:saas_stock/features/products/ui/screens/add_edit_product_screen.dart';

class ProductsTableRow extends StatelessWidget {
  final ProductModel product;

  const ProductsTableRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    final qty = product.quantity ?? 0;
    final minQty = product.minQuantity ?? 0;
    final qtyColor = qty <= minQty
        ? Colors.red
        : (qty <= (minQty * 2) ? Colors.orange : Colors.green);

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(product.id?.substring(0, 8) ?? '-', style: textStyle),
            ),
            Expanded(
              flex: 4,
              child: Text(
                product.name ?? '-',
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(product.categoryName, style: textStyle),
            ),
            Expanded(
              flex: 3,
              child: Text(
                product.barcode?.toString() ?? '-',
                style: textStyle?.copyWith(color: Colors.grey[700]),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                qty.toStringAsFixed(0),
                style: textStyle?.copyWith(color: qtyColor),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${product.buyPrice?.toStringAsFixed(2) ?? '0'} ج.م',
                style: textStyle,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${product.sellPrice?.toStringAsFixed(2) ?? '0'} ج.م',
                style: textStyle?.copyWith(color: Colors.green),
              ),
            ),
            Expanded(
              flex: 2,
              child: _StatusChip(isActive: product.active ?? false),
            ),

            // ✅ Actions
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    tooltip: 'تعديل',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditProductScreen(productId: product.id),
                        ),
                      );
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    tooltip: 'حذف',
                    onPressed: () => _showDeleteOtpDialog(context),
                  ),

                  IconButton(
                    icon: const Icon(Icons.print),
                    color: Colors.black87,
                    tooltip: "طباعة باركود",
                    onPressed: () async {
                      await BarcodePrintService.printSingleBarcode(product);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ OTP Delete Dialog (FULL UI)
  void _showDeleteOtpDialog(BuildContext context) async {
    final cubit = context.read<ProductsCubit>();

    // ✅ اطلب OTP الأول
    cubit.requestDeleteOtp(product.id!);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final otpController = TextEditingController();

        return BlocConsumer<ProductsCubit, ProductsState>(
          listenWhen: (prev, curr) =>
              curr is DeleteOtpSendError ||
              curr is DeleteConfirmError ||
              curr is DeleteConfirmed,

          listener: (context, state) {
            if (state is DeleteOtpSendError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(dialogContext);
            }

            if (state is DeleteConfirmError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is DeleteConfirmed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(dialogContext);
            }
          },

          builder: (context, state) {
            final isSendingOtp = state is DeleteOtpSending;
            final isOtpSent = state is DeleteOtpSent;
            final isConfirming = state is DeleteConfirmLoading;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_forever, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "تأكيد حذف المنتج",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "سيتم حذف المنتج: ${product.name ?? ''}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "الباركود: ${product.barcode ?? '-'}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (isSendingOtp) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text("جاري إرسال OTP..."),
                    ),
                  ] else if (isOtpSent) ...[
                    const Text(
                      "أدخل رمز OTP المرسل:",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "OTP",
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox.shrink(),
                  ],

                  const SizedBox(height: 10),
                  const Text(
                    "⚠️ هذا الإجراء لا يمكن التراجع عنه",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: isSendingOtp || isConfirming
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text("إلغاء"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (!isOtpSent || isConfirming)
                      ? null
                      : () {
                          final otp = otpController.text.trim();

                          if (otp.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("من فضلك أدخل OTP"),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          cubit.confirmDeleteProduct(
                            productId: product.id!,
                            otp: otp,
                          );
                        },
                  child: isConfirming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("تأكيد الحذف"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bg = color.withOpacity(0.1);
    final text = isActive ? 'نشط' : 'موقوف';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
