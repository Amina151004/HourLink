import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/user.dart';
import 'package:hourlink/features/auth/presentation/pages/CreateTeamScreen.dart';
import 'package:hourlink/features/auth/presentation/pages/team_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/team_list_item.dart';
import 'package:hourlink/features/auth/presentation/widgets/app_search_bar.dart';

class MyTeamsScreen extends StatefulWidget {
  const MyTeamsScreen({super.key});

  @override
  State<MyTeamsScreen> createState() => _MyTeamsScreenState();
}

class _MyTeamsScreenState extends State<MyTeamsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  late final List<Team> _teams = [
    Team(
      name: 'Team first',
      memberCount: 5,
      bio: 'team bio ....',
      meetings: [
        Meeting(
          title: 'Daily setup',
          time: 'Today at 9:00pm',
          platform: 'zoom',
          showBadge: true,
        ),
        Meeting(title: 'Review progress', time: 'Today at 11:00pm'),
      ],
      members: [
        User(
          name: 'Amina B.',
          title: 'Freelancer',
          location: 'Tlemcen, Algeria',
          description: 'Write your informations here........',
          email: 'amina@gmail.com',
          phone: '0550-23-23-34',
          id: '3',
        ),
        User(
          name: 'Karim D.',
          title: 'Developer',
          location: 'Alger, Algeria',
          description: 'Write your informations here........',
          email: 'karim@gmail.com',
          phone: '0660-11-22-33',
          id: '2',
        ),
        User(
          name: 'Sara M.',
          title: 'Designer',
          location: 'Oran, Algeria',
          description: 'Write your informations here........',
          email: 'sara@gmail.com',
          phone: '0770-44-55-66',
          id: '3',
        ),
      ],
      ownerId: '1',
    ),
    Team(
      name: 'Team2',
      memberCount: 10,
      bio: 'team bio ....',
      meetings: [],
      members: [
        User(
          name: 'Yacine R.',
          title: 'Manager',
          location: 'Alger, Algeria',
          description: 'Write your informations here........',
          email: 'yacine@gmail.com',
          phone: '0550-99-88-77',
          id: '3',
        ),
        User(
          name: 'Nadia K.',
          title: 'Designer',
          location: 'Annaba, Algeria',
          description: 'Write your informations here........',
          email: 'nadia@gmail.com',
          phone: '0660-33-44-55',
          id: '2',
        ),
      ],
      ownerId: '2',
    ),
    Team(
      name: 'Team3',
      memberCount: 7,
      bio: 'team bio ....',
      meetings: [],
      members: [
        User(
          name: 'Omar S.',
          title: 'Developer',
          location: 'Constantine, Algeria',
          description: 'Write your informations here........',
          email: 'omar@gmail.com',
          phone: '0770-12-34-56',
          id: '3',
        ),
      ],
      ownerId: '3',
    ),
    Team(
      name: 'Team4',
      memberCount: 3,
      bio: 'team bio ....',
      meetings: [],
      members: [
        User(
          name: 'Lina T.',
          title: 'Analyst',
          location: 'Oran, Algeria',
          description: 'Write your informations here........',
          email: 'lina@gmail.com',
          phone: '0550-65-43-21',
          id: '4',
        ),
      ],
      ownerId: '4',
    ),
  ];

  List<Team> get _filteredTeams {
    if (_query.trim().isEmpty) return _teams;
    final q = _query.trim().toLowerCase();
    return _teams.where((team) => team.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTeams = _filteredTeams;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 1),
              child: Row(
                children: [
                  Text('My Teams', style: AppTextStyles.subheading),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateTeamScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Search bar ───────────────────────────────────────────────
            AppSearchBar(
              controller: _searchController,
              hintText: 'Search teams...',
              onChanged: (value) => setState(() => _query = value),
            ),

            // ── Teams list ───────────────────────────────────────────────
            if (filteredTeams.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Center(
                  child: Text(
                    'No teams found',
                    style: AppTextStyles.body.copyWith(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTeams.length,
                itemBuilder: (context, index) => TeamListItem(
                  team: filteredTeams[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TeamProfileScreen(team: filteredTeams[index]),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
