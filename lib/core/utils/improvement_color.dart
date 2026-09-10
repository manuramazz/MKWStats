import 'package:flutter/material.dart';

Color improvementColor(double improvementSeconds) {
  final t = improvementSeconds.clamp(0, 1.5) / 1.5;
  final r = (222 + t * (3 - 222)).round();
  final g = (247 + t * (84 - 247)).round();
  final b = (236 + t * (63 - 236)).round();
  return Color.fromARGB(255, r, g, b);
}
