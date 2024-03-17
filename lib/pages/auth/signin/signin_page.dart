import 'package:fb_auth_riverpod/config/router/route_names.dart';
import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/pages/auth/signin/signin_provider.dart';
import 'package:fb_auth_riverpod/pages/widgets/buttons.dart';
import 'package:fb_auth_riverpod/pages/widgets/form_fields.dart';
import 'package:fb_auth_riverpod/utils/extensions/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
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
    ref.read(signinProvider.notifier).signin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      signinProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, st) => errorDialog(
            context,
            error as CustomError,
          ),
        );
      },
    );

    final signinState = ref.watch(signinProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidateMode,
            child: ListView(
              shrinkWrap: true,
              reverse: true,
              children: [
                const FlutterLogo(size: 100),
                const SizedBox(height: 20),
                EmailFormField(emailController: _emailController),
                const SizedBox(height: 20),
                PasswordFormField(
                  passwordController: _passwordController,
                  labelText: 'Password',
                ),
                const SizedBox(height: 20),
                CustomFilledButton(
                  onPressed: signinState.maybeWhen(
                    loading: () => null,
                    orElse: () => _submit,
                  ),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  child: signinState.maybeWhen(
                    loading: () => const Text('Logging in...'),
                    orElse: () => const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member? '),
                    CustomTextButton(
                        onPressed: signinState.maybeWhen(
                          orElse: () => () =>
                              GoRouter.of(context).goNamed(RouteNames.signup),
                          loading: () => null,
                        ),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        child: const Text('Sign up')),
                  ],
                ),
                CustomTextButton(
                  onPressed: signinState.maybeWhen(
                    loading: () => null,
                    orElse: () =>
                        () => context.goNamed(RouteNames.resetPassword),
                  ),
                  foregroundColor: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  child: const Text('Forget Password?'),
                ),
              ].reversed.toList(),
              // ],
            ),
          ),
        ),
      ),
    );
  }
}
