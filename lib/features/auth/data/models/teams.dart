import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';

class Team {
  final String id;
  final String name;
  final String bio;
  final String? photoUrl;
  final String createdBy;
  final List<String> memberIds; // ← just UIDs stored in Firestore
  final List<AppUser> members; // ← full objects loaded separately
  final List<Meeting> meetings; // ← loaded from subcollection
  final DateTime? createdAt;

  Team({
    required this.id,
    required this.name,
    this.bio = '',
    this.photoUrl,
    required this.createdBy,
    this.memberIds = const [],
    this.members = const [],
    this.meetings = const [],
    this.createdAt,
  });

  int get memberCount => memberIds.length;

  bool isOwnedBy(String userId) => createdBy == userId;

  bool isActiveFor(String userId) =>
      createdBy == userId || memberIds.contains(userId);

  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'],
      createdBy: data['createdBy'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []), // ← corrigé
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'createdBy': createdBy,
      'memberIds': memberIds, // ← corrigé
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Team copyWith({List<AppUser>? members, List<Meeting>? meetings}) {
    return Team(
      id: id,
      name: name,
      bio: bio,
      photoUrl: photoUrl,
      createdBy: createdBy,
      memberIds: memberIds,
      members: members ?? this.members,
      meetings: meetings ?? this.meetings,
      createdAt: createdAt,
    );
  }
}
