import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
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
    ),
  ];

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

            // ── Header ✅ padding symétrique + Spacer ─────────────────────
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
                  // ✅ Spacer au lieu de SizedBox(width: 120)
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Stat cards ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                StatCard(label: 'Meetings Today', value: ' 06'),
                StatCard(label: 'Active Teams', value: ' 10'),
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

            // ── Team cards ────────────────────────────────────────────────
            ...teams.map(
              (team) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(child: TeamCard(team: team)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
