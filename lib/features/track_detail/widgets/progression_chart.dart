import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/personal_time.dart';

class ProgressionChart extends StatelessWidget {
  final List<PersonalTime> times;
  final int? wrTimeMs;

  const ProgressionChart({
    super.key,
    required this.times,
    required this.wrTimeMs,
  });

  @override
  Widget build(BuildContext context) {
    if (times.isEmpty || wrTimeMs == null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Aún no tienes tiempos registrados en este circuito',
            textAlign: TextAlign.center,
            style: AppTextStyles.interRegular14(color: AppColors.grayMuted),
          ),
        ),
      );
    }

    final sorted = [...times]
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));
    final firstDate = sorted.first.recordDate;

    final spots = sorted.map((t) {
      final x = t.recordDate.difference(firstDate).inDays.toDouble();
      final y = (t.timeMs - wrTimeMs!) / 1000;
      return FlSpot(x, y);
    }).toList();

    final minX = spots.map((s) => s.x).reduce((a, b) => a < b ? a : b);
    final maxX = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    final xPad = (maxX - minX) * 0.1 + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: Row(
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'Gap to WR',
                  style: AppTextStyles.interRegular14(
                    color: AppColors.grayMuted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: minX - xPad,
                    maxX: maxX + xPad,
                    lineTouchData: const LineTouchData(enabled: false),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final date = firstDate.add(
                              Duration(days: value.round()),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: AppTextStyles.interRegular14(
                                  color: AppColors.grayMuted,
                                ).copyWith(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      // y = 0 dashed reference line ("tied the WR exactly")
                      LineChartBarData(
                        spots: [FlSpot(minX - xPad, 0), FlSpot(maxX + xPad, 0)],
                        color: AppColors.grayMuted,
                        barWidth: 1,
                        dashArray: const [4, 4],
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: spots,
                        color: Colors.transparent,
                        barWidth: 0,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.gold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Text(
            'Date',
            style: AppTextStyles.interRegular14(color: AppColors.grayMuted),
          ),
        ),
      ],
    );
  }
}
