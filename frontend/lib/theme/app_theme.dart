import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tactical color tokens. Amber = action/alert, Teal = online/normal,
/// Red = critical, Blue = info.
class AppColors {
  final Color bg, bgElev, surface, surface2, border, borderSoft;
  final Color text, textDim, textFaint;
  final Color amber, teal, red, blue;

  const AppColors({
    required this.bg,
    required this.bgElev,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.borderSoft,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.amber,
    required this.teal,
    required this.red,
    required this.blue,
  });

  static const dark = AppColors(
    bg: Color(0xFF080B10),
    bgElev: Color(0xFF0D1219),
    surface: Color(0xFF11161F),
    surface2: Color(0xFF161D28),
    border: Color(0xFF232D3B),
    borderSoft: Color(0xFF1A222E),
    text: Color(0xFFE9EEF3),
    textDim: Color(0xFF8A96A6),
    textFaint: Color(0xFF576273),
    amber: Color(0xFFE5A83D),
    teal: Color(0xFF2FD9A8),
    red: Color(0xFFE85B4F),
    blue: Color(0xFF4C8DE8),
  );

  static const light = AppColors(
    bg: Color(0xFFEEF1F5),
    bgElev: Color(0xFFF6F8FA),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF2F5F8),
    border: Color(0xFFDCE2E9),
    borderSoft: Color(0xFFE6EAEF),
    text: Color(0xFF131A22),
    textDim: Color(0xFF5B6673),
    textFaint: Color(0xFF8A94A0),
    amber: Color(0xFFB87E1E),
    teal: Color(0xFF128F6D),
    red: Color(0xFFC6392F),
    blue: Color(0xFF2E6FCB),
  );
}

/// Font roles — headings use Sora (geometric, technical), data/labels use
/// JetBrains Mono (HUD/telemetry feel), body copy uses Inter.
class AppFonts {
  static TextStyle display(BuildContext c, {double size = 16, FontWeight w = FontWeight.w600, Color? color}) =>
      GoogleFonts.sora(fontSize: size, fontWeight: w, color: color, letterSpacing: 0.2);

  static TextStyle mono(BuildContext c, {double size = 11, FontWeight w = FontWeight.w500, Color? color, double? spacing}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: w, color: color, letterSpacing: spacing ?? 0.6);

  static TextStyle body(BuildContext c, {double size = 13.5, FontWeight w = FontWeight.w400, Color? color}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: color);
}

ThemeData buildAppTheme(AppColors c, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: c.bg,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.amber,
      onPrimary: const Color(0xFF14100A),
      secondary: c.teal,
      onSecondary: const Color(0xFF06110E),
      error: c.red,
      onError: Colors.white,
      surface: c.surface,
      onSurface: c.text,
    ),
    cardColor: c.surface,
    dividerColor: c.border,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.bgElev,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: c.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: c.teal, width: 1.4),
      ),
      hintStyle: TextStyle(color: c.textFaint),
    ),
  );
}
