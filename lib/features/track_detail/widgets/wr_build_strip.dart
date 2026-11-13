import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/i18n.dart';

class WrBuildStrip extends StatelessWidget {
  final String? character;
  final String? kart;

  const WrBuildStrip({super.key, required this.character, required this.kart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryBrown,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Text(
            t('track_detail.wr_build'),
            style: AppTextStyles.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.grayMuted,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.person, color: AppColors.grayLighter, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              character ?? t('common.not_available'),
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.interRegular14(
                color: AppColors.grayLighter,
              ).copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.directions_car,
            color: AppColors.grayLighter,
            size: 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              kart ?? t('common.not_available'),
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.interRegular14(
                color: AppColors.grayLighter,
              ).copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
