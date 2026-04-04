import 'package:flutter/material.dart';

class AppTheme {
  // Color schemes for different sections
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryTeal = Color(0xFF009688);
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color primaryIndigo = Color(0xFF3F51B5);

  // Gradient colors for each section
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFCC80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoGradient = LinearGradient(
    colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Section-specific themes
  static ThemeData getThemeForSection(String section) {
    Color primaryColor;

    switch (section) {
      case 'home':
        primaryColor = primaryBlue;
        break;
      case 'assessment':
        primaryColor = primaryPink;
        break;
      case 'translation':
        primaryColor = primaryPurple;
        break;
      case 'ai_tutor':
        primaryColor = primaryGreen;
        break;
      case 'learning':
        primaryColor = primaryOrange;
        break;
      case 'classes':
        primaryColor = primaryCyan;
        break;
      case 'profile':
        primaryColor = primaryTeal;
        break;
      default:
        primaryColor = primaryBlue;
    }

    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Card decoration with gradient
  static BoxDecoration cardDecoration(LinearGradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: gradient.colors[0].withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  // Soft card decoration (white with subtle shadow)
  static BoxDecoration softCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  // Icon container decoration
  static BoxDecoration iconContainerDecoration(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
