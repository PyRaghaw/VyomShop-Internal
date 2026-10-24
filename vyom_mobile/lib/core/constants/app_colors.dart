import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Brand Colors (Vyom Palette)
  static const Color background = Color(0xFFF8F8F7);
  static const Color foreground = Color(0xFF101010);
  static const Color card = Colors.white;
  static const Color primary = Color(0xFFFF641C); // Tangerine signature
  static const Color primaryLight = Color(0xFFFFF0E6);
  static const Color brandYellow = Color(0xFFFFD400); // Signature Figma Golden Yellow
  static const Color brandYellowLight = Color(0xFFFFD829); // Figma diagonal stripe yellow #FFD829
  static const Color accent = Color(0xFFFFD600); // Electric lime/yellow
  static const Color muted = Color(0xFFF0EFEB);
  static const Color mutedText = Color(0xFF6B6B65);
  static const Color border = Color(0xFF101010); // Neo-brutalist border
  static const Color borderSubtle = Color(0xFFEAEAEA);

  // Soft Tint Card Backgrounds (from Figma prototype)
  static const Color tintCream = Color(0xFFEEEAE5);
  static const Color tintSage = Color(0xFFE8E9E5);
  static const Color tintSand = Color(0xFFEAE5DC);
  static const Color tintGreen = Color(0xFFEDF4E9);
  static const Color tagGreenText = Color(0xFF376035);

  // Status & Alerts
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // Convenient Aliases
  static const Color mutedForeground = mutedText;
  static const Color softGreen = tintGreen;
  static const Color softYellow = Color(0xFFFFFBEA);
  static const Color softPink = Color(0xFFFFECEB);
}
