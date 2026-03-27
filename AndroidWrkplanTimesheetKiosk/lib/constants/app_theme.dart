import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkNavy,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.teal,
      onPrimary: AppColors.white,
      secondary: AppColors.teal,
      onSecondary: AppColors.white,
      error: Color(0xFFCF6679),
      onError: AppColors.white,
      surface: AppColors.darkNavy,
      onSurface: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkNavy,
      foregroundColor: AppColors.white,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: AppColors.cardStroke, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.teal),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.dialogHeader,
      contentTextStyle: TextStyle(color: AppColors.white),
    ),
  );
}
