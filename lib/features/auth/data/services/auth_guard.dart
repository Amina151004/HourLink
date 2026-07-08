// lib/core/services/auth_guard.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthGuard {
  static String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  static User get user {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user;
  }
}
