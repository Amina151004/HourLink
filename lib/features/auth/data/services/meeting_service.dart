import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/services/auth_guard.dart';
import 'package:hourlink/features/auth/data/services/team_service.dart';

class MeetingService {
  final _firestore = FirebaseFirestore.instance;
  final _teamService = TeamService(); // 👈 add this

  String get _uid => AuthGuard.uid;

  CollectionReference _meetingsRef(String teamId) =>
      _firestore.collection('teams').doc(teamId).collection('meetings');

  // ── 1. CREATE meeting ──────────────────────────────────────────────────
  Future<Meeting> createMeeting({
    required String teamId,
    required String title,
    required DateTime scheduledAt,
    String? platform,
  }) async {
    // validate before hitting Firestore
    if (title.trim().isEmpty) throw Exception('Meeting title cannot be empty');

    final ref = await _meetingsRef(teamId).add({
      'title': title.trim(),
      'platform': platform,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': 'coming',
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 👈 tell TeamService to re-fetch meetings next time
    _teamService.invalidateMeetingsCache(teamId);

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

  // ── 3. READ — today's meetings across all teams ────────────────────────
  // ── 3. READ — today's meetings across all teams ────────────────────────
  Future<List<Meeting>> getTodayMeetings(List<String> teamIds) async {
    if (teamIds.isEmpty) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // 👈 all queries fire at the same time instead of one by one
    final results = await Future.wait(
      teamIds.map(
        (teamId) => _meetingsRef(teamId)
            .where(
              'scheduledAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
            .orderBy('scheduledAt')
            .get(),
      ),
    );

    // flatten the list of lists into a single list
    return results
        .expand((snap) => snap.docs.map((d) => Meeting.fromFirestore(d)))
        .toList();
  }

  // ── 4. UPDATE meeting status ───────────────────────────────────────────
  Future<void> updateStatus({
    required String teamId,
    required String meetingId,
    required String status,
  }) async {
    const validStatuses = ['coming', 'done', 'cancelled'];
    if (!validStatuses.contains(status)) {
      throw Exception('Invalid status: $status');
    }
    await _meetingsRef(teamId).doc(meetingId).update({'status': status});
  }

  // ── 5. DELETE meeting ──────────────────────────────────────────────────
  Future<void> deleteMeeting({
    required String teamId,
    required String meetingId,
  }) async {
    await _meetingsRef(teamId).doc(meetingId).delete();

    // 👈 tell TeamService to re-fetch meetings next time
    _teamService.invalidateMeetingsCache(teamId);
  }
}
