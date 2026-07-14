import 'package:flutter/material.dart';
import 'dart:io';
import '../state/app_state.dart';

class AppTheme {
  static bool get isDarkMode => AppState.darkModeNotifier.value;

  // Brand Colors
  static Color get primary => isDarkMode ? const Color(0xff5B4BFF) : const Color(0xff4F46E5);      // Deep Indigo / Premium MD3 Purple
  static Color get secondary => isDarkMode ? const Color(0xff7C6CFF) : const Color(0xff6D5DF6);    // Royal Violet
  static Color get accent => isDarkMode ? const Color(0xff7C6CFF) : const Color(0xff60A5FA);       // Sky Blue
  static Color get primaryPastel => isDarkMode ? const Color(0xff1E293B) : const Color(0xffEEF2F6);
  
  // Status Colors
  static Color get errorColor => const Color(0xffEF4444);    // Soft Red
  static Color get successColor => isDarkMode ? const Color(0xff22C55E) : const Color(0xff10B981);  // Green
  static Color get warningColor => const Color(0xffF59E0B);  // Amber

  // Backgrounds
  static Color get bgLight => isDarkMode ? const Color(0xff0F172A) : const Color(0xffF8FAFC);      // Very Light Gray
  static Color get bgSurface => isDarkMode ? const Color(0xff1E293B) : const Color(0xffF1F5F9);    // Soft light gray
  static Color get bgCard => isDarkMode ? const Color(0xff1E293B) : const Color(0xffFFFFFF);       // White
  
  // Neutral Text/Icons
  static Color get textDark => isDarkMode ? const Color(0xffFFFFFF) : const Color(0xff0F172A);     // Slate 900
  static Color get textMedium => isDarkMode ? const Color(0xffCBD5E1) : const Color(0xff475569);   // Slate 600
  static Color get textLight => isDarkMode ? const Color(0xffCBD5E1) : const Color(0xff64748B);    // Slate 500
  static Color get textMuted => isDarkMode ? const Color(0xff64748B) : const Color(0xff94A3B8);    // Slate 400
  
  // Border colors
  static Color get borderLight => isDarkMode ? const Color(0xff334155) : const Color(0xffE2E8F0);  // Slate 200
  static Color get borderMedium => isDarkMode ? const Color(0xff334155) : const Color(0xffCBD5E1); // Slate 300
  static Color get borderDark => isDarkMode ? const Color(0xff475569) : const Color(0xff94A3B8);   // Slate 400
  static Color get borderSubtle => isDarkMode ? const Color(0xff1E293B) : const Color(0xffF8FAFC); // Slate 50

  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get accentGradient => LinearGradient(
    colors: [secondary, isDarkMode ? const Color(0xff0F172A) : const Color(0xff312E81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get bgHeaderGradient => LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Premium Shadows
  static List<BoxShadow> get premiumShadow => [
        BoxShadow(
          color: (isDarkMode ? Colors.black : const Color(0xff0F172A)).withOpacity(isDarkMode ? 0.35 : 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: (isDarkMode ? Colors.black : const Color(0xff0F172A)).withOpacity(isDarkMode ? 0.20 : 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: (isDarkMode ? Colors.black : const Color(0xff0F172A)).withOpacity(isDarkMode ? 0.25 : 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
      
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: (isDarkMode ? Colors.black : const Color(0xff0F172A)).withOpacity(isDarkMode ? 0.20 : 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
      
  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: (isDarkMode ? Colors.black : const Color(0xff0F172A)).withOpacity(isDarkMode ? 0.30 : 0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
      
  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primary.withOpacity(isDarkMode ? 0.45 : 0.25),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  // Global Theme Settings
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: bgLight,
        error: errorColor,
      ),
      scaffoldBackgroundColor: bgLight,
      fontFamily: 'Inter',
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: errorColor, width: 2.0),
        ),
        labelStyle: TextStyle(
          color: textMedium,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: textMuted,
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderLight, width: 1.2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: bgLight,
        error: errorColor,
      ),
      scaffoldBackgroundColor: bgLight,
      fontFamily: 'Inter',
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: errorColor, width: 2.0),
        ),
        labelStyle: TextStyle(
          color: textMedium,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: textMuted,
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderLight, width: 1.2),
        ),
      ),
    );
  }

  // Dynamic Image Loading Utility
  static Widget buildProductImage(
    String imageUrl, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: bgSurface,
            width: width,
            height: height,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: bgSurface,
          width: width,
          height: height,
          child: Icon(Icons.menu_book_rounded, color: textLight),
        ),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          color: bgSurface,
          width: width,
          height: height,
          child: Icon(Icons.menu_book_rounded, color: textLight),
        ),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          color: bgSurface,
          width: width,
          height: height,
          child: Icon(Icons.menu_book_rounded, color: textLight),
        ),
      );
    }
  }

  static ImageProvider buildProductImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else {
      return FileImage(File(imageUrl));
    }
  }
}
