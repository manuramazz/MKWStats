import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Bangers — titles, nav labels, buttons, pills.
  static TextStyle bangers({
    double fontSize = 16,
    Color color = AppColors.white,
  }) {
    return GoogleFonts.bangers(fontSize: fontSize, color: color);
  }

  static TextStyle bangers15({Color color = AppColors.white}) =>
      bangers(fontSize: 15, color: color);

  static TextStyle bangers16({Color color = AppColors.white}) =>
      bangers(fontSize: 16, color: color);

  static TextStyle bangers18({Color color = AppColors.white}) =>
      bangers(fontSize: 18, color: color);

  static TextStyle bangers20({Color color = AppColors.white}) =>
      bangers(fontSize: 20, color: color);

  // Inter — form labels, inputs, table content, modal text.
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.white,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle interRegular14({Color color = AppColors.white}) =>
      inter(fontSize: 14, fontWeight: FontWeight.w400, color: color);

  static TextStyle interMedium14({Color color = AppColors.white}) =>
      inter(fontSize: 14, fontWeight: FontWeight.w500, color: color);

  static TextStyle interMedium16({Color color = AppColors.white}) =>
      inter(fontSize: 16, fontWeight: FontWeight.w500, color: color);

  static TextStyle interBold18({Color color = AppColors.white}) =>
      inter(fontSize: 18, fontWeight: FontWeight.w700, color: color);

  static TextStyle interSemiBold12({Color color = AppColors.white}) =>
      inter(fontSize: 12, fontWeight: FontWeight.w600, color: color);
}
