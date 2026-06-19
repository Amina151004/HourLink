import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

/// Shared shell for profile screens: back button + top-right action icon
/// in the header zone, overlapping avatar, and the white rounded card
/// containing [body]. Used by both [UserProfileScreen] and [MyProfileScreen].
class ProfileScreenShell extends StatelessWidget {
  final IconData headerRightIcon;
  final VoidCallback onHeaderRightTap;
  final Widget body;

  const ProfileScreenShell({
    super.key,
    required this.headerRightIcon,
    required this.onHeaderRightTap,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Background zone ──────────────────────────────────────
              Container(
                color: AppColors.background,
                height: 220,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: Icon(headerRightIcon, size: 24),
                            onPressed: onHeaderRightTap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── White card ────────────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border.all(color: AppColors.textDark, width: 0.5),
                  ),
                  child: body,
                ),
              ),
            ],
          ),

          // ── Avatar overlapping ─────────────────────────────────────────
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.avatarPlaceholder,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
