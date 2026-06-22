import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/meeting.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/user.dart';
import 'package:hourlink/features/auth/presentation/pages/edit_team_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/user_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/leave_team_dialog.dart';
import 'package:hourlink/features/auth/presentation/widgets/meeting_row.dart';
import 'package:hourlink/features/auth/presentation/widgets/see_all_meetings_button.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';
import 'package:hourlink/features/auth/presentation/widgets/team_more_options_menu.dart';

class TeamProfileScreen extends StatefulWidget {
  final Team team;

  const TeamProfileScreen({super.key, required this.team});

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // ✅ remplace par l'uid réel de FirebaseAuth.instance.currentUser!.uid
    const String currentUserId = '1';
    final bool isOwner = widget.team.isOwnedBy(currentUserId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header zone ────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            child: Column(
              children: [
                const SizedBox(height: 60),

                // ── Back + (3 dots if not owner / pencil if owner) ──────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      if (isOwner)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 22),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditTeamScreen(team: widget.team),
                              ),
                            );
                          },
                        )
                      else
                        TeamMoreOptionsMenu(
                          onLeaveTeam: () {
                            LeaveTeamDialog.show(
                              context,
                              teamName: widget.team.name,
                              onConfirm: () {
                                // ── Ici tu retireras l'utilisateur de Firestore plus tard ──
                                // await teamRef.update({'members': FieldValue.arrayRemove([uid])});

                                // ✅ réutilise SuccessDialog pour confirmer la sortie
                                SuccessDialog.show(
                                  context,
                                  title: 'Left Team',
                                  message:
                                      'You have left "${widget.team.name}".',
                                  onDone: () {
                                    Navigator.pop(context); // ferme dialog
                                    Navigator.pop(
                                      context,
                                    ); // retourne à MyTeamsScreen
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
                    color: AppColors.avatarPlaceholder,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Name + bio ────────────────────────────────────────────
                Text(widget.team.name, style: AppTextStyles.subheading),
                const SizedBox(height: 6),
                Text(
                  widget.team.bio ?? 'team bio ....',
                  style: AppTextStyles.date,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── White card with tabs ───────────────────────────────────────
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
                        ? _MeetingsTab(team: widget.team)
                        : _MembersTab(
                            members: widget.team.members,
                            isOwner: isOwner,
                            onMemberTap: (user) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(user: user),
                                ),
                              );
                            },
                            onRemoveMember: (user) {
                              setState(() {
                                widget.team.members.remove(user);
                              });
                            },
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
                time: meetings[index].time,
                platform: meetings[index].platform,
                showBadge: meetings[index].showBadge,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: SeeAllMeetingsButton(team: team), // ✅ widget réutilisable
          ),
        ],
      ),
    );
  }
}

// ── Members tab ───────────────────────────────────────────────────────────────
class _MembersTab extends StatelessWidget {
  final List<User> members;
  final bool isOwner;
  final void Function(User user) onMemberTap;
  final void Function(User user) onRemoveMember;

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
                      ),
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
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 22,
                              color: AppColors.textGrey,
                            ),
                            onPressed: () {},
                          ),
                  ],
                ),
              ),
              const Divider(
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
