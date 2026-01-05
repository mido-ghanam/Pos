import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_button.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/features/suppliers/data/models/verify_supplier_otp_request_body.dart';
import 'package:saas_stock/features/suppliers/logic/cubit.dart';
import 'package:saas_stock/features/suppliers/logic/states.dart';

class SupplierOtpScreen extends StatefulWidget {
  final String phone;
  const SupplierOtpScreen({super.key, required this.phone});

  @override
  State<SupplierOtpScreen> createState() => _SupplierOtpScreenState();
}

class _SupplierOtpScreenState extends State<SupplierOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SuppliersCubit, SuppliersState>(
      listener: (context, state) {
        if (state is SupplierRegistered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم تسجيل المورد بنجاح ✅"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }

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

        return Scaffold(
          appBar: AppBar(title: const Text("تأكيد OTP للمورد")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("تم إرسال كود OTP إلى: ${widget.phone}"),
                  const SizedBox(height: 20),
                  UniversalFormField(
                    controller: _otpController,
                    hintText: "ادخل كود OTP",
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "ادخل الكود";
                      if (v.length < 4) return "الكود غير صحيح";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextButton(
                    textStyle:  const TextStyle(color: Colors.white),
                    buttonText: "تأكيد",
                    isLoading: isLoading,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      context.read<SuppliersCubit>().verifySupplierOtp(
                            VerifySupplierOtpRequestBody(
                              phone: widget.phone,
                              otpCode: _otpController.text.trim(),
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
