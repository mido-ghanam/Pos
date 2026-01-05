import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/features/customers/data/models/verify_customer_otp_request_body.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/customers/logic/states.dart';

class CustomerOtpScreen extends StatefulWidget {
  final String phone;
  const CustomerOtpScreen({super.key, required this.phone});

  @override
  State<CustomerOtpScreen> createState() => _CustomerOtpScreenState();
}

class _CustomerOtpScreenState extends State<CustomerOtpScreen> {
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomersCubit, CustomersState>(
      listener: (context, state) {
        if (state is CustomerRegistered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ تم إضافة العميل بنجاح")),
          );
          Navigator.pop(context, true);
        }

        if (state is CustomersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final loading = state is CustomersLoading;

        return Scaffold(
          appBar: AppBar(title: const Text("تأكيد OTP")),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text("تم إرسال كود OTP إلى: ${widget.phone}"),
                const SizedBox(height: 20),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "أدخل OTP",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                          context.read<CustomersCubit>().verifyCustomerOtp(
                                VerifyCustomerOtpRequestBody(
                                  phone: widget.phone,
                                  otpCode: otpController.text.trim(),
                                ),
                              );
                        },
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("تأكيد"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
