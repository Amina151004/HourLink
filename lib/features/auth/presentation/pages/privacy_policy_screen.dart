import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<_PolicySection> _sections = [
    _PolicySection(
      title: 'Information We Collect',
      body:
          'HourLink collects your name, email, and profile photo through '
          'Google Sign-In, along with team, meeting, and message data you '
          'create while using the app.',
    ),
    _PolicySection(
      title: 'Calendar Access',
      body:
          'With your permission, HourLink reads your Google Calendar '
          'free/busy information to suggest meeting times. We never read '
          'event titles or details — only whether a time slot is free or '
          'busy.',
    ),
    _PolicySection(
      title: 'How We Use Your Data',
      body:
          'Your data is used to run core features: team coordination, '
          'meeting scheduling, and in-app messaging. We do not sell your '
          'data or share it with third parties for advertising.',
    ),
    _PolicySection(
      title: 'Data Storage',
      body:
          'Your data is stored securely in Firebase (Firestore) under '
          'Google Cloud\'s infrastructure, with access restricted to your '
          'account and the teams you belong to.',
    ),
    _PolicySection(
      title: 'Messaging',
      body:
          'Direct messages are visible only to the participants of a '
          'conversation and are stored to let you view your chat history '
          'across devices.',
    ),
    _PolicySection(
      title: 'Your Choices',
      body:
          'You can edit or delete your profile information at any time '
          'from Settings, and revoke Google Calendar access from your '
          'Google Account permissions.',
    ),
    _PolicySection(
      title: 'Contact Us',
      body:
          'If you have questions about this policy or your data, reach out '
          'through the Help Center.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                Text('Privacy Policy', style: AppTextStyles.subheading),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Text(
              'Last updated: July 2026',
              style: AppTextStyles.caption,
            ),
          ),

          const SizedBox(height: 16),

          // ── Sections ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ).copyWith(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final section in _sections) ...[
                    Text(section.title, style: AppTextStyles.bodyBold),
                    const SizedBox(height: 6),
                    Text(
                      section.body,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});
}
