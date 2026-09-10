import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_format.dart';

class TrackStatsRow extends StatelessWidget {
  final int? personalBestMs;
  final int? wrTimeMs;

  const TrackStatsRow({
    super.key,
    required this.personalBestMs,
    required this.wrTimeMs,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatBox(
              label: 'Personal Best',
              child: Text(
                personalBestMs == null
                    ? 'No time set'
                    : formatTimeMs(personalBestMs!),
                style: AppTextStyles.interRegular14(color: AppColors.grayLight),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBox(
              label: 'WR',
              child: Text(
                wrTimeMs == null ? 'No disponible' : formatTimeMs(wrTimeMs!),
                style: AppTextStyles.interRegular14(color: AppColors.grayLight),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBox(label: 'Gap', child: _buildGap()),
          ),
        ],
      ),
    );
  }

  Widget _buildGap() {
    if (personalBestMs == null || wrTimeMs == null) {
      return Text(
        '—',
        style: AppTextStyles.interRegular14(color: AppColors.grayLight),
      );
    }
    final gapMs = personalBestMs! - wrTimeMs!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatGapSeconds(gapMs),
          style: AppTextStyles.interRegular14(color: AppColors.grayLight),
        ),
        Text(
          formatGapPercent(gapMs, wrTimeMs!),
          style: AppTextStyles.interRegular14(color: AppColors.grayLight),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatBox({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.statBoxBrown,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.grayLight,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
