import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/presentation/widgets/meeting_row.dart';
import 'package:hourlink/features/auth/presentation/widgets/see_all_meetings_button.dart';

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
          // ── Team header ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
              const SizedBox(width: 12),
              Text(team.name, style: AppTextStyles.body),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.avatarPlaceholder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${team.memberCount} members',
                  style: AppTextStyles.date.copyWith(color: AppColors.textDark),
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
                time: team.meetings[index].formattedTime,
                platform: team.meetings[index].platform,
                showBadge: team.meetings[index].showBadge,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ✅ widget réutilisable — style compact pour la dashboard card
          Align(
            alignment: Alignment.centerRight,
            child: SeeAllMeetingsButton(
              team: team,
              textStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textDark,
              ),
              iconSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
