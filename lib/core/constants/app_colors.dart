import 'package:flutter/material.dart';

/// Couleurs de l'application EVAL360
class AppColors {
  AppColors._(); // Private constructor pour empêcher l'instanciation

  // Primary Colors
  static const Color primary = Color(0xFF2563EB); // Bleu professionnel
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Vert
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF34D399);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors (Light Mode)
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF374151);

  // Sidebar Colors
  static const Color sidebarBg = Color(0xFF1F2937);
  static const Color sidebarActive = Color(0xFF3B82F6);
  static const Color sidebarHover = Color(0xFF374151);
  static const Color sidebarText = Color(0xFFD1D5DB);
  static const Color sidebarTextActive = Colors.white;

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF3B82F6), // Bleu
    Color(0xFF10B981), // Vert
    Color(0xFFF59E0B), // Orange
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Rose
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange foncé
    Color(0xFF14B8A6), // Teal
  ];

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
