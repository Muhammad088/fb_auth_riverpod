import 'dart:async';

import 'package:fb_auth_riverpod/config/router/route_names.dart';
import 'package:fb_auth_riverpod/constants/firebase_constants.dart';
import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/repositories/auth_repository_provider.dart';
import 'package:fb_auth_riverpod/utils/extensions/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    sendEmailVerification();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void errorDialogRef(CustomError e) {
    errorDialog(context, e);
  }

  Future<void> checkEmailVerified() async {
    final goRouter = GoRouter.of(context);
    try {
      await ref.read(authRepositoryProvider).reloadUser();
      if (fbAuth.currentUser!.emailVerified) {
        timer?.cancel();
        goRouter.goNamed(RouteNames.home);
      }
    } on CustomError catch (e) {
      if (!mounted) return;
      errorDialog(context, e);

      // always show the error message regardless of whether it's mounted or not
      // errorDialogRef(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        checkEmailVerified();
      });
    } on CustomError catch (e) {
      if (!mounted) return;
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Verification Email has been sent to'),
                  Text('${fbAuth.currentUser?.email}'),
                  const Text('if you cannot find verification Email'),
                  RichText(
                    text: TextSpan(
                      text: "Please check",
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(fontSize: 18),
                      children: const [
                        TextSpan(
                          text: " SPAM",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " folder.",
                        ),
                      ],
                    ),
                  ),
                  const Text('or, your email is incorrect'),
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref.read(authRepositoryProvider).signout();
                        timer?.cancel();
                      } on CustomError catch (e) {
                        if (!mounted) return;
                        errorDialog(context, e);
                      }
                    },
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
