import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/asset_image_or_fallback.dart';
import '../../../data/models/track.dart';
import '../../../core/i18n/i18n.dart';

class TrackHeader extends StatelessWidget {
  final Track track;

  const TrackHeader({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AssetImageOrFallback(
          assetPath: track.trackImg,
          assetFolder: 'tracks',
          width: 70,
          height: 70,
          borderRadius: BorderRadius.circular(8),
        ),
        SizedBox(width: MediaQuery.sizeOf(context).width * 0.1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.name.toUpperCase(),
                style: AppTextStyles.bangers(
                  fontSize: 20,
                  color: AppColors.grayLight,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AssetImageOrFallback(
                    assetPath: track.cupImg,
                    assetFolder: 'cups',
                    width: 20,
                    height: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    (track.cup ?? t('common.not_available')).toUpperCase(),
                    style: AppTextStyles.bangers(
                      fontSize: 16,
                      color: AppColors.grayMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
