import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';

class ChatPreview {
  final String id;
  final String? name; // null for direct messages
  final bool isGroup;
  final List<String> memberIds;
  final List<AppUser> members; // loaded separately
  final String? teamId;
  final String lastMessage;
  final DateTime? lastMessageAt;

  ChatPreview({
    required this.id,
    this.name,
    this.isGroup = false,
    this.memberIds = const [],
    this.members = const [],
    this.teamId,
    this.lastMessage = '',
    this.lastMessageAt,
  });

  // for direct messages — returns the other user's name
  String chatName(String currentUserId) {
    if (name != null) return name!;
    final other = members.where((m) => m.id != currentUserId).firstOrNull;
    return other?.name ?? 'Unknown';
  }

  factory ChatPreview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatPreview(
      id: doc.id,
      name: data['name'],
      isGroup: data['isGroup'] ?? false,
      memberIds: List<String>.from(
        data['memberIds'] ?? [],
      ), // ← 'members' → 'memberIds'
      teamId: data['teamId'],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isGroup': isGroup,
      'memberIds': memberIds, // ← 'members' → 'memberIds'
      'teamId': teamId,
      'lastMessage': lastMessage,
      'lastMessageAt': FieldValue.serverTimestamp(),
    };
  }

  ChatPreview copyWith({List<AppUser>? members}) {
    return ChatPreview(
      id: id,
      name: name,
      isGroup: isGroup,
      memberIds: memberIds,
      members: members ?? this.members,
      teamId: teamId,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
    );
  }
}
