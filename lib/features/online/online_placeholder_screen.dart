import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OnlinePlaceholderScreen extends StatelessWidget {
  const OnlinePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Coming soon',
        style: AppTextStyles.bangers20(color: AppColors.white),
      ),
    );
  }
}
