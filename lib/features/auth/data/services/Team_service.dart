import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/services/auth_guard.dart';

class TeamService {
  final _firestore = FirebaseFirestore.instance;

  String get _uid => AuthGuard.uid;
  CollectionReference get _teams => _firestore.collection('teams');
  CollectionReference get _users => _firestore.collection('users');

  // ── Local cache ────────────────────────────────────────────────────────
  final Map<String, List<AppUser>> _membersCache = {};
  final Map<String, List<String>> _memberIdsCache = {};
  final Map<String, List<Meeting>> _meetingsCache = {};

  // ── 1. CREATE team ─────────────────────────────────────────────────────
  Future<Team> createTeam({
    required String name,
    String bio = '',
    String photoUrl = '',
  }) async {
    final ref = await _teams.add({
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'createdBy': _uid,
      'memberIds': [_uid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    return Team.fromFirestore(doc);
  }

  // ── 2. STREAM — real-time list of user's teams ─────────────────────────
  Stream<List<Team>> getUserTeamsStream() {
    return _teams.where('memberIds', arrayContains: _uid).snapshots().asyncMap((
      snapshot,
    ) async {
      final teams = snapshot.docs.map((d) => Team.fromFirestore(d)).toList();
      return Future.wait(teams.map((t) => _loadTeamDetailsCached(t)));
    });
  }

  // ── 3. READ — single team with full details ────────────────────────────
  Future<Team> getTeamWithDetails(String teamId) async {
    final doc = await _teams.doc(teamId).get();
    if (!doc.exists) throw Exception('Team not found');
    final team = Team.fromFirestore(doc);
    return _loadTeamDetailsCached(team);
  }

  // ── 4. READ — all teams owned by current user ──────────────────────────
  Future<List<Team>> getMyTeams() async {
    final snap = await _teams.where('memberIds', arrayContains: _uid).get();
    debugPrint('getMyTeams → ${snap.docs.length} teams found');
    return snap.docs.map((d) => Team.fromFirestore(d)).toList();
  }

  // ── 5. UPDATE team info ────────────────────────────────────────────────
  Future<void> updateTeam({
    required String teamId,
    required String name,
    String bio = '',
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{'name': name, 'bio': bio};
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    await _teams.doc(teamId).update(data);
  }

  // ── 6. DELETE team — only creator can do this ──────────────────────────
  Future<void> deleteTeam(String teamId) async {
    // delete all meetings subcollection first
    final meetings = await _teams.doc(teamId).collection('meetings').get();
    for (final doc in meetings.docs) {
      await doc.reference.delete();
    }

    // clear cache
    _membersCache.remove(teamId);
    _memberIdsCache.remove(teamId);
    _meetingsCache.remove(teamId);

    await _teams.doc(teamId).delete();
  }

  // ── 7. ADD member to team ──────────────────────────────────────────────
  Future<void> addMember({
    required String teamId,
    required String userId,
  }) async {
    // invalidate members cache so it re-fetches with new member
    _memberIdsCache.remove(teamId);
    _membersCache.remove(teamId);

    await _teams.doc(teamId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  // ── 8. REMOVE member from team ─────────────────────────────────────────
  Future<void> removeMember({
    required String teamId,
    required String userId,
  }) async {
    // invalidate members cache
    _memberIdsCache.remove(teamId);
    _membersCache.remove(teamId);

    await _teams.doc(teamId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  // ── 9. LEAVE team — current user removes themselves ────────────────────
  Future<void> leaveTeam(String teamId) async {
    await removeMember(teamId: teamId, userId: _uid);
  }

  // ── 10. CHECK if current user is owner of a team ───────────────────────
  Future<bool> isTeamOwner(String teamId) async {
    final doc = await _teams.doc(teamId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    return data['createdBy'] == _uid;
  }

  // ── 11. INVALIDATE meetings cache — called from MeetingService ─────────
  void invalidateMeetingsCache(String teamId) {
    _meetingsCache.remove(teamId);
    debugPrint('TeamService: meetings cache cleared for $teamId');
  }

  // ── 12. CLEAR all caches — call on sign out ────────────────────────────
  void clearCache() {
    _membersCache.clear();
    _memberIdsCache.clear();
    _meetingsCache.clear();
    debugPrint('TeamService: all caches cleared');
  }

  // ── Private: smart loader — only re-fetches what changed ──────────────
  Future<Team> _loadTeamDetailsCached(Team team) async {
    final cachedIds = _memberIdsCache[team.id];
    final currentIds = team.memberIds;

    // re-fetch members only if memberIds changed
    final memberIdsChanged =
        cachedIds == null ||
        cachedIds.length != currentIds.length ||
        !cachedIds.toSet().containsAll(currentIds.toSet());

    if (memberIdsChanged) {
      debugPrint('TeamService: re-fetching members for "${team.name}"');
      final members = await _getMembers(currentIds);
      _membersCache[team.id] = members;
      _memberIdsCache[team.id] = List.from(currentIds);
    }

    // fetch meetings only if not cached
    if (!_meetingsCache.containsKey(team.id)) {
      debugPrint('TeamService: fetching meetings for "${team.name}"');
      final meetings = await _getMeetings(team.id);
      _meetingsCache[team.id] = meetings;
    }

    return team.copyWith(
      members: _membersCache[team.id] ?? [],
      meetings: _meetingsCache[team.id] ?? [],
    );
  }

  // ── Private: fetch members — chunked (Firestore whereIn max = 10) ──────
  Future<List<AppUser>> _getMembers(List<String> ids) async {
    if (ids.isEmpty) return [];

    final results = <AppUser>[];

    // Firestore whereIn only accepts 10 items max
    // so we split into chunks of 10
    for (var i = 0; i < ids.length; i += 10) {
      final end = (i + 10 > ids.length) ? ids.length : i + 10;
      final chunk = ids.sublist(i, end);

      final snap = await _users
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      results.addAll(snap.docs.map((d) => AppUser.fromFirestore(d)));
    }

    debugPrint('TeamService: loaded ${results.length} members');
    return results;
  }

  // ── Private: fetch meetings subcollection ──────────────────────────────
  Future<List<Meeting>> _getMeetings(String teamId) async {
    final snap = await _teams
        .doc(teamId)
        .collection('meetings')
        .orderBy('scheduledAt')
        .get();

    final meetings = snap.docs.map((d) => Meeting.fromFirestore(d)).toList();
    debugPrint('TeamService: loaded ${meetings.length} meetings for $teamId');
    return meetings;
  }
}
