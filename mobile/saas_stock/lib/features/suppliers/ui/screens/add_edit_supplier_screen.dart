import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/suppliers/data/models/register_supplier_request_body.dart';
import 'package:saas_stock/features/suppliers/data/models/supplier_model.dart';
import 'package:saas_stock/features/suppliers/data/models/update_supplier_request_body.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/logic/states.dart';
import 'supplier_otp_screen.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final SupplierModel? supplier;

  const AddEditSupplierScreen({super.key, this.supplier});

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();

  final _personController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isBlocked = false;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _personController.text = widget.supplier!.personName ?? "";
      _companyController.text = widget.supplier!.companyName ?? "";
      _phoneController.text = widget.supplier!.phone ?? "";
      _addressController.text = widget.supplier!.address ?? "";
      _notesController.text = widget.supplier!.notes ?? "";
      _isBlocked = widget.supplier!.blocked ?? false;
      _isVip = widget.supplier!.vip ?? false;
    }
  }

  @override
  void dispose() {
    _personController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return BlocConsumer<SuppliersCubit, SuppliersState>(
      listener: (context, state) async {
        // ✅ Register → OTP
        if (state is SupplierOtpSent) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SuppliersCubit>(),
                child: SupplierOtpScreen(phone: state.phone),
              ),
            ),
          );

          if (result == true) {
            if (!mounted) return;
            Navigator.pop(context, true); // ✅ يرجع للشاشة اللي فاتح منها
          }
        }

        // ✅ Update success
        if (state is SupplierUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ تم تعديل بيانات المورد"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }

        // ✅ Error
        if (state is SuppliersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SuppliersLoading;
        final isMobile = ResponsiveHelper.isMobile(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? "تعديل مورد" : "إضافة مورد جديد"),
          ),

          // ✅ في الموبايل خلي زرار الحفظ/الإلغاء في Bottom ثابت
          bottomNavigationBar: isMobile
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildActions(isEdit, isLoading, isMobile),
                  ),
                )
              : null,

          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: ResponsiveHelper.pagePadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.maxContentWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMainInfoCard(),
                      const SizedBox(height: 14),
                      _buildFlagsCard(),
                      const SizedBox(height: 14),
                      _buildNotesCard(),
                      const SizedBox(height: 18),

                      // ✅ في الديسكتوب نخلي الأزرار جوه البودي
                      if (!isMobile)
                        _buildActions(isEdit, isLoading, isMobile),

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

  // ===================== Main Info =====================
  Widget _buildMainInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(icon: Icons.storefront, title: "بيانات المورد"),
            const SizedBox(height: 14),

            UniversalFormField(
              controller: _personController,
              hintText: "اسم المسئول / الشخص",
              prefixIcon: const Icon(Icons.person),
              validator: (v) => (v == null || v.isEmpty) ? "أدخل الاسم" : null,
            ),
            const SizedBox(height: 12),

            UniversalFormField(
              controller: _companyController,
              hintText: "اسم الشركة (اختياري)",
              prefixIcon: const Icon(Icons.apartment),
            ),
            const SizedBox(height: 12),

            UniversalFormField(
              controller: _phoneController,
              hintText: "رقم الهاتف",
              prefixIcon: const Icon(Icons.phone),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "أدخل رقم الهاتف" : null,
            ),
            const SizedBox(height: 12),

            UniversalFormField(
              controller: _addressController,
              hintText: "العنوان",
              prefixIcon: const Icon(Icons.location_on),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Flags =====================
  Widget _buildFlagsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: _SectionTitle(icon: Icons.settings, title: "إعدادات المورد"),
          ),
          SwitchListTile(
            title: const Text("مورد محظور"),
            subtitle: const Text("منع التعامل مع المورد"),
            value: _isBlocked,
            activeColor: const Color(0xFF7C3AED),
            onChanged: (v) => setState(() => _isBlocked = v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text("مورد VIP"),
            subtitle: const Text("مورد مميز"),
            value: _isVip,
            activeColor: const Color(0xFF7C3AED),
            onChanged: (v) => setState(() => _isVip = v),
          ),
        ],
      ),
    );
  }

  // ===================== Notes =====================
  Widget _buildNotesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(icon: Icons.note_alt, title: "ملاحظات"),
            const SizedBox(height: 14),
            UniversalFormField(
              controller: _notesController,
              hintText: "اكتب ملاحظات عن المورد...",
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Actions =====================
  Widget _buildActions(bool isEdit, bool isLoading, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: AppTextButton(
            buttonText: isEdit ? "حفظ التعديلات" : "إضافة المورد",
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
            buttonText: "إلغاء",
            backgroundColor: Colors.grey[200],
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  // ===================== Submit =====================
  void _handleSubmit(bool isEdit) {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<SuppliersCubit>();

    if (!isEdit) {
      cubit.registerSupplier(
        RegisterSupplierRequestBody(
          personName: _personController.text.trim(),
          companyName: _companyController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );
    } else {
      cubit.updateSupplier(
        widget.supplier!.id!,
        UpdateSupplierRequestBody(
          personName: _personController.text.trim(),
          companyName: _companyController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          blocked: _isBlocked,
          vip: _isVip,
          notes: _notesController.text.trim(),
          isVerified: widget.supplier!.isVerified ?? true,
        ),
      );
    }
  }
}

// ===================== Section Title =====================
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
