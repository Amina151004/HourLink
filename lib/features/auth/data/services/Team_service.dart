import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';

class TeamService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;
  CollectionReference get _teams => _firestore.collection('teams');
  CollectionReference get _users => _firestore.collection('users');

  // ── 1. CREATE ──────────────────────────────────────────────────────────
  Future<Team> createTeam({
    required String name,
    String bio = '',
    String photoUrl = '', // ✅ added
  }) async {
    final ref = await _teams.add({
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl, // ✅ added
      'createdBy': _uid,
      'memberIds': [_uid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    return Team.fromFirestore(doc);
  }

  // ── 2. STREAM — user's teams (real-time) ───────────────────────────────
  Stream<List<Team>> getUserTeamsStream() {
    return _teams.where('memberIds', arrayContains: _uid).snapshots().asyncMap((
      snapshot,
    ) async {
      final teams = snapshot.docs.map((d) => Team.fromFirestore(d)).toList();
      return Future.wait(teams.map((t) => _loadTeamDetails(t)));
    });
  }

  // ── 3. READ — single team with members + meetings ──────────────────────
  Future<Team> getTeamWithDetails(String teamId) async {
    final doc = await _teams.doc(teamId).get();
    final team = Team.fromFirestore(doc);
    return _loadTeamDetails(team);
  }

  // ── 4. UPDATE team info ────────────────────────────────────────────────
  Future<void> updateTeam({
    required String teamId,
    required String name,
    String bio = '',
    String? photoUrl, // null = don't touch the existing photo
  }) async {
    final data = <String, dynamic>{'name': name, 'bio': bio};
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl; // ✅ only write when actually provided
    }
    await _teams.doc(teamId).update(data);
  }

  // ── 5. DELETE team (createdBy only) ───────────────────────────────────
  Future<void> deleteTeam(String teamId) async {
    final meetings = await _teams.doc(teamId).collection('meetings').get();
    for (final doc in meetings.docs) {
      await doc.reference.delete();
    }
    await _teams.doc(teamId).delete();
  }

  // ── 6. ADD member ──────────────────────────────────────────────────────
  Future<void> addMember({
    required String teamId,
    required String userId,
  }) async {
    await _teams.doc(teamId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  // ── 7. REMOVE member ───────────────────────────────────────────────────
  Future<void> removeMember({
    required String teamId,
    required String userId,
  }) async {
    await _teams.doc(teamId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  // ── 8. LEAVE team (current user removes themselves) ────────────────────
  Future<void> leaveTeam(String teamId) async {
    await removeMember(teamId: teamId, userId: _uid);
  }

  // ── 9. GET teams créées par l'utilisateur courant ──────────────────────
  Future<List<Team>> getMyTeams() async {
    final snap = await _teams.where('memberIds', arrayContains: _uid).get();
    debugPrint('getMyTeams uid: $_uid');
    debugPrint('getMyTeams results: ${snap.docs.length}');
    return snap.docs.map((d) => Team.fromFirestore(d)).toList();
  }

  // ── Private: load members + meetings for a team ────────────────────────
  Future<Team> _loadTeamDetails(Team team) async {
    final members = await _getMembers(team.memberIds);
    final meetings = await _getMeetings(team.id);
    return team.copyWith(members: members, meetings: meetings);
  }

  // ── Private: fetch AppUser list (chunked — Firestore max whereIn = 10) ─
  Future<List<AppUser>> _getMembers(List<String> ids) async {
    if (ids.isEmpty) return [];
    final results = <AppUser>[];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snap = await _users
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snap.docs.map((d) => AppUser.fromFirestore(d)));
    }
    return results;
  }

  // ── Private: fetch meetings subcollection ──────────────────────────────
  Future<List<Meeting>> _getMeetings(String teamId) async {
    final snap = await _teams
        .doc(teamId)
        .collection('meetings')
        .orderBy('scheduledAt')
        .get();
    return snap.docs.map((d) => Meeting.fromFirestore(d)).toList();
  }
}
