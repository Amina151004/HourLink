import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';

class MeetingService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference _meetingsRef(String teamId) =>
      _firestore.collection('teams').doc(teamId).collection('meetings');

  // ── 1. CREATE meeting ──────────────────────────────────────────────────
  Future<Meeting> createMeeting({
    required String teamId,
    required String title,
    required DateTime scheduledAt,
    String? platform,
  }) async {
    final ref = await _meetingsRef(teamId).add({
      'title': title,
      'platform': platform,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': 'coming',
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    return Meeting.fromFirestore(doc);
  }

  // ── 2. READ — real-time stream of team meetings ────────────────────────
  Stream<List<Meeting>> getTeamMeetingsStream(String teamId) {
    return _meetingsRef(teamId)
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Meeting.fromFirestore(d)).toList());
  }

  // ── 3. READ — all meetings for current user across all teams ───────────
  Future<List<Meeting>> getTodayMeetings(List<String> teamIds) async {
    if (teamIds.isEmpty) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final results = <Meeting>[];

    for (final teamId in teamIds) {
      final snap = await _meetingsRef(teamId)
          .where(
            'scheduledAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('scheduledAt')
          .get();

      results.addAll(snap.docs.map((d) => Meeting.fromFirestore(d)));
    }

    return results;
  }

  // ── 4. UPDATE meeting status ───────────────────────────────────────────
  Future<void> updateStatus({
    required String teamId,
    required String meetingId,
    required String status,
  }) async {
    await _meetingsRef(teamId).doc(meetingId).update({'status': status});
  }

  // ── 5. DELETE meeting ──────────────────────────────────────────────────
  Future<void> deleteMeeting({
    required String teamId,
    required String meetingId,
  }) async {
    await _meetingsRef(teamId).doc(meetingId).delete();
  }
}
