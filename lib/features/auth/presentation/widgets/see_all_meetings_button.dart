import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/teams.dart';
import 'package:hourlink/features/auth/presentation/pages/all_team_meetings_screen.dart';

/// "See all meetings ›" link — navigates to the full meetings list
/// for the given team. Reusable anywhere a team's meetings preview
/// is shown (team profile, dashboard cards, etc.).
///
/// [textStyle] lets each context control sizing — e.g. a compact
/// dashboard card vs. a roomier team profile tab.
class SeeAllMeetingsButton extends StatelessWidget {
  final Team team;
  final TextStyle? textStyle;
  final double iconSize;

  const SeeAllMeetingsButton({
    super.key,
    required this.team,
    this.textStyle,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? AppTextStyles.body;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AllTeamMeetingsScreen(team: team)),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('See all meetings', style: style),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: iconSize, color: style.color),
        ],
      ),
    );
  }
}
