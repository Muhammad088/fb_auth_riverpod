import 'package:fb_auth_riverpod/repositories/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reset_password_provider.g.dart';

@riverpod
class ResetPassword extends _$ResetPassword {
  @override
  FutureOr<void> build() {}

  Future<void> resetPassword({required String email}) async {
    state = const AsyncLoading<void>();
    print("trying to reset password");
    state = await AsyncValue.guard<void>(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
  }
}
