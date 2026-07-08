import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

class AuthService {
  // ── Singleton ────────────────────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ── Firebase instances ───────────────────────────────────────────────────
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ── GoogleSignIn unique, avec scopes Calendar inclus ─────────────────────
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      gcal.CalendarApi.calendarScope,
      gcal.CalendarApi.calendarEventsScope,
    ],
  );

  // Expose l'instance pour que GoogleCalendarService puisse la réutiliser
  GoogleSignIn get googleSignIn => _googleSignIn;

  // ── Sign in with Google + save user to Firestore ─────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    await _saveUserToFirestore(userCredential.user!);

    return userCredential;
  }

  // ── Save/update user document in Firestore ────────────────────────────────
  Future<void> _saveUserToFirestore(User firebaseUser) async {
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);

    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'id': firebaseUser.uid,
        'name': firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'photoUrl': firebaseUser.photoURL ?? '',
        'title': '',
        'location': '',
        'description': '',
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userRef.update({
        'name': firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'photoUrl': firebaseUser.photoURL ?? '',
      });
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Get current Firebase user ──────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
}
