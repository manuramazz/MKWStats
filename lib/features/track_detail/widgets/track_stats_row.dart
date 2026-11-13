import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/i18n/i18n.dart';

class TrackStatsRow extends StatelessWidget {
  final int? personalBestMs;
  final int? wrTimeMs;
  final String? wrPlayerName;

  const TrackStatsRow({
    super.key,
    required this.personalBestMs,
    required this.wrTimeMs,
    required this.wrPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatBox(
              label: t('track_detail.personal_best'),
              child: Text(
                personalBestMs == null
                    ? t('common.no_time_set')
                    : formatTimeMs(personalBestMs!),
                style: AppTextStyles.interRegular14(color: AppColors.grayLight),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBox(
              label: t('track_detail.wr'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wrTimeMs == null
                        ? t('common.not_available')
                        : formatTimeMs(wrTimeMs!),
                    style: AppTextStyles.interRegular14(
                      color: AppColors.grayLight,
                    ),
                  ),
                  if (wrPlayerName != null)
                    Text(
                      t('track_detail.wr_by', {'player': wrPlayerName}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.interRegular14(
                        color: AppColors.grayMuted,
                      ).copyWith(fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBox(label: t('common.gap'), child: _buildGap()),
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
