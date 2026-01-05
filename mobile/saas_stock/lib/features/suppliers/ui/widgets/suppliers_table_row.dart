import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saas_stock/features/suppliers/data/models/supplier_model.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/ui/screens/add_edit_supplier_screen.dart';

class SuppliersTableRow extends StatelessWidget {
  final SupplierModel supplier;

  const SuppliersTableRow({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    final isBlocked = supplier.blocked == true;
    final isVip = supplier.vip == true;
    final isVerified = supplier.isVerified == true;

    String createdAtFormatted = "-";
    try {
      if (supplier.createdAt != null && supplier.createdAt!.isNotEmpty) {
        final dt = DateTime.parse(supplier.createdAt!).toLocal();
        createdAtFormatted = DateFormat('dd/MM/yyyy').format(dt);
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                  child: Icon(
                    Icons.store,
                    color: isBlocked ? Colors.red : const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    supplier.personName ?? "-",
                    style: textStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isBlocked ? Colors.red[700] : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVip) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(supplier.companyName ?? "-", style: textStyle),
          ),
          Expanded(
            flex: 2,
            child: Text(supplier.phone ?? "-", style: textStyle),
          ),
          Expanded(
            flex: 3,
            child: Text(
              supplier.address ?? "-",
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: _StatusChip(
              label: isBlocked ? "محظور" : "نشط",
              color: isBlocked ? Colors.red : Colors.green,
            ),
          ),
          Expanded(
            flex: 2,
            child: _StatusChip(
              label: isVerified ? "موثق" : "غير موثق",
              color: isVerified ? Colors.blue : Colors.grey,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(createdAtFormatted, style: textStyle),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.blue,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<SuppliersCubit>(),
                          child: AddEditSupplierScreen(supplier: supplier),
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      context.read<SuppliersCubit>().fetchSuppliers();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
