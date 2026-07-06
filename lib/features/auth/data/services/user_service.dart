import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;
  DocumentReference get _userRef => _firestore.collection('users').doc(_uid);

  // ── 1. GET current user (one-time) ────────────────────────────────────
  Future<AppUser?> getCurrentUser() async {
    final doc = await _userRef.get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  // ── 2. GET current user (real-time stream) ─────────────────────────────
  Stream<AppUser?> getCurrentUserStream() {
    return _userRef.snapshots().map(
      (doc) => doc.exists ? AppUser.fromFirestore(doc) : null,
    );
  }

  // ── 3. GET any user by id ──────────────────────────────────────────────
  Future<AppUser?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  // ── 4. UPDATE current user profile ────────────────────────────────────
  Future<void> updateProfile({
    required String name,
    required String title,
    required String location,
    required String description,
    required String phone,
  }) async {
    await _userRef.set({
      'name': name,
      'title': title,
      'location': location,
      'description': description,
      'phone': phone,
    });
  }

  // ── 5. SEARCH users by name (for adding to team) ───────────────────────
  // ── 5. SEARCH users by name or email ──────────────────────────────────
  Future<List<AppUser>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final q = query.trim().toLowerCase();

    final snap = await _firestore.collection('users').limit(100).get();

    debugPrint('Total users in Firestore: ${snap.docs.length}');
    for (final doc in snap.docs) {
      debugPrint('User: ${doc.data()}');
    }

    return snap.docs
        .map((d) => AppUser.fromFirestore(d))
        .where((u) => u.id != _uid)
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }
}
