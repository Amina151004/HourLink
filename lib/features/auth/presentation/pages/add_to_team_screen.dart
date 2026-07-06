import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/services/team_service.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';

class AddToTeamScreen extends StatefulWidget {
  final AppUser user;
  final List<Team> allTeams;

  const AddToTeamScreen({
    super.key,
    required this.user,
    required this.allTeams,
  });

  @override
  State<AddToTeamScreen> createState() => _AddToTeamScreenState();
}

class _AddToTeamScreenState extends State<AddToTeamScreen> {
  final TeamService _teamService = TeamService();
  final Set<String> _selectedTeamIds = {};
  bool _isLoading = false;

  void _toggleTeam(String teamId) {
    setState(() {
      if (_selectedTeamIds.contains(teamId)) {
        _selectedTeamIds.remove(teamId);
      } else {
        _selectedTeamIds.add(teamId);
      }
    });
  }

  Future<void> _addToTeams() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Ajouter l'utilisateur à chaque team sélectionnée
      await Future.wait(
        _selectedTeamIds.map(
          (teamId) =>
              _teamService.addMember(teamId: teamId, userId: widget.user.id),
        ),
      );

      if (!mounted) return;
      SuccessDialog.show(
        context,
        message:
            '${widget.user.name} added to ${_selectedTeamIds.length} team${_selectedTeamIds.length > 1 ? 's' : ''}.',
        onDone: () {
          Navigator.pop(context); // ferme le dialog
          Navigator.pop(context); // retourne à UserProfileScreen
        },
      );
    } catch (e) {
      debugPrint('Error adding to teams: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add to teams: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool hasSelection = _selectedTeamIds.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Teams List', style: AppTextStyles.subheading),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Team list ──────────────────────────────────────────────────
          Expanded(
            child: widget.allTeams.isEmpty
                ? Center(
                    child: Text(
                      'You have no teams yet',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.allTeams.length,
                    itemBuilder: (context, index) {
                      final team = widget.allTeams[index];
                      // Griser les teams dont l'user est déjà membre
                      final alreadyMember = team.memberIds.contains(
                        widget.user.id,
                      );
                      final isSelected = _selectedTeamIds.contains(team.id);

                      return GestureDetector(
                        onTap: alreadyMember
                            ? null
                            : () => _toggleTeam(team.id),
                        behavior: HitTestBehavior.opaque,
                        child: Opacity(
                          opacity: alreadyMember ? 0.4 : 1.0,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.avatarPlaceholder,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Name + bio
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            team.name,
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            team.bio,
                                            style: AppTextStyles.date,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (alreadyMember)
                                            Text(
                                              'Already a member',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: AppColors.textGrey,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Checkbox
                                    if (!alreadyMember)
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textGrey,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
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
                        ),
                      );
                    },
                  ),
          ),

          // ── Add button ────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: hasSelection ? 90 : 0,
            child: hasSelection
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading ? null : _addToTeams,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Add to ${_selectedTeamIds.length} team${_selectedTeamIds.length > 1 ? 's' : ''}',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
