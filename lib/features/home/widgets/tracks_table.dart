import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_format.dart';
import '../../../data/models/track.dart';
import '../../../data/models/world_record.dart';

const double tracksTableHeaderHeight = 52;

enum TracksSortColumn { track, bestTime, gap }

enum SortDirection { ascending, descending }

class TracksTableHeader extends StatelessWidget {
  final TracksSortColumn? sortColumn;
  final SortDirection sortDirection;
  final ValueChanged<TracksSortColumn> onSort;

  const TracksTableHeader({
    super.key,
    required this.sortColumn,
    required this.sortDirection,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tracksTableHeaderHeight,
      color: AppColors.tableDark,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: _HeaderCell(
                    label: 'TRACK',
                    column: TracksSortColumn.track,
                    activeColumn: sortColumn,
                    sortDirection: sortDirection,
                    onTap: onSort,
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _HeaderCell(
                    label: 'BEST TIME',
                    column: TracksSortColumn.bestTime,
                    activeColumn: sortColumn,
                    sortDirection: sortDirection,
                    onTap: onSort,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: _HeaderCell(
                    label: 'GAP',
                    column: TracksSortColumn.gap,
                    activeColumn: sortColumn,
                    sortDirection: sortDirection,
                    onTap: onSort,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.grayMuted),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final TracksSortColumn column;
  final TracksSortColumn? activeColumn;
  final SortDirection sortDirection;
  final ValueChanged<TracksSortColumn> onTap;

  const _HeaderCell({
    required this.label,
    required this.column,
    required this.activeColumn,
    required this.sortDirection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = activeColumn == column;
    return InkWell(
      onTap: () => onTap(column),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.interSemiBold12(color: AppColors.white),
          ),
          if (isActive) ...[
            const SizedBox(width: 4),
            Icon(
              sortDirection == SortDirection.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 12,
              color: AppColors.white,
            ),
          ],
        ],
      ),
    );
  }
}

class TracksTableHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TracksSortColumn? sortColumn;
  final SortDirection sortDirection;
  final ValueChanged<TracksSortColumn> onSort;

  const TracksTableHeaderDelegate({
    required this.sortColumn,
    required this.sortDirection,
    required this.onSort,
  });

  @override
  double get minExtent => tracksTableHeaderHeight;

  @override
  double get maxExtent => tracksTableHeaderHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return TracksTableHeader(
      sortColumn: sortColumn,
      sortDirection: sortDirection,
      onSort: onSort,
    );
  }

  @override
  bool shouldRebuild(covariant TracksTableHeaderDelegate oldDelegate) {
    return oldDelegate.sortColumn != sortColumn ||
        oldDelegate.sortDirection != sortDirection;
  }
}

class TracksTableRows extends StatelessWidget {
  final List<Track> tracks;
  final List<WorldRecord> worldRecords;
  final Map<int, int> bestTimesByTrack;
  final ValueChanged<Track> onTrackTap;

  const TracksTableRows({
    super.key,
    required this.tracks,
    required this.worldRecords,
    required this.bestTimesByTrack,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    final wrByTrack = {for (final wr in worldRecords) wr.trackId: wr};

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.tableDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(
        children: [
          for (final track in tracks)
            _TrackRow(
              track: track,
              worldRecord: wrByTrack[track.id],
              personalBestMs: bestTimesByTrack[track.id],
              onTap: () => onTrackTap(track),
            ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  final Track track;
  final WorldRecord? worldRecord;
  final int? personalBestMs;
  final VoidCallback onTap;

  const _TrackRow({
    required this.track,
    this.worldRecord,
    this.personalBestMs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 10, right: 8, bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Text(
                track.name,
                style: AppTextStyles.interRegular14(
                  color: AppColors.white,
                ).copyWith(fontSize: 11),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                personalBestMs == null
                    ? 'No time set'
                    : formatTimeMs(personalBestMs!),
                style: AppTextStyles.interRegular14(
                  color: AppColors.grayMuted,
                ).copyWith(fontSize: 12),
              ),
            ),
            Expanded(
              flex: 4,
              child: personalBestMs == null || worldRecord == null
                  ? Text(
                      '—',
                      style: AppTextStyles.interRegular14(
                        color: AppColors.grayMuted,
                      ).copyWith(fontSize: 12),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatGapSeconds(
                            personalBestMs! - worldRecord!.timeMs,
                          ),
                          style: AppTextStyles.interRegular14(
                            color: AppColors.grayMuted,
                          ).copyWith(fontSize: 12),
                        ),
                        Text(
                          formatGapPercent(
                            personalBestMs! - worldRecord!.timeMs,
                            worldRecord!.timeMs,
                          ),
                          style: AppTextStyles.interRegular14(
                            color: AppColors.grayMuted,
                          ).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 1),
            const SizedBox(
              width: 24,
              child: Icon(
                Icons.keyboard_double_arrow_right,
                color: AppColors.grayMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
