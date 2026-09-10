import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
        surface: AppColors.background,
      ),
      textTheme: TextTheme(bodyMedium: AppTextStyles.interRegular14()),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.navbarBrown,
      ),
    );
  }
}
