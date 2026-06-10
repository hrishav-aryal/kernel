import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme colors
  static const Color primaryColor = Color(0xFF2e3338);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color.fromARGB(255, 0, 0, 0);
  static const Color textSecondaryColor = Color.fromARGB(255, 166, 172, 182);

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFFE4E2DD);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF141414);
  static const Color darkTextPrimaryColor = Color.fromARGB(255, 213, 216, 219);
  static const Color darkTextSecondaryColor = Color(0xFF9CA3AF);

  // Typography constants
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 20.0;
  static const double fontSize3XL = 24.0;
  static const double fontSize4XL = 28.0;

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.5;

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: const Color.fromARGB(255, 119, 120, 231),
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        error: const Color(0xFFEF5350),
        onError: Colors.white,
        outline: Colors.grey[300],
        surfaceVariant: Colors.grey[300],
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      shadowColor: Colors.black.withOpacity(
        0.05,
      ), // Global shadow color for light mode
      // Typography with Source Sans Pro font (better weight distribution)
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          // Headline styles for section titles
          headlineLarge: TextStyle(
            fontSize: fontSizeXL,
            fontWeight: FontWeight.bold,
            height: lineHeightTight,
            color: textPrimaryColor,
          ),
          headlineMedium: TextStyle(
            fontSize: fontSizeLG,
            fontWeight: FontWeight.w800,
            height: lineHeightTight,
            color: Colors.black,
            letterSpacing: 0,
          ),
          headlineSmall: TextStyle(
            fontSize: fontSizeBase,
            fontWeight: FontWeight.w600,
            height: lineHeightTight,
            color: textPrimaryColor,
          ),

          // Title styles for card titles
          titleLarge: TextStyle(
            fontSize: fontSizeLG,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: textPrimaryColor,
          ),
          titleMedium: TextStyle(
            fontSize: fontSizeBase,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: textPrimaryColor,
          ),
          titleSmall: TextStyle(
            fontSize: fontSizeSM,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: textPrimaryColor,
          ),

          // Body styles for content
          bodyLarge: TextStyle(
            fontSize: fontSizeLG,
            fontWeight: FontWeight.normal,
            height: lineHeightRelaxed,
            color: textPrimaryColor,
          ),
          bodyMedium: TextStyle(
            fontSize: fontSizeBase + 2,
            fontWeight: FontWeight.w500,
            height: lineHeightRelaxed,
            color: textPrimaryColor,
            letterSpacing: 0.1,
          ),
          bodySmall: TextStyle(
            fontSize: fontSizeSM,
            fontWeight: FontWeight.normal,
            height: lineHeightNormal,
            color: textSecondaryColor,
          ),

          // Label styles for UI elements
          labelLarge: TextStyle(
            fontSize: fontSizeSM,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: textPrimaryColor,
          ),
          labelMedium: TextStyle(
            fontSize: fontSizeXS,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: textPrimaryColor,
          ),
          labelSmall: TextStyle(
            fontSize: fontSizeXS,
            fontWeight: FontWeight.w500,
            height: lineHeightNormal,
            color: textSecondaryColor,
          ),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 0, // Hide default toolbar globally
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: surfaceColor, // White status bar
          statusBarIconBrightness: Brightness.dark, // Dark icons
          statusBarBrightness: Brightness.light, // For iOS
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // Additional theme properties for better color access
      dividerTheme: DividerThemeData(
        color: textSecondaryColor.withOpacity(0.2),
        thickness: 1,
      ),

      iconTheme: IconThemeData(color: textPrimaryColor, size: 24),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: const Color.fromARGB(255, 189, 187, 183),
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: darkTextPrimaryColor,
        onBackground: darkTextPrimaryColor,
        error: const Color(0xFFEF5350),
        onError: Colors.black,
        outline: Colors.grey[700],
        surfaceVariant: Colors.grey[800],
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackgroundColor,
      shadowColor: Colors.black.withOpacity(
        0.3,
      ), // Global shadow color for dark mode
      // Typography with Source Sans Pro font (better weight distribution)
      textTheme: GoogleFonts.nunitoSansTextTheme(
        const TextTheme(
          // Headline styles for section titles
          headlineLarge: TextStyle(
            fontSize: fontSizeXL,
            fontWeight: FontWeight.bold,
            height: lineHeightTight,
            color: darkTextPrimaryColor,
          ),
          headlineMedium: TextStyle(
            fontSize: fontSizeLG,
            fontWeight: FontWeight.w800,
            height: lineHeightTight,
            color: darkTextPrimaryColor,
          ),
          headlineSmall: TextStyle(
            fontSize: fontSizeBase,
            fontWeight: FontWeight.w600,
            height: lineHeightTight,
            color: darkTextPrimaryColor,
          ),

          // Title styles for card titles
          titleLarge: TextStyle(
            fontSize: fontSizeLG,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: darkTextPrimaryColor,
          ),
          titleMedium: TextStyle(
            fontSize: fontSizeBase,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: darkTextPrimaryColor,
          ),
          titleSmall: TextStyle(
            fontSize: fontSizeSM,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: darkTextPrimaryColor,
          ),

          // Body styles for content
          bodyLarge: TextStyle(
            fontSize: fontSizeLG,
            fontWeight: FontWeight.normal,
            height: lineHeightRelaxed,
            color: darkTextPrimaryColor,
          ),
          bodyMedium: TextStyle(
            fontSize: fontSizeBase + 2,
            fontWeight: FontWeight.w500,
            height: lineHeightNormal,
            color: darkTextPrimaryColor,
          ),
          bodySmall: TextStyle(
            fontSize: fontSizeSM,
            fontWeight: FontWeight.normal,
            height: lineHeightNormal,
            color: darkTextSecondaryColor,
          ),

          // Label styles for UI elements
          labelLarge: TextStyle(
            fontSize: fontSizeSM,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: darkTextPrimaryColor,
          ),
          labelMedium: TextStyle(
            fontSize: fontSizeXS,
            fontWeight: FontWeight.w600,
            height: lineHeightNormal,
            color: darkTextPrimaryColor,
          ),
          labelSmall: TextStyle(
            fontSize: fontSizeXS,
            fontWeight: FontWeight.w500,
            height: lineHeightNormal,
            color: darkTextSecondaryColor,
          ),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceColor,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 0, // Hide default toolbar globally
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: darkSurfaceColor, // Dark status bar
          statusBarIconBrightness: Brightness.light, // Light icons
          statusBarBrightness: Brightness.dark, // For iOS
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // Additional theme properties for better color access
      dividerTheme: DividerThemeData(
        color: darkTextSecondaryColor.withOpacity(0.2),
        thickness: 1,
      ),

      iconTheme: IconThemeData(color: darkTextPrimaryColor, size: 24),
    );
  }
}
