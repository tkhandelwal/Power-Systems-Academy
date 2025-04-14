// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Primary color options (more accessible and contrasting)
  static const Color primaryIndigo = Color(0xFF3949AB); // Slightly darker
  static const Color primaryBlue = Color(0xFF1E88E5); // Material Blue 600
  static const Color primaryTeal = Color(0xFF009688); // Material Teal
  static const Color primaryGreen = Color(0xFF43A047); // Material Green 600
  static const Color primaryPurple = Color(0xFF5E35B1); // Material Deep Purple 600
  
  // Accent color options (more vibrant and accessible)
  static const Color accentAmber = Color(0xFFFFC107); // Material Amber
  static const Color accentOrange = Color(0xFFFF9800); // Material Orange
  static const Color accentPink = Color(0xFFE91E63); // Material Pink
  static const Color accentCyan = Color(0xFF00BCD4); // Material Cyan

  // Create a common theme configuration method to reduce code duplication
  static ThemeData _baseTheme({
    required Brightness brightness,
    Color primaryColor = primaryIndigo, 
    Color secondaryColor = accentAmber,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final Color scaffoldBackground = isDark ? Color(0xFF121212) : Colors.grey[50]!;
    final Color cardBackground = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subtextColor = isDark ? Colors.white70 : Colors.grey[600]!;

    return ThemeData(
      brightness: brightness,
      
      // Base colors
      primaryColor: primaryColor,
      primarySwatch: _createMaterialColor(primaryColor),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      
      // Scaffold and background colors
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: cardBackground,
      
      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: isDark ? Color(0xFF1E1E1E) : primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Color(0xFF262626) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Tab bar theme
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: secondaryColor,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
        disabledColor: isDark ? Colors.grey[700] : Colors.grey[300],
        selectedColor: primaryColor.withOpacity(0.2),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Text themes
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: subtextColor,
        ),
      ),
    );
  }

  // Light theme method
  static ThemeData lightTheme({
    Color primaryColor = primaryIndigo, 
    Color secondaryColor = accentAmber,
  }) {
    return _baseTheme(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }
  
  // Dark theme method
  static ThemeData darkTheme({
    Color primaryColor = primaryIndigo, 
    Color secondaryColor = accentAmber,
  }) {
    return _baseTheme(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }
  
  // Helper function to create MaterialColor from a Color
  static MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = <int, Color>{};
    
    final int r = color.red;
    final int g = color.green;
    final int b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        (r + ((ds < 0 ? r : (255 - r)) * ds).round()).clamp(0, 255),
        (g + ((ds < 0 ? g : (255 - g)) * ds).round()).clamp(0, 255),
        (b + ((ds < 0 ? b : (255 - b)) * ds).round()).clamp(0, 255),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
}