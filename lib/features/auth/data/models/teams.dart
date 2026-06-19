import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/user.dart';

class Team {
  final String name;
  final int memberCount;
  final String? bio;
  final List<Meeting> meetings;
  final List<User> members;

  Team({
    required this.name,
    required this.memberCount,
    this.bio,
    required this.meetings,
    List<User>? members, // ✅ nullable en paramètre
  }) : members = members ?? []; // ✅ fallback vide dans l'initializer
}
