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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Check icon ───────────────────────────────────────────────
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 247, 239),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ────────────────────────────────────────────────────
            Text(title, style: AppTextStyles.subheading),
            const SizedBox(height: 8),

            // ── Message ──────────────────────────────────────────────────
            Text(
              message,
              style: AppTextStyles.date,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── Button ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onDone,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
