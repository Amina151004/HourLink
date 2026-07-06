import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

/// The "⋮" button on a team profile for non-owner members.
/// Opens a popup menu with team-related actions (currently: Leave Team).
class TeamMoreOptionsMenu extends StatelessWidget {
  final VoidCallback onLeaveTeam;

  const TeamMoreOptionsMenu({super.key, required this.onLeaveTeam});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 24, color: AppColors.textDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: AppColors.white,
      onSelected: (value) {
        if (value == 'leave') onLeaveTeam();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'leave',
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 18,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Text(
                'Leave Team',
                style: AppTextStyles.body.copyWith(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
