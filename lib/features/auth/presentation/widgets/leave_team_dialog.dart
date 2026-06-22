import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

/// Confirmation dialog shown before a non-owner member leaves a team.
/// Reusable anywhere a "leave team" action is offered.
class LeaveTeamDialog extends StatelessWidget {
  final String teamName;
  final VoidCallback onConfirm;

  const LeaveTeamDialog({
    super.key,
    required this.teamName,
    required this.onConfirm,
  });

  // ── Helper static pour l'appeler facilement partout ────────────────────
  static void show(
    BuildContext context, {
    required String teamName,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => LeaveTeamDialog(teamName: teamName, onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.white, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon badge, dashed-style ring in primary tone ────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.35),
                  width: 1.5,
                ),
                color: AppColors.primary.withOpacity(0.08),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Leave Team?',
              style: AppTextStyles.subheading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
                children: [
                  const TextSpan(text: 'You\'ll lose access to '),
                  TextSpan(
                    text: teamName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const TextSpan(
                    text: '. You\'ll need a new invite to rejoin.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ── Actions: outlined cancel + filled primary leave ──────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: BorderSide(color: AppColors.textDark, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // ferme le dialog
                      onConfirm();
                    },
                    child: Text(
                      'Leave',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
