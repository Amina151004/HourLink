import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/user.dart';
import 'package:hourlink/features/auth/presentation/pages/create_meeting_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/stats_card.dart';
import 'package:hourlink/features/auth/presentation/widgets/team_card.dart';

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key});

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  final List<Team> teams = [
    Team(
      name: 'Team1',
      memberCount: 5,
      meetings: [
        Meeting(
          title: 'Daily setup',
          time: 'Today at 9:00pm',
          platform: 'zoom',
          showBadge: true,
        ),
        Meeting(title: 'Review progress', time: 'Today at 11:00pm'),
        Meeting(
          title: 'Sprint planning',
          time: 'Today at 2:00pm',
          platform: 'zoom',
          showBadge: true,
        ),
      ],
      ownerId: '1', // ✅ owned by current user → counted as active
    ),
    Team(
      name: 'Team2',
      memberCount: 10,
      meetings: [
        Meeting(
          title: 'Daily setup',
          time: 'Today at 12:00pm',
          platform: 'zoom',
          showBadge: true,
        ),
        Meeting(title: 'Review progress', time: 'Today at 1:00am'),
      ],
      members: [
        User(
          id: '1', // ✅ current user is a MEMBER here (not owner) → still active
          name: 'Amina',
          title: 'Member',
          location: 'Tlemcen, Algeria',
          description: '',
          email: 'amina@gmail.com',
          phone: '',
        ),
      ],
      ownerId: '2', // owned by someone else
    ),
    Team(
      name: 'Team3',
      memberCount: 7,
      meetings: [
        Meeting(title: 'Kick-off', time: 'Today at 10:00am', platform: 'meet'),
        Meeting(title: 'Retrospective', time: 'Today at 3:00pm'),
        Meeting(
          title: 'Design review',
          time: 'Today at 5:00pm',
          platform: 'zoom',
          showBadge: true,
        ),
        Meeting(title: 'Sync up', time: 'Today at 6:00pm'),
      ],
      ownerId: '3', // ✅ not owned by current user, no members list → NOT active
    ),
  ];

  // ✅ remplace par l'uid réel de FirebaseAuth.instance.currentUser!.uid
  static const String _currentUserId = '1';

  // ✅ teams où l'utilisateur est owner OU membre
  List<Team> get _activeTeams =>
      teams.where((team) => team.isActiveFor(_currentUserId)).toList();

  // ✅ nombre de teams actives pour l'utilisateur
  int _getActiveTeamsCount() => _activeTeams.length;

  // ✅ total des meetings de toutes les teams actives de l'utilisateur
  // Note: tous les meetings mock contiennent "Today" dans `time` (String),
  // donc on compte tous les meetings des teams actives — à affiner plus tard
  // avec un vrai DateTime sur Meeting pour filtrer le jour exact.
  int _getTodayMeetingsCount() {
    return _activeTeams.fold<int>(
      0,
      (total, team) => total + team.meetings.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sunday, 25 June 2024', style: AppTextStyles.date),
                      const SizedBox(height: 10),
                      Text('Hi, Amina👋!', style: AppTextStyles.subheading),
                    ],
                  ),
                  const Spacer(),
                  // ✅ navigue vers CreateMeetingScreen
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateMeetingScreen(allTeams: teams),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Stat cards ✅ valeurs calculées dynamiquement ──────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatCard(
                  label: 'Meetings Today',
                  value:
                      ' ${_getTodayMeetingsCount().toString().padLeft(2, '0')}',
                ),
                StatCard(
                  label: 'Active Teams',
                  value:
                      ' ${_getActiveTeamsCount().toString().padLeft(2, '0')}',
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ── Section title ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                'Your meetings for Today',
                style: AppTextStyles.greyheading,
              ),
            ),

            const SizedBox(height: 20),

            // ── Team cards ✅ seulement les teams actives de l'utilisateur ──
            ..._activeTeams.map(
              (team) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(child: TeamCard(team: team)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
