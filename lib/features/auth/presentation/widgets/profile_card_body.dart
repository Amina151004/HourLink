import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';

/// Shared body of the white profile card: top action icon (chat or edit),
/// name/title/location, description block, and contact infos.
/// Used by both [UserProfileScreen] (viewing a member) and
/// [MyProfileScreen] (viewing/editing your own profile).
class ProfileCardBody extends StatelessWidget {
  final AppUser user;
  final IconData topRightIcon;
  final VoidCallback? onTopRightTap;

  const ProfileCardBody({
    super.key,
    required this.user,
    required this.topRightIcon,
    required this.onTopRightTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top right icon (chat / edit) ──────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(topRightIcon, size: 22, color: AppColors.textDark),
                onPressed: onTopRightTap,
              ),
            ),
          ),

          // ── Name + title + location ────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(user.name, style: AppTextStyles.subheading),
                const SizedBox(height: 4),
                Text(
                  user.title,
                  style: AppTextStyles.date.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.location,
                      style: AppTextStyles.date.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ── Description ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Description',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(
                      Icons.work_outline_rounded,
                      size: 20,
                      color: AppColors.textDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(user.description, style: AppTextStyles.label),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ── Contact Infos ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.12,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Infos',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _ContactRow(
                  text: user.email,
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 12),
                _ContactRow(text: user.phone, icon: Icons.phone_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact row ───────────────────────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  final String text;
  final IconData icon;

  const _ContactRow({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(icon, size: 20, color: AppColors.textDark),
      ],
    );
  }
}
