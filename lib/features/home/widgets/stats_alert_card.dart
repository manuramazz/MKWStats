import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/track.dart';
import '../../../data/models/world_record.dart';

class StatsAlertCard extends StatelessWidget {
  final List<Track> tracks;
  final List<WorldRecord> worldRecords;
  final Map<int, int> bestTimesByTrack;

  const StatsAlertCard({
    super.key,
    required this.tracks,
    required this.worldRecords,
    required this.bestTimesByTrack,
  });

  @override
  Widget build(BuildContext context) {
    final wrByTrack = {for (final wr in worldRecords) wr.trackId: wr};

    final completedCount = bestTimesByTrack.length;

    final gapsMs = <int>[];
    final gapPercents = <double>[];
    String? bestTrackName;
    double? bestTrackPercent;

    for (final track in tracks) {
      final personalMs = bestTimesByTrack[track.id];
      final wr = wrByTrack[track.id];
      if (personalMs == null || wr == null) continue;

      final gapMs = personalMs - wr.timeMs;
      final gapPercent = gapMs / wr.timeMs * 100;
      gapsMs.add(gapMs);
      gapPercents.add(gapPercent);

      if (bestTrackPercent == null || gapPercent < bestTrackPercent) {
        bestTrackPercent = gapPercent;
        bestTrackName = track.name;
      }
    }

    final averageGapMs = gapsMs.isEmpty
        ? null
        : gapsMs.reduce((a, b) => a + b) / gapsMs.length;
    final averageGapPercent = gapPercents.isEmpty
        ? null
        : gapPercents.reduce((a, b) => a + b) / gapPercents.length;

    final averageGapText = averageGapMs == null
        ? '—'
        : '${averageGapMs >= 0 ? '+' : '-'}'
              '${(averageGapMs.abs() / 1000).toStringAsFixed(3)} sec / '
              '${averageGapPercent!.abs().toStringAsFixed(2)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.navbarBrown,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('Completed tracks'),
                  _label('Average gap to WR'),
                  _label('Best track'),
                ],
              ),
            ),
            const VerticalDivider(color: AppColors.grayLight, width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _value('$completedCount / ${tracks.length}'),
                  _value(averageGapText),
                  bestTrackName == null
                      ? _value('—')
                      : Text(
                          bestTrackName.toUpperCase(),
                          style: AppTextStyles.bangers16(
                            color: AppColors.grayLight,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: AppTextStyles.interRegular14(color: AppColors.grayLight),
      ),
    );
  }

  Widget _value(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: AppTextStyles.interRegular14(color: AppColors.grayLight),
      ),
    );
  }
}
