import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/presentation/widgets/meeting_row.dart';

/// Full, scrollable list of every meeting for a given team.
/// Reached via the "See all meetings" link on the team profile.
class AllTeamMeetingsScreen extends StatelessWidget {
  final Team team;

  const AllTeamMeetingsScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // ── Header: back + team name + avatar ──────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    team.name,
                    style: AppTextStyles.subheading,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.avatarPlaceholder,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Meetings list ─────────────────────────────────────────────
          Expanded(
            child: team.meetings.isEmpty
                ? Center(
                    child: Text(
                      'No meetings yet',
                      style: AppTextStyles.date.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                    ),
                    itemCount: team.meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = team.meetings[index];
                      return MeetingRow(
                        title: meeting.title,
                        time: meeting.time,
                        platform: meeting.platform,
                        showBadge: meeting.showBadge,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
