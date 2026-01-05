import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/customers/logic/states.dart';
import 'package:saas_stock/features/customers/ui/screens/add_edit_customer_screen.dart';
import 'package:saas_stock/features/customers/ui/widgets/customers_table.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final cubit = context.read<CustomersCubit>();
    
        final customers = (state is CustomersLoaded)
            ? state.customers
            : (state is CustomersLoading)
                ? state.oldCustomers
                : cubit.customers;
    
        return Scaffold(
          appBar: AppBar(title: const Text('العملاء')),
          body: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric( horizontal: 8.0),
                child: UniversalFormField(
                  hintText: 'ابحث بالاسم، التليفون، الكود...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    // cubit.searchCustomers(value);
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
    
              Expanded(
                child: Stack(
                  children: [
                    CustomersTable(customers: customers),
                    if (state is CustomersLoading)
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
            icon: const Icon(Icons.person_add),
            label: const Text('إضافة عميل'),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CustomersCubit>(),
                    child: const AddEditCustomerScreen(),
                  ),
                ),
              );
    
              if (result == true) {
                cubit.fetchCustomers();
              }
            },
          ),
        );
      },
    );
  }
}
