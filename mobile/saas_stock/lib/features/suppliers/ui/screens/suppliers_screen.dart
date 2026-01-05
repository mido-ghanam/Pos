import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/logic/states.dart';
import 'package:saas_stock/features/suppliers/ui/screens/add_edit_supplier_screen.dart';
import 'package:saas_stock/features/suppliers/ui/widgets/suppliers_table.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuppliersCubit, SuppliersState>(
      builder: (context, state) {
        final cubit = context.read<SuppliersCubit>();

        final suppliers = (state is SuppliersLoaded)
            ? state.suppliers
            : (state is SuppliersLoading)
                ? state.oldSuppliers
                : cubit.suppliers;

        return Scaffold(
          appBar: AppBar(title: const Text("الموردين")),
          body: Column(
            children: [
              const SizedBox(height: 8),
              UniversalFormField(
                hintText: 'ابحث بالاسم، الشركة، التليفون...',
                prefixIcon: const Icon(Icons.search),
                onChanged: (value) {
                  // cubit.searchSuppliers(value);
                },
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: Stack(
                  children: [
                    SuppliersTable(suppliers: suppliers),
                    if (state is SuppliersLoading)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF7C3AED),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text("إضافة مورد"),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<SuppliersCubit>(),
                    child: const AddEditSupplierScreen(),
                  ),
                ),
              );
              if (result == true) {
                cubit.fetchSuppliers();
              }
            },
          ),
        );
      },
    );
  }
}
