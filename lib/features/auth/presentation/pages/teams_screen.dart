import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/presentation/pages/CreateTeamScreen.dart';
import 'package:hourlink/features/auth/presentation/pages/team_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/team_list_item.dart';
import 'package:hourlink/features/auth/presentation/widgets/app_search_bar.dart';
import 'package:hourlink/features/auth/data/services/team_service.dart';

class MyTeamsScreen extends StatefulWidget {
  final AppUser currentUser;
  const MyTeamsScreen({super.key, required this.currentUser});

  @override
  State<MyTeamsScreen> createState() => _MyTeamsScreenState();
}

class _MyTeamsScreenState extends State<MyTeamsScreen> {
  final TeamService _teamService = TeamService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<Team> _teams = [];
  bool _isLoading = true;

  List<Team> get _filteredTeams {
    if (_query.trim().isEmpty) return _teams;
    final q = _query.trim().toLowerCase();
    return _teams.where((team) => team.name.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTeams() {
    _teamService.getUserTeamsStream().listen((loadedTeams) {
      if (mounted) {
        setState(() {
          _teams = loadedTeams;
          _isLoading = false;
        });
      }
    });
  }

  void _refreshTeams() {
    setState(() => _isLoading = true);
    _loadTeams();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTeams = _filteredTeams;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshTeams();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 1),
                child: Row(
                  children: [
                    Text('My Teams', style: AppTextStyles.subheading),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.add, color: AppColors.textDark),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateTeamScreen(),
                          ),
                        );
                        if (result == true) _refreshTeams();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AppSearchBar(
                controller: _searchController,
                hintText: 'Search teams...',
                onChanged: (value) => setState(() => _query = value),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredTeams.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 40,
                  ),
                  child: Center(
                    child: Text(
                      _query.isEmpty
                          ? 'You are not in any teams yet.\nCreate your first team!'
                          : 'No teams found matching "$_query"',
                      textAlign: TextAlign.center,
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
                          builder: (_) => TeamProfileScreen(
                            team: filteredTeams[index],
                            currentUserId: widget.currentUser.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
