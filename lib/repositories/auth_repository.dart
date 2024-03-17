import 'package:fb_auth_riverpod/constants/firebase_constants.dart';
import 'package:fb_auth_riverpod/repositories/handle_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  User? get currentUser => fbAuth.currentUser;
  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await fbAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      final signedInUser = userCredential.user!;
      await usersCollection.doc(signedInUser.uid).set({
        'name': name,
        'email': email,
      });
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> signin({
    required String email,
    required String password,
  }) async {
    try {
      await fbAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> signout() async {
    try {
      // throw 'signout error';
      await fbAuth.signOut();
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      await currentUser!.updatePassword(newPassword);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await fbAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await currentUser!.sendEmailVerification();
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> reloadUser() async {
    try {
      await currentUser!.reload();
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> reauthenticateWithCredential({
    required String email,
    required String password,
  }) async {
    try {
      await currentUser!.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    } catch (e) {
      throw handleException(e);
    }
  }
}
