import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/user.dart';

class Team {
  final String name;
  final int memberCount;
  final String? bio;
  final List<Meeting> meetings;
  final List<User> members;
  final String ownerId;

  Team({
    required this.name,
    required this.memberCount,
    this.bio,
    required this.meetings,
    List<User>? members,
    required this.ownerId,
  }) : members = members ?? [];

  bool isOwnedBy(String currentUserId) => ownerId == currentUserId;

  // ✅ true si l'utilisateur est owner OU dans la liste des membres
  bool isActiveFor(String currentUserId) {
    return ownerId == currentUserId ||
        members.any((member) => member.id == currentUserId);
  }
}
