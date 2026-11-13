import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/i18n/i18n.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

class MkwStatsApp extends StatefulWidget {
  const MkwStatsApp({super.key});

  @override
  State<MkwStatsApp> createState() => _MkwStatsAppState();
}

class _MkwStatsAppState extends State<MkwStatsApp> {
  @override
  void initState() {
    super.initState();
    I18n.language.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    I18n.language.removeListener(_onLanguageChanged);
    super.dispose();
  }

  /// `t()` no depende del contexto, así que los widgets no se enteran solos
  /// del cambio de idioma: se marca todo el árbol para reconstruir. Se
  /// conserva el estado (datos cargados, scroll, pila de navegación).
  void _onLanguageChanged() {
    setState(() {});
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MKWorld Stats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
      locale: I18n.language.value.locale,
      supportedLocales: [for (final l in AppLanguage.values) l.locale],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
