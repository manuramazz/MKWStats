import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/asset_image_or_fallback.dart';
import '../../../data/models/track.dart';

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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                track.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bangers(
                  fontSize: 20,
                  color: AppColors.grayLight,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    (track.cup ?? 'No disponible').toUpperCase(),
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
