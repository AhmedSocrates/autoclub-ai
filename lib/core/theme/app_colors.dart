import 'package:flutter/material.dart';

class AppColors {
  // --- Core Palette ---
  static const Color primary = Colors.black; // Black is the primary brand color
  static const Color secondary = Colors.white; // White is the secondary/background color

  // --- Backgrounds & Surfaces ---
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5); // Light grey surface (cards, containers)
  static const Color surfaceLight = Color(0xFFEEEEEE); // Slightly darker light surface

  // --- Borders ---
  static const Color border = Color(0xFFDDDDDD); // Subtle light grey border
  static const Color borderDark = Color(0xFF333333); // Dark border for emphasis

  // --- Text ---
  static const Color textPrimary = Colors.black; // Main body text
  static const Color textSecondary = Color(0xFF555555); // Muted/secondary text
  static const Color textDisabled = Color(0xFFAAAAAA); // Disabled / placeholder text
  static const Color textOnDark = Colors.white; // Text on dark/black backgrounds
  static const Color textBody = Colors.black; // Alias for body text

  // --- Accents ---
  static const Color accentGold = Color(0xFFFFCC57);
  static const Color accentOrange = Color(0xFFFF7A50);

  // --- Utilities ---
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
}
