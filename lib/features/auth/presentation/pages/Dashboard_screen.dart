import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/presentation/pages/create_meeting_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/stats_card.dart';
import 'package:hourlink/features/auth/presentation/widgets/team_card.dart';
import 'package:hourlink/features/auth/data/services/team_service.dart'; // ✅ import
import 'package:firebase_auth/firebase_auth.dart'; // ✅ import
// add this import at the top

class MyDashboard extends StatefulWidget {
  final AppUser currentUser;
  const MyDashboard({super.key, required this.currentUser});

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  final TeamService _teamService = TeamService(); // ✅ service instance
  final List<Team> teams = []; // keep as local state
  StreamSubscription<List<Team>>? _teamsSubscription;

  // ✅ get current user id from Firebase Auth
  String get _currentUserId => FirebaseAuth.instance.currentUser!.uid;

  // ✅ teams where user is owner OR member
  List<Team> get _activeTeams =>
      teams.where((team) => team.isActiveFor(_currentUserId)).toList();

  // ✅ number of active teams for the user
  int _getActiveTeamsCount() => _activeTeams.length;

  // ✅ total meetings from all active teams
  int _getTodayMeetingsCount() {
    return _activeTeams.fold<int>(
      0,
      (total, team) => total + team.meetings.length,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTeams(); // ✅ load teams when screen initializes
  }

  @override
  void dispose() {
    _teamsSubscription?.cancel(); // 👈 close the tap
    super.dispose();
  }

  // ✅ method to load teams from service
  void _loadTeams() {
    _teamsSubscription = _teamService.getUserTeamsStream().listen((
      loadedTeams,
    ) {
      if (mounted) {
        setState(() {
          teams.clear();
          teams.addAll(loadedTeams);
        });
      }
    });
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
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                        style: AppTextStyles.date,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hi, ${widget.currentUser.name}👋!',
                        style: AppTextStyles.subheading,
                      ), // ✅ use currentUser from widget
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColors.textDark),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateMeetingScreen(
                            allTeams: teams,
                            currentUserId: widget.currentUser.id,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Stat cards ──────────────────────────────────────────────
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

            // ── Team cards ──────────────────────────────────────────────
            if (_activeTeams.isEmpty) // ✅ handle empty state
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No active teams. Create or join a team to get started!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
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
