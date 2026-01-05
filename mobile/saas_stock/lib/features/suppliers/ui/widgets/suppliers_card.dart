import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/suppliers/data/models/supplier_model.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/ui/screens/add_edit_supplier_screen.dart';

class SuppliersCard extends StatelessWidget {
  final SupplierModel supplier;

  const SuppliersCard({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final blocked = supplier.blocked == true;
    final vip = supplier.vip == true;
    final verified = supplier.isVerified == true;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SuppliersCubit>(),
                child: AddEditSupplierScreen(supplier: supplier),
              ),
            ),
          );

          // ✅ refresh بدل pop
          if (result == true && context.mounted) {
            context.read<SuppliersCubit>().fetchSuppliers();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                    child: Icon(
                      Icons.store,
                      color: blocked ? Colors.red : const Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.personName ?? "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blocked ? Colors.red[700] : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          supplier.companyName ?? "-",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (vip)
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                  if (blocked)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.block, color: Colors.red, size: 20),
                    ),
                  if (verified)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.verified, color: Colors.blue, size: 20),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Address
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      supplier.address ?? "-",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Phone
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    supplier.phone ?? "-",
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
