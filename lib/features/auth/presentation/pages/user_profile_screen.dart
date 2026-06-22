import 'package:flutter/material.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/chat_preview.dart';
import 'package:hourlink/features/auth/data/models/user.dart';
import 'package:hourlink/features/auth/presentation/pages/add_to_team_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/chat_room_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/profile_card_body.dart';
import 'package:hourlink/features/auth/presentation/widgets/profile_screen_shell.dart';

/// Viewing another member's profile — header action is "add to team",
/// card top-right action is "open chat".
class UserProfileScreen extends StatelessWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // mock teams — à remplacer par Firestore plus tard
    final List<Team> allTeams = [
      Team(
        name: 'Team1',
        memberCount: 5,
        bio: 'team bio ....',
        meetings: [],
        ownerId: '1',
      ),
      Team(
        name: 'Team2',
        memberCount: 10,
        bio: 'team bio ....',
        meetings: [],
        ownerId: '2',
      ),
      Team(
        name: 'Team3',
        memberCount: 7,
        bio: 'team bio ....',
        meetings: [],
        ownerId: '3',
      ),
      Team(
        name: 'Team4',
        memberCount: 3,
        bio: 'team bio ....',
        meetings: [],
        ownerId: '4',
      ),
    ];

    return ProfileScreenShell(
      headerRightIcon: Icons.add,
      onHeaderRightTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddToTeamScreen(user: user, allTeams: allTeams),
          ),
        );
      },
      body: ProfileCardBody(
        user: user,
        topRightIcon: Icons.chat_bubble_outline_rounded,
        onTopRightTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                chat: ChatPreview(user: user, lastMessage: '', time: ''),
              ),
            ),
          );
        },
      ),
    );
  }
}
