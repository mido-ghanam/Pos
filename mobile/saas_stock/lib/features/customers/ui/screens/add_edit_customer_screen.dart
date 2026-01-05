import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/customers/data/models/customer_model.dart';
import 'package:saas_stock/features/customers/data/models/register_customer_request_body.dart';
import 'package:saas_stock/features/customers/data/models/update_customer_request_body.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/customers/logic/states.dart';
import 'customer_otp_screen.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isBlocked = false;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name ?? "";
      _phoneController.text = widget.customer!.phone ?? "";
      _addressController.text = widget.customer!.address ?? "";
      _notesController.text = widget.customer!.notes ?? "";
      _isBlocked = widget.customer!.blocked ?? false;
      _isVip = widget.customer!.vip ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return BlocConsumer<CustomersCubit, CustomersState>(
      listener: (context, state) async {
        if (state is CustomerOtpSent) {
          // روح صفحة OTP
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CustomersCubit>(),
                child: CustomerOtpScreen(phone: state.phone),
              ),
            ),
          );

          // لو تم التأكيد → refresh + pop
          if (result == true) {
            if (!mounted) return;
            Navigator.pop(context, true);
          }
        }

        if (state is CustomerUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم تعديل بيانات العميل"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }

        if (state is CustomersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CustomersLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? 'تعديل عميل' : 'إضافة عميل جديد'),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: ResponsiveHelper.pagePadding(context),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.maxContentWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMainInfo(),
                      const SizedBox(height: 16),
                      _buildFlags(),
                      const SizedBox(height: 16),
                      _buildNotes(),
                      const SizedBox(height: 24),
                      _buildActions(isEdit, isLoading),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainInfo() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.person_outline,
              title: 'بيانات العميل',
            ),
            const SizedBox(height: 16),
            UniversalFormField(
              controller: _nameController,
              hintText: 'اسم العميل',
              prefixIcon: const Icon(Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك أدخل اسم العميل';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            UniversalFormField(
              controller: _phoneController,
              hintText: 'رقم الهاتف',
              prefixIcon: const Icon(Icons.phone),
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return "أدخل رقم الهاتف";
                return null;
              },
            ),
            const SizedBox(height: 12),
            UniversalFormField(
              controller: _addressController,
              hintText: 'العنوان',
              prefixIcon: const Icon(Icons.location_on),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlags() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _SectionTitle(
              icon: Icons.settings,
              title: 'إعدادات العميل',
            ),
          ),
          SwitchListTile(
            title: const Text('عميل محظور'),
            subtitle: const Text('منع البيع لهذا العميل'),
            value: _isBlocked,
            activeColor: const Color(0xFF7C3AED),
            onChanged: (v) => setState(() => _isBlocked = v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('عميل مميز (VIP)'),
            subtitle: const Text('يمكن استخدامه في الخصومات والعروض'),
            value: _isVip,
            activeColor: const Color(0xFF7C3AED),
            onChanged: (v) => setState(() => _isVip = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.note_alt_outlined,
              title: 'ملاحظات (اختياري)',
            ),
            const SizedBox(height: 16),
            UniversalFormField(
              controller: _notesController,
              hintText: 'اكتب أي ملاحظات عن العميل...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(bool isEdit, bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: AppTextButton(
            buttonText: isEdit ? 'حفظ التعديلات' : 'إضافة العميل',
            isLoading: isLoading,
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: const Color(0xFF7C3AED),
            onPressed: () => _handleSubmit(isEdit),
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  void _handleSubmit(bool isEdit) {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<CustomersCubit>();

    if (!isEdit) {
      cubit.registerCustomer(
        RegisterCustomerRequestBody(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );
    } else {
      cubit.updateCustomer(
        widget.customer!.id!,
        UpdateCustomerRequestBody(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          blocked: _isBlocked,
          vip: _isVip,
          notes: _notesController.text.trim(),
          isVerified: widget.customer!.isVerified ?? true,
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7C3AED)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
