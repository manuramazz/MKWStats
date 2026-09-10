import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/improvement_color.dart';
import '../../../core/utils/time_format.dart';
import '../../../data/models/personal_time.dart';

class MyTimesTable extends StatelessWidget {
  final List<PersonalTime> times;
  final int? wrTimeMs;

  const MyTimesTable({super.key, required this.times, required this.wrTimeMs});

  List<_RowData> _computeRows() {
    final chronological = [...times]
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    final withImprovement = <_RowData>[];
    for (final t in chronological) {
      final priorTimes = chronological.where(
        (o) => o.recordDate.isBefore(t.recordDate),
      );
      if (priorTimes.isEmpty) {
        withImprovement.add(_RowData(t, null));
      } else {
        final priorBest = priorTimes
            .map((o) => o.timeMs)
            .reduce((a, b) => a < b ? a : b);
        withImprovement.add(_RowData(t, priorBest - t.timeMs));
      }
    }

    withImprovement.sort((a, b) => a.time.timeMs.compareTo(b.time.timeMs));
    return withImprovement;
  }

  @override
  Widget build(BuildContext context) {
    if (times.isEmpty) {
      return Text(
        'Aún no tienes tiempos registrados en este circuito',
        style: AppTextStyles.interRegular14(color: AppColors.grayMuted),
      );
    }

    final rows = _computeRows();

    return Column(
      children: [
        Row(
          children: [
            _headerCell('Time', 3),
            _headerCell('Improvement', 3),
            _headerCell('Gap (s)', 2),
            _headerCell('Gap (%)', 2),
            _headerCell('Date', 3),
          ],
        ),
        for (var i = 0; i < rows.length; i++) _buildRow(rows[i], i),
      ],
    );
  }

  Widget _headerCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grayLight,
        ),
      ),
    );
  }

  Widget _buildRow(_RowData row, int index) {
    final isFastest = index == 0;
    final rowColor = index.isEven
        ? AppColors.secondaryBrown
        : AppColors.statBoxBrown;

    Widget improvementCell;
    if (row.improvementMs == null) {
      improvementCell = Text(
        '—',
        style: AppTextStyles.interRegular14(
          color: AppColors.grayLight,
        ).copyWith(fontSize: 12),
      );
    } else {
      final improvementMs = row.improvementMs!;
      final seconds = improvementMs.abs() / 1000;
      final isRealImprovement = improvementMs > 0;
      improvementCell = Text(
        '${isRealImprovement ? '-' : '+'}${seconds.toStringAsFixed(3)}',
        style: AppTextStyles.interRegular14(
          color: isRealImprovement
              ? improvementColor(seconds)
              : AppColors.grayLight,
        ).copyWith(fontSize: 12),
      );
    }

    final gapMs = wrTimeMs == null ? null : row.time.timeMs - wrTimeMs!;

    return Container(
      color: rowColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              formatTimeMs(row.time.timeMs),
              style: AppTextStyles.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isFastest ? AppColors.gold : AppColors.grayLight,
              ),
            ),
          ),
          Expanded(flex: 3, child: improvementCell),
          Expanded(
            flex: 2,
            child: Text(
              gapMs == null ? '—' : formatGapSeconds(gapMs),
              style: AppTextStyles.interRegular14(
                color: AppColors.grayLight,
              ).copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              gapMs == null ? '—' : formatGapPercent(gapMs, wrTimeMs!),
              style: AppTextStyles.interRegular14(
                color: AppColors.grayLight,
              ).copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${row.time.recordDate.day}/${row.time.recordDate.month.toString().padLeft(2, '0')}/${row.time.recordDate.year}',
              style: AppTextStyles.interRegular14(
                color: AppColors.grayLight,
              ).copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowData {
  final PersonalTime time;
  final int? improvementMs;

  _RowData(this.time, this.improvementMs);
}
