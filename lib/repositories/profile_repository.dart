import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_auth_riverpod/constants/firebase_constants.dart';
import 'package:fb_auth_riverpod/models/app_user.dart';
import 'package:fb_auth_riverpod/repositories/handle_exception.dart';
import 'package:flutter/material.dart';

import '../utils/colored_print.dart';

class ProfileRepository {
  Future<AppUser> getProfile({required String uid}) async {
    try {
      final DocumentSnapshot appUserDoc = await usersCollection.doc(uid).get();

      if (appUserDoc.exists) {
        coloredPrint(msg: appUserDoc["email"], color: Colors.yellow);
        final appUser = AppUser.fromDoc(appUserDoc);
        return appUser;
      }
      throw 'User not found';
    } catch (e) {
      throw handleException(e);
    }
  }
}
