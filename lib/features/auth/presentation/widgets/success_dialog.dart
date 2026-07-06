import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onDone;

  const SuccessDialog({
    super.key,
    this.title = 'Success!',
    required this.message,
    this.buttonLabel = 'Done',
    required this.onDone,
  });

  // ── Helper statique pour l'appeler facilement partout ─────────────────
  static void show(
    BuildContext context, {
    String title = 'Success!',
    required String message,
    String buttonLabel = 'Done',
    required VoidCallback onDone,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        onDone: onDone,
      ),
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
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon badge, ring in primary tone ─────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: AppTextStyles.subheading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 26),

            // ── Button: filled primary ──────────────────────────────────
            SizedBox(
              width: double.infinity,
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
                onPressed: onDone,
                child: Text(
                  buttonLabel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
