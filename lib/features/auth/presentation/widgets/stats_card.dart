import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

// ── Reusable stat card ─────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.42, // responsive instead of hardcoded 150
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textDark, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodyBold),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
