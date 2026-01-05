import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/widgets/app_text_form_field.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/login/logic/login_cubit.dart';
import 'package:saas_stock/features/login/logic/login_states.dart';
// ignore: unused_import
import 'package:saas_stock/features/login/ui/widgets/remember_me_row.dart';
import 'package:saas_stock/features/login/ui/widgets/signIn_botton.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Column(
          children: [
            // Username Field (مش Email)
            UniversalFormField(
              controller: context.read<LoginCubit>().usernameController,
              prefixIcon: const Icon(Icons.person_outline),
              hintText: 'اسم المستخدم',
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 16)),

            // Password Field
            UniversalFormField(
              controller: context.read<LoginCubit>().passwordController,
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'كلمة المرور',
              isObscureText: context.watch<LoginCubit>().obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  context.watch<LoginCubit>().obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  context.read<LoginCubit>().togglePasswordVisibility();
                },
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(context, 24)),

            // Remember Me
            // RememberMeRow(
            //   rememberMe:  context.read<LoginCubit>().rememberMe,
            //  onRememberMeChanged: (value) {
            //     context.read<LoginCubit>().toggleRememberMe(value);
            //  },
            // ),
            SizedBox(height: ResponsiveHelper.spacing(context, 24)),

            // SignIn Button مع Loading state
            SignInButton(),
          ],
        );
      },
    );
  }
}
