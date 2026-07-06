import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global notifier — wrap MaterialApp in a ValueListenableBuilder that
/// listens to this so the whole tree rebuilds when the mode flips.
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

class AppTheme {
  AppTheme._();

  static const _prefsKey = 'isDarkMode';

  /// Call once in main() before runApp() to restore the saved preference.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = prefs.getBool(_prefsKey) ?? false;
  }

  /// Call this from the Settings "Dark Mode" switch.
  static Future<void> setDark(bool value) async {
    isDarkModeNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  static bool get isDark => isDarkModeNotifier.value;
}

// ── Colors ────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static bool get _dark => isDarkModeNotifier.value;

  static Color get primary =>
      const Color(0xFFE8713A); // orange — same in both modes

  static Color get background =>
      _dark ? const Color(0xFF121212) : const Color(0xFFFFF8F2);

  static Color get white =>
      _dark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);

  static Color get textDark =>
      _dark ? const Color(0xFFF2F2F2) : const Color(0xFF1A1A1A);

  static Color get textGrey => _dark
      ? const Color(0xFFA0A0A0)
      : const Color.fromARGB(255, 107, 107, 107);

  static Color get divider =>
      _dark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

  static Color get blue => const Color(0xFF6BA3D6); // meeting badge

  static Color get avatarPlaceholder =>
      _dark ? const Color(0xFF3A3A3A) : const Color(0xFFD0D0D0);

  static Color get inputBg =>
      _dark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

  static Color get avatarPast => _dark
      ? const Color(0xFF3D3220)
      : const Color.fromARGB(255, 255, 242, 215);
}

// ── Text Styles ───────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading => GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle get subheading => GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle get body => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle get bodyBold => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle get caption => GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textGrey,
  );

  static TextStyle get button => GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color:
        AppColors.textDark, // was hardcoded black — now flips in dark mode too
  );

  static TextStyle get label => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle get date => GoogleFonts.nunito(
    fontSize: 9,
    fontWeight: FontWeight.w800,
    color: AppColors.textGrey,
  );

  static TextStyle get greyheading => GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );
}
