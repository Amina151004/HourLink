import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/data/models/user.dart';
import 'package:hourlink/features/auth/presentation/widgets/success_dialog.dart';
import 'package:hourlink/features/auth/presentation/widgets/team_list_item.dart';

class AddToTeamScreen extends StatefulWidget {
  final User user;
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
  // ── Set des teams sélectionnées ──────────────────────────────────────────
  final Set<String> _selectedTeamNames = {};

  void _toggleTeam(String teamName) {
    setState(() {
      if (_selectedTeamNames.contains(teamName)) {
        _selectedTeamNames.remove(teamName);
      } else {
        _selectedTeamNames.add(teamName);
      }
    });
  }

  void _addToTeams() {
    // ── Ici tu appelleras Firestore plus tard ────────────────────────────
    // Pour l'instant : affiche un message de succès puis retourne en arrière
    SuccessDialog.show(
      context,
      message: 'Amina added to 2 teams.',
      onDone: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool hasSelection = _selectedTeamNames.isNotEmpty;

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

          // ── Team list with checkboxes ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: widget.allTeams.length,
              itemBuilder: (context, index) {
                final team = widget.allTeams[index];
                final isSelected = _selectedTeamNames.contains(team.name);

                return GestureDetector(
                  onTap: () => _toggleTeam(team.name),
                  behavior: HitTestBehavior.opaque,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team.name,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    team.bio ?? 'team bio ....',
                                    style: AppTextStyles.date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // ✅ Checkbox de sélection
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
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
                                borderRadius: BorderRadius.circular(6),
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
            ),
          ),

          // ── Add to team button (apparaît quand sélection non vide) ─────
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
                        onPressed: _addToTeams,
                        child: Text(
                          'Add to ${_selectedTeamNames.length} team${_selectedTeamNames.length > 1 ? 's' : ''}',
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
