import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

class ProfileScreenShell extends StatelessWidget {
  final IconData headerRightIcon;
  final VoidCallback onHeaderRightTap;
  final Widget body;
  final String? avatarUrl; // ← ajouté
  final String? avatarName; // ← ajouté pour l'initiale en fallback

  const ProfileScreenShell({
    super.key,
    required this.headerRightIcon,
    required this.onHeaderRightTap,
    required this.body,
    this.avatarUrl,
    this.avatarName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final initiale = (avatarName?.isNotEmpty == true)
        ? avatarName![0].toUpperCase()
        : '?';

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
                            icon: Icon(
                              Icons.chevron_left,
                              color: AppColors.textDark,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: Icon(
                              headerRightIcon,
                              color: AppColors.textDark,
                              size: 24,
                            ),
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
            top: 147,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: screenWidth * 0.34,
                height: screenWidth * 0.34,
                decoration: BoxDecoration(
                  color: AppColors.avatarPlaceholder,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 4),
                  image: (avatarUrl?.isNotEmpty == true)
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (avatarUrl?.isEmpty ?? true)
                    ? Center(
                        child: Text(
                          initiale,
                          style: AppTextStyles.subheading.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
