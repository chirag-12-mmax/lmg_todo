import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Light Theme with Pink Accents
  static const Color primary = Color(0xFFEC4899); // Pink
  static const Color primaryLight = Color(0xFFF472B6); // Light Pink
  static const Color primaryDark = Color(0xFFDB2777); // Dark Pink

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Green
  static const Color secondaryLight = Color(0xFF34D399); // Light Green
  static const Color secondaryDark = Color(0xFF059669); // Dark Green

  // Background Colors
  static const Color background = Color(0xFFF8FAFC); // Light Gray Background
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBackground = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Dark Gray
  static const Color textSecondary = Color(0xFF64748B); // Medium Gray
  static const Color textTertiary = Color(0xFF94A3B8); // Light Gray
  static const Color textInverse = Color(0xFFFFFFFF); // White

  // Status Colors
  static const Color todo = Color(0xFFF59E0B); // Orange
  static const Color inProgress = Color(0xFF3B82F6); // Blue
  static const Color done = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Orange

  // Border Colors
  static const Color border = Color(0xFFE2E8F0); // Light Gray
  static const Color borderLight = Color(0xFFF1F5F9); // Very Light Gray

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Colors
  static const Color categoryPink = Color(0xFFEC4899); // Pink
  static const Color categoryOrange = Color(0xFFF97316); // Orange
  static const Color categoryBlue = Color(0xFF3B82F6); // Blue
  static const Color categoryPurple = Color(0xFF8B5CF6); // Purple

  // Status Color Map
  static Map<String, Color> statusColors = {
    'TODO': todo,
    'IN_PROGRESS': inProgress,
    'DONE': done,
  };

  // Get status color
  static Color getStatusColor(String status) {
    return statusColors[status] ?? textSecondary;
  }
}
