String formatTimeMs(int ms) {
  final minutes = ms ~/ 60000;
  final seconds = (ms % 60000) ~/ 1000;
  final millis = ms % 1000;
  final secondsStr = seconds.toString().padLeft(2, '0');
  final millisStr = millis.toString().padLeft(3, '0');
  return '$minutes:$secondsStr.$millisStr';
}

String formatGapSeconds(int gapMs, {bool withUnit = true}) {
  final sign = gapMs >= 0 ? '+' : '-';
  final seconds = gapMs.abs() / 1000;
  return '$sign${seconds.toStringAsFixed(3)}${withUnit ? ' sec' : ''}';
}

/// dd/MM/yy
String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = (date.year % 100).toString().padLeft(2, '0');
  return '$day/$month/$year';
}

String formatGapPercent(int gapMs, int wrTimeMs) {
  final sign = gapMs >= 0 ? '+' : '-';
  final percent = gapMs.abs() / wrTimeMs * 100;
  return '$sign${percent.toStringAsFixed(2)}%';
}
