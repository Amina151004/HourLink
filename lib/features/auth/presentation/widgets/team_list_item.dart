import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';

class TeamListItem extends StatelessWidget {
  final Team team;
  final VoidCallback? onTap;

  const TeamListItem({super.key, required this.team, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              children: [
                // ── Avatar ───────────────────────────────────────────────
                // ── Avatar ───────────────────────────────────────────────────────
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.avatarPast,
                    shape: BoxShape.circle,
                    image: team.photoUrl != null && team.photoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(team.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: team.photoUrl == null || team.photoUrl!.isEmpty
                      ? Center(
                          child: Text(
                            team.name.isNotEmpty
                                ? team.name[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // ── Name + bio ────────────────────────────────────────────
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
                        team.bio,
                        style: AppTextStyles.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ── Members badge ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.textDark, width: 0.5),
                  ),
                  child: Text(
                    '${team.memberCount} members',
                    style: AppTextStyles.date.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Divider ───────────────────────────────────────────────────────
        Divider(color: AppColors.divider, height: 1, indent: 25, endIndent: 25),
      ],
    );
  }
}
