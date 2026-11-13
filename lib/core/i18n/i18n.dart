import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  es,
  en;

  Locale get locale => Locale(name);
}

/// Textos de la app en `locale/<idioma>.json`. Se accede con [t].
///
/// Idioma inicial: el guardado en el dispositivo; si no hay ninguno, el del
/// sistema (español → es, cualquier otro → en).
class I18n {
  I18n._();

  static const _prefsKey = 'app_language';
  static const fallback = AppLanguage.en;

  /// Idioma activo. `MkwStatsApp` lo escucha para repintar la app entera.
  static final language = ValueNotifier<AppLanguage>(fallback);

  static final Map<AppLanguage, Map<String, String>> _strings = {};

  static Future<void> init() async {
    for (final lang in AppLanguage.values) {
      final raw = await rootBundle.loadString('locale/${lang.name}.json');
      _strings[lang] = _flatten(jsonDecode(raw) as Map<String, dynamic>);
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = AppLanguage.values
        .where((l) => l.name == prefs.getString(_prefsKey))
        .firstOrNull;
    final deviceIsSpanish =
        PlatformDispatcher.instance.locale.languageCode == 'es';
    language.value =
        saved ?? (deviceIsSpanish ? AppLanguage.es : AppLanguage.en);
  }

  static Future<void> setLanguage(AppLanguage lang) async {
    language.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang.name);
  }

  static String translate(String key, [Map<String, Object?>? params]) {
    var text =
        _strings[language.value]?[key] ?? _strings[fallback]?[key] ?? key;
    assert(
      _strings[language.value]?.containsKey(key) ?? true,
      'Missing i18n key "$key" for ${language.value.name}',
    );
    params?.forEach((name, value) {
      text = text.replaceAll('{$name}', '$value');
    });
    return text;
  }

  /// `{"a": {"b": "x"}}` → `{"a.b": "x"}`
  static Map<String, String> _flatten(
    Map<String, dynamic> json, [
    String prefix = '',
  ]) {
    final result = <String, String>{};
    json.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flatten(value, fullKey));
      } else {
        result[fullKey] = '$value';
      }
    });
    return result;
  }
}

/// Texto traducido para [key] (ruta con puntos, p. ej. `'home.best_track'`).
/// Los `{nombre}` del texto se sustituyen con [params].
String t(String key, [Map<String, Object?>? params]) =>
    I18n.translate(key, params);
