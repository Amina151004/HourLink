import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                Text('About HourLink', style: AppTextStyles.subheading),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
              ).copyWith(top: 20, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App icon + name ─────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(0, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image(
                            image: const AssetImage(
                              'assets/images/favicon.png',
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('HourLink', style: AppTextStyles.heading),
                        const SizedBox(height: 4),
                        FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            final version = snapshot.hasData
                                ? 'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                                : 'Version —';
                            return Text(version, style: AppTextStyles.caption);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'HourLink helps teams coordinate meetings effortlessly. '
                    'Connect your team, sync your Google Calendar, and let '
                    'smart scheduling find the perfect time for everyone — '
                    'no more back-and-forth.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _AboutGroup(
                    children: [
                      _AboutTile(
                        icon: Icons.star_border_rounded,
                        label: 'Rate HourLink',
                        onTap: () {},
                      ),
                      _AboutTile(
                        icon: Icons.share_outlined,
                        label: 'Share with a friend',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: Text(
                      '© 2026 HourLink. All rights reserved.',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutGroup extends StatelessWidget {
  final List<Widget> children;

  const _AboutGroup({required this.children});

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

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textDark),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(color: AppColors.textDark),
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
