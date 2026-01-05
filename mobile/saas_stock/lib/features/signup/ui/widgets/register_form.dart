import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/signup/logic/signup_cubit.dart';
import 'package:saas_stock/features/signup/logic/signup_states.dart';
import 'package:saas_stock/features/signup/ui/widgets/register_button.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();

        return Column(
          children: [
            // ✅ Username
            UniversalFormField(
              controller: cubit.usernameController,
              prefixIcon: const Icon(Icons.person_outline),
              hintText: 'اسم المستخدم',
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 16)),

            // ✅ Phone
            UniversalFormField(
              controller: cubit.phoneController,
              prefixIcon: const Icon(Icons.phone_outlined),
              hintText: 'رقم الهاتف',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 16)),

            // ✅ First Name
            UniversalFormField(
              controller: cubit.firstNameController,
              prefixIcon: const Icon(Icons.badge_outlined),
              hintText: 'الاسم الأول',
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 16)),

            // ✅ Last Name
            UniversalFormField(
              controller: cubit.lastNameController,
              prefixIcon: const Icon(Icons.badge_outlined),
              hintText: 'اسم العائلة',
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 16)),

            // ✅ Password
            UniversalFormField(
              controller: cubit.passwordController,
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'كلمة المرور',
              isObscureText: context.watch<RegisterCubit>().obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  context.watch<RegisterCubit>().obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: cubit.togglePasswordVisibility,
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 16)),

            // ✅ Confirm Password
            UniversalFormField(
              controller: cubit.confirmPasswordController,
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'تأكيد كلمة المرور',
              isObscureText: context.watch<RegisterCubit>().obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  context.watch<RegisterCubit>().obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: cubit.toggleConfirmPasswordVisibility,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(context, 24)),

            // ✅ Button
            const RegisterButton(),
          ],
        );
      },
    );
  }
}
