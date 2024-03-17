import 'package:fb_auth_riverpod/config/router/route_names.dart';
import 'package:fb_auth_riverpod/config/router/route_path.dart';
import 'package:fb_auth_riverpod/constants/firebase_constants.dart';
import 'package:fb_auth_riverpod/pages/auth/reset_password/reset_password_page.dart';
import 'package:fb_auth_riverpod/pages/auth/signin/signin_page.dart';
import 'package:fb_auth_riverpod/pages/auth/signup/signup_page.dart';
import 'package:fb_auth_riverpod/pages/auth/verify_email/verify_email_page.dart';
import 'package:fb_auth_riverpod/pages/content/change_password/change_password_page.dart';
import 'package:fb_auth_riverpod/pages/content/home/home_page.dart';
import 'package:fb_auth_riverpod/pages/page_not_found.dart';
import 'package:fb_auth_riverpod/pages/splash/firebase_error_page.dart';
import 'package:fb_auth_riverpod/pages/splash/splash_page.dart';
import 'package:fb_auth_riverpod/repositories/auth_repository_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_provider.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateStreamProvider);
  return GoRouter(
    initialLocation: RoutePath.splash,
    redirect: (context, state) {
      if (authState is AsyncLoading<User?>) {
        return RoutePath.splash;
      }
      if (authState is AsyncError<User?>) {
        return RoutePath.firebaseError;
      }
      final authenticated = authState.valueOrNull != null;
      final authenticatingPages = [
        RoutePath.signin,
        RoutePath.signup,
        RoutePath.resetPassword,
      ];
      var authenticating = authenticatingPages.contains(state.matchedLocation);

      if (!authenticated) {
        return authenticating ? null : RoutePath.signin;
      }

      if (!fbAuth.currentUser!.emailVerified) {
        return RoutePath.verifyEmail;
      }

      final verifyingEmail = state.matchedLocation == RoutePath.verifyEmail;
      final splashing = state.matchedLocation == RoutePath.splash;

      return (authenticating || verifyingEmail || splashing)
          ? RoutePath.home
          : null;
    },
    routes: [
      GoRoute(
        path: RoutePath.splash,
        name: RouteNames.splash,
        builder: (ctx, state) {
          print('##### splash #####');
          return const SplashPage();
        },
      ),
      GoRoute(
        path: RoutePath.firebaseError,
        name: RouteNames.firebaseError,
        builder: (ctx, state) {
          return const FirebaseErrorPage();
        },
      ),
      GoRoute(
        path: RoutePath.signin,
        name: RouteNames.signin,
        builder: (ctx, state) {
          return const SigninPage();
        },
      ),
      GoRoute(
        path: RoutePath.signup,
        name: RouteNames.signup,
        builder: (ctx, state) {
          return const SignupPage();
        },
      ),
      GoRoute(
        path: RoutePath.resetPassword,
        name: RouteNames.resetPassword,
        builder: (ctx, state) {
          return const ResetPasswordPage();
        },
      ),
      GoRoute(
        path: RoutePath.verifyEmail,
        name: RouteNames.verifyEmail,
        builder: (ctx, state) {
          return const VerifyEmailPage();
        },
      ),
      GoRoute(
        path: RoutePath.home,
        name: RouteNames.home,
        builder: (ctx, state) {
          return const HomePage();
        },
        routes: [
          GoRoute(
            path: RoutePath.changePassword,
            name: RouteNames.changePassword,
            builder: (ctx, state) {
              return const ChangePasswordPage();
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return PageNotFound(errorMessage: state.error.toString());
    },
  );
}
