import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

// ── Single meeting row ─────────────────────────────────────────────────────
class MeetingRow extends StatelessWidget {
  final String title;
  final String time;
  final String? platform;
  final bool showBadge;

  const MeetingRow({
    super.key,
    required this.title,
    required this.time,
    this.platform,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── IntrinsicHeight lets the blue bar stretch to match row height ──
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Blue left border (stretches automatically) ─────────────
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // ── Title + time + platform ────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: AppTextStyles.bodyBold),
                      const SizedBox(height: 2),
                      Text(time, style: AppTextStyles.caption),
                      if (platform != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.videocam_outlined,
                              size: 14,
                              color: AppColors.textGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(platform!, style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Coming badge ───────────────────────────────────────────
              if (showBadge)
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'coming',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(color: AppColors.divider),
      ],
    );
  }
}
