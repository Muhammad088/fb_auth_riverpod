// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fb_auth_riverpod/config/router/route_names.dart';
import 'package:fb_auth_riverpod/pages/widgets/buttons.dart';
import 'package:fb_auth_riverpod/pages/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/pages/auth/signup/signup_provider.dart';
import 'package:fb_auth_riverpod/utils/extensions/error_dialog.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  var _autoValidateMode = AutovalidateMode.disabled;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _autoValidateMode = AutovalidateMode.always;
    });
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    print("name: ${_nameController.text}");
    print("email: ${_emailController.text}");
    print("password: ${_passwordController.text}");

    ref.read(signupProvider.notifier).signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      signupProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, st) => errorDialog(context, error as CustomError),
        );
      },
    );

    final signupState = ref.watch(signupProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              autovalidateMode: _autoValidateMode,
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                reverse: true,
                children: [
                  const FlutterLogo(size: 100),
                  const SizedBox(height: 20),
                  NameFormField(nameController: _nameController),
                  const SizedBox(height: 20),
                  EmailFormField(emailController: _emailController),
                  const SizedBox(height: 20),
                  PasswordFormField(
                    passwordController: _passwordController,
                    labelText: 'Password',
                  ),
                  const SizedBox(height: 20),
                  ConfirmPasswordFormField(
                    passwordController: _passwordController,
                    labelText: 'ConfirmPassword',
                  ),
                  const SizedBox(height: 20),
                  CustomFilledButton(
                    onPressed: signupState.maybeWhen(
                      loading: () => null,
                      orElse: () => _submit,
                    ),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    child: signupState.maybeWhen(
                      loading: () => const Text('Submitting...'),
                      orElse: () => const Text('Sign UP'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already a member? '),
                      CustomTextButton(
                          onPressed: signupState.maybeWhen(
                            orElse: () => () =>
                                GoRouter.of(context).goNamed(RouteNames.signin),
                            loading: () => null,
                          ),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          child: const Text('Sign in')),
                    ],
                  ),
                ].reversed.toList(),
                // ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
