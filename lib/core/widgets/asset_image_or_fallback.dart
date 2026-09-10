import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AssetImageOrFallback extends StatelessWidget {
  final String? assetPath;
  final String assetFolder;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AssetImageOrFallback({
    super.key,
    required this.assetPath,
    required this.assetFolder,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    final content = path == null
        ? _fallback()
        : ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: Image.asset(
              'assets/$assetFolder/$path',
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _fallback(),
            ),
          );

    return SizedBox(width: width, height: height, child: content);
  }

  Widget _fallback() {
    // Below this size "Image not available" can't fit — show a generic icon instead.
    final tooSmallForText = width < 32 || height < 32;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pillInactive,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: tooSmallForText
          ? Icon(
              Icons.image_not_supported,
              color: AppColors.grayMuted,
              size: width * 0.6,
            )
          : Text(
              'Image not available',
              textAlign: TextAlign.center,
              style: AppTextStyles.interRegular14(
                color: AppColors.grayMuted,
              ).copyWith(fontSize: 9),
            ),
    );
  }
}
