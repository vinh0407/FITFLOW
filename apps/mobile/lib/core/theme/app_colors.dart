import 'package:flutter/material.dart';

abstract final class AppColors {
  // FITFLOW palette: black, white, neutral grays, and a deep blue accent.
  static const Color ink = Color(0xFF151515);
  static const Color paper = Color(0xFFE9E9E7);
  static const Color gray900 = Color(0xFF1D1D1D);
  static const Color gray800 = Color(0xFF292929);
  static const Color gray700 = Color(0xFF3F3F3F);
  static const Color gray600 = Color(0xFF727272);
  static const Color gray500 = Color(0xFFAAAAAA);
  static const Color gray300 = Color(0xFFC9C9C7);
  static const Color gray100 = Color(0xFFF1F1EF);

  // Canonical names for the current black-white-blue visual system.
  static const Color primaryBlue = Color(0xFF183B63);
  static const Color primaryBlueDark = Color(0xFF0B223D);
  static const Color primaryBlueLight = Color(0xFF4E78A5);
  static const Color primaryBlueGlow = Color(0x29183B63);
  static const Color statusWarning = primaryBlueLight;
  static const Color statusRecovery = Color(0xFF6F9CC7);

  // Accent gradients for the few elevated FITFLOW surfaces that need
  // a stronger visual hierarchy. Core screens continue to use flat surfaces.
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF557FA8), primaryBlue],
  );
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gray800, gray900],
  );

  // AI uses the same blue-black system, with a slightly lighter blue surface.
  static const Color aiPurple = Color(0xFF245A91);
  static const Color aiPurpleLight = Color(0xFF9DBDDB);
  static const Color aiPurpleDark = Color(0xFF0B223D);
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [aiPurple, aiPurpleDark],
  );

  // Semantic tones stay within the black-white-blue system.
  static const Color mintGreen = gray700;
  static const Color mintGreenDark = gray300;
  static const Color amberYellow = gray600;
  static const Color skyBlue = gray600;

  // Light Mode Tokens (Master Prompt Spec)
  static const Color lightBg = paper;
  static const Color lightSurface = white;
  static const Color lightElevatedSurface = white;
  static const Color lightSurfaceMid = gray100;
  static const Color lightCardHero = ink;
  static const Color lightBorder = gray300;
  static const Color lightTextPrimary = ink;
  static const Color lightTextSecondary = Color(0xFF626262);
  static const Color lightTextMuted = lightTextSecondary;

  // Dark Mode Tokens (Master Prompt Spec)
  static const Color darkBg = ink;
  static const Color darkSurface = gray900;
  static const Color darkElevatedSurface = gray800;
  static const Color darkSurfaceMid = gray800;
  static const Color darkBorder = gray700;
  static const Color darkTextPrimary = white;
  static const Color darkTextSecondary = gray300;
  static const Color darkTextMuted = gray500;

  // Base & Semantic Tokens
  static const Color black = ink;
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = darkBg;
  static const Color surface = darkSurface;
  static const Color surfaceMid = darkSurfaceMid;
  static const Color surfaceLight = darkBorder;
  static const Color surfaceHighest = gray700;

  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;
  static const Color textDisabled = gray600;

  static const Color border = darkBorder;
  static const Color borderLight = gray700;
  static const Color borderStrong = gray500;
  static const Color borderBlue = Color(0x66183B63);

  static const Color success = mintGreen;
  static const Color warning = amberYellow;
  static const Color error = primaryBlue;
  static const Color info = gray600;
  static const Color smm = gray600;

  // Recovery status colors
  static const Color recoveryHigh = gray300;
  static const Color recoveryMid = gray500;
  static const Color recoveryLow = primaryBlue;
}
