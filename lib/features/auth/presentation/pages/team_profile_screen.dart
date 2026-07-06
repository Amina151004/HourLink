import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/services/team_service.dart';
import 'package:hourlink/features/auth/presentation/pages/edit_team_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/user_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/leave_team_dialog.dart';
import 'package:hourlink/features/auth/presentation/widgets/meeting_row.dart';
import 'package:hourlink/features/auth/presentation/widgets/see_all_meetings_button.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';
import 'package:hourlink/features/auth/presentation/widgets/team_more_options_menu.dart';

class TeamProfileScreen extends StatefulWidget {
  final Team team;
  final String currentUserId;

  const TeamProfileScreen({
    super.key,
    required this.team,
    required this.currentUserId,
  });

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  final TeamService _teamService = TeamService();
  int _selectedTab = 0;
  Team? __team;
  Team get _team => __team ?? widget.team;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  void _loadTeam() {
    _teamService.getUserTeamsStream().listen((teams) {
      final updated = teams.where((t) => t.id == widget.team.id).firstOrNull;
      if (updated != null && mounted) {
        setState(() => __team = updated);
      }
    });
  }

  Future<void> _leaveTeam() async {
    await _teamService.leaveTeam(_team.id);
  }

  Future<void> _removeMember(AppUser user) async {
    await _teamService.removeMember(teamId: _team.id, userId: user.id);
    if (mounted) {
      setState(() => _team.members.remove(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = _team.isOwnedBy(widget.currentUserId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: AppColors.background,
            child: Column(
              children: [
                const SizedBox(height: 60),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: AppColors.textDark,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      if (isOwner)
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppColors.textDark,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTeamScreen(team: _team),
                              ),
                            );
                          },
                        )
                      else
                        TeamMoreOptionsMenu(
                          onLeaveTeam: () {
                            LeaveTeamDialog.show(
                              context,
                              teamName: _team.name,
                              onConfirm: () async {
                                await _leaveTeam();
                                if (!context.mounted) return;
                                SuccessDialog.show(
                                  context,
                                  title: 'Left Team',
                                  message: 'You have left "${_team.name}".',
                                  onDone: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),

                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.avatarPast,
                    shape: BoxShape.circle,
                    image: _team.photoUrl != null && _team.photoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_team.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _team.photoUrl == null || _team.photoUrl!.isEmpty
                      ? Center(
                          child: Text(
                            _team.name.isNotEmpty
                                ? _team.name[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.heading.copyWith(
                              color: AppColors.textDark,
                              fontSize: 30,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                Text(_team.name, style: AppTextStyles.subheading),
                const SizedBox(height: 6),
                Text(_team.bio, style: AppTextStyles.date),

                const SizedBox(height: 24),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border.all(color: AppColors.textDark, width: 0.5),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Meetings',
                          isActive: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        _TabButton(
                          label: 'Members',
                          isActive: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _selectedTab == 0
                        ? _MeetingsTab(team: _team)
                        : _MembersTab(
                            members: _team.members,
                            isOwner: isOwner,
                            onMemberTap: (user) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(
                                    user: user,
                                    currentUserId: widget.currentUserId,
                                  ),
                                ),
                              );
                            },
                            onRemoveMember: _removeMember,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab button ────────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : AppColors.background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.textDark : AppColors.textGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Meetings tab ──────────────────────────────────────────────────────────────
class _MeetingsTab extends StatelessWidget {
  final Team team;

  const _MeetingsTab({required this.team});

  @override
  Widget build(BuildContext context) {
    final meetings = team.meetings;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: meetings.length,
              itemBuilder: (context, index) => MeetingRow(
                title: meetings[index].title,
                time: meetings[index].formattedTime,
                platform: meetings[index].platform,
                showBadge: meetings[index].showBadge,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: SeeAllMeetingsButton(team: team),
          ),
        ],
      ),
    );
  }
}

// ── Members tab ───────────────────────────────────────────────────────────────
class _MembersTab extends StatelessWidget {
  final List<AppUser> members;
  final bool isOwner;
  final void Function(AppUser user) onMemberTap;
  final void Function(AppUser user) onRemoveMember;

  const _MembersTab({
    required this.members,
    required this.isOwner,
    required this.onMemberTap,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final user = members[index];
        return GestureDetector(
          onTap: () => onMemberTap(user),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.avatarPlaceholder,
                        shape: BoxShape.circle,
                        image: user.photoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(user.photoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user.photoUrl.isEmpty
                          ? Center(
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(user.title, style: AppTextStyles.date),
                        ],
                      ),
                    ),
                    isOwner
                        ? IconButton(
                            icon: const Icon(
                              Icons.person_remove_outlined,
                              size: 22,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => onRemoveMember(user),
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 22,
                              color: AppColors.textGrey,
                            ),
                            onPressed: () {},
                          ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: AppColors.divider,
                indent: 25,
                endIndent: 25,
              ),
            ],
          ),
        );
      },
    );
  }
}
