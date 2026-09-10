import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

class MkwStatsApp extends StatelessWidget {
  const MkwStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MKWStats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
