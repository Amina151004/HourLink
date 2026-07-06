import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/services/auth_service.dart';
import 'package:hourlink/features/auth/presentation/pages/edit_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/help_center_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/privacy_policy_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/about_screen.dart';
import 'package:hourlink/core/utils/calendar_launcher.dart';

class SettingsScreen extends StatelessWidget {
  final AppUser user;

  const SettingsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: AppColors.textDark,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Settings', style: AppTextStyles.subheading),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Sections ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Account'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(user: user),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Google Calendar',
                        onTap: () => openGoogleCalendar(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  _SectionLabel('Preferences'),
                  _SettingsGroup(
                    children: [
                      _SettingsToggleTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifications',
                        value: true,
                        onChanged: (_) {},
                      ),
                      // ── Dark Mode toggle, wired to isDarkModeNotifier ──
                      ValueListenableBuilder<bool>(
                        valueListenable: isDarkModeNotifier,
                        builder: (context, isDark, _) {
                          return _SettingsToggleTile(
                            icon: Icons.dark_mode_outlined,
                            label: 'Dark Mode',
                            value: isDark,
                            onChanged: (value) => AppTheme.setDark(value),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  _SectionLabel('Support'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpCenterScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About HourLink',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Logout ────────────────────────────────────────────
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        label: 'Log Out',
                        labelColor: Colors.redAccent,
                        iconColor: Colors.redAccent,
                        onTap: () {
                          authService.signOut();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 4),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}

// ── Settings group container ────────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textDark, width: 0.8),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, color: AppColors.divider, indent: 56),
          ],
        ],
      ),
    );
  }
}

// ── Simple settings tile ────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? AppColors.textDark),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: labelColor ?? AppColors.textDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toggle settings tile ────────────────────────────────────────────────────
class _SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textDark),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.textDark,
          ),
        ],
      ),
    );
  }
}
