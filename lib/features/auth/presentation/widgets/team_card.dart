import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/presentation/widgets/meeting_row.dart';

class TeamCard extends StatelessWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.88,
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textDark, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: [
          // ── Team header ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
              const SizedBox(width: 12),

              // Team name
              Text(team.name, style: AppTextStyles.body),

              // ✅ Spacer au lieu de SizedBox(width: 30)
              const Spacer(),

              // ✅ Badge sans largeur fixe
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.avatarPlaceholder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${team.memberCount} members',
                  style: AppTextStyles.date.copyWith(
                    color: const Color.fromARGB(221, 52, 52, 52),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Meetings scrollables ───────────────────────────────────────
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: team.meetings.length,
              itemBuilder: (context, index) => MeetingRow(
                title: team.meetings[index].title,
                time: team.meetings[index].time,
                platform: team.meetings[index].platform,
                showBadge: team.meetings[index].showBadge,
              ),
            ),
          ),
          // Dans team_card.dart, après le Expanded(ListView...)
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // navigation vers la page de tous les meetings de cette team
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all meetings',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
