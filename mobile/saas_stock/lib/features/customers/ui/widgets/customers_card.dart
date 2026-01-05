import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/customers/data/models/customer_model.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/customers/ui/screens/add_edit_customer_screen.dart';

class CustomersCard extends StatelessWidget {
  final CustomerModel customer;

  const CustomersCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final blocked = customer.blocked == true;
    final vip = customer.vip == true;
    final verified = customer.isVerified == true;

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
                value: context.read<CustomersCubit>(),
                child: AddEditCustomerScreen(customer: customer),
              ),
            ),
          );

          // ✅ بدل pop — اعمل refresh للقائمة
          if (result == true && context.mounted) {
            context.read<CustomersCubit>().fetchCustomers();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER (Name + Status icons)
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: blocked ? Colors.red : const Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name ?? "-",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blocked ? Colors.red[700] : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.phone ?? "-",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badges
                  if (vip)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.star, color: Colors.orange, size: 20),
                    ),

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

              // ================= Address
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      customer.address ?? "-",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if ((customer.notes ?? "").trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.note_alt_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        customer.notes ?? "",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // ================= Actions (Edit Button)
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("تعديل"),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<CustomersCubit>(),
                          child: AddEditCustomerScreen(customer: customer),
                        ),
                      ),
                    );

                    // ✅ نفس الفكرة: refresh بدل pop
                    if (result == true && context.mounted) {
                      context.read<CustomersCubit>().fetchCustomers();
                    }
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
