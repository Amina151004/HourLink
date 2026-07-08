import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/services/auth_guard.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  String get _uid => AuthGuard.uid;
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
    await _userRef.update({
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
    final q = query.trim();
    if (q.isEmpty) return [];

    final qLower = q.toLowerCase();

    // ── Search by email prefix server-side ────────────────────────────────
    final emailSnap = await _firestore
        .collection('users')
        .orderBy('email')
        .startAt([qLower])
        .endAt(['$qLower\uf8ff'])
        .limit(20)
        .get();

    // ── Search by name client-side but with small limit ───────────────────
    final nameSnap = await _firestore
        .collection('users')
        .limit(30) // 👈 reduced from 100 to 30
        .get();

    // combine both results, remove duplicates, exclude self
    final Map<String, AppUser> merged = {};

    for (final doc in [...emailSnap.docs, ...nameSnap.docs]) {
      final user = AppUser.fromFirestore(doc);
      if (user.id != AuthGuard.uid) {
        merged[user.id] = user;
      }
    }

    // filter merged results by query
    return merged.values
        .where(
          (u) =>
              u.name.toLowerCase().contains(qLower) ||
              u.email.toLowerCase().contains(qLower),
        )
        .take(20) // 👈 max 20 results shown
        .toList();
  }
}
