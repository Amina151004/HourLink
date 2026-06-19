import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE8713A); // orange
  static const Color background = Color(0xFFFFF8F2); // warm cream
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color.fromARGB(255, 107, 107, 107);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color blue = Color(0xFF6BA3D6); // meeting badge
  static const Color avatarPlaceholder = Color(0xFFD0D0D0);
  static const Color inputBg = Color(0xFFF5F5F5);
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
    color: const Color.fromARGB(255, 0, 0, 0),
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
