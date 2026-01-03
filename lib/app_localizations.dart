import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'localingo.dart';

/// Main localization class that loads and provides translations
class AppLocalizations {
  final Locale locale;
  Map<String, dynamic> _localizedStrings = {};

  AppLocalizations(this.locale);

  /// Get the current AppLocalizations instance from context
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Localization delegate
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Load the JSON file for the current locale
  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/l10n/${locale.languageCode}.json',
      );
      _localizedStrings = _flattenMap(json.decode(jsonString));
      return true;
    } catch (e) {
      try {
        // Fallback to English if locale file not found
        String jsonString = await rootBundle.loadString('assets/l10n/en.json');
        _localizedStrings = _flattenMap(json.decode(jsonString));
        return true;
      } catch (e) {
        debugPrint('Error loading localization: $e');
        return false;
      }
    }
  }

  /// Flatten nested JSON keys
  Map<String, dynamic> _flattenMap(Map<String, dynamic> json,
      [String prefix = '']) {
    final Map<String, dynamic> result = {};
    for (final entry in json.entries) {
      final key = prefix.isEmpty ? entry.key : '${prefix}_${entry.key}';
      if (entry.value is Map<String, dynamic>) {
        result.addAll(_flattenMap(entry.value, key));
      } else {
        result[key] = entry.value;
      }
    }
    return result;
  }

  /// Translate a key to the current locale
  String translate(String key, {Map<String, dynamic>? args}) {
    String value = _localizedStrings[key]?.toString() ?? key;

    if (args != null && args.isNotEmpty) {
      args.forEach((key, val) {
        value = value.replaceAll('{$key}', val.toString());
      });
    }

    return value;
  }

  /// Short alias for translate
  String tr(String key, {Map<String, dynamic>? args}) =>
      translate(key, args: args);

  /// Get all available keys
  List<String> get keys => _localizedStrings.keys.toList();
}

/// Localization delegate for Flutter
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Basic support check - this can be further improved to check actual files
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension to add .tr() method to String for easy translations
extension StringTranslation on String {
  String tr({BuildContext? context, Map<String, dynamic>? args}) {
    // Try to use the provided context
    if (context != null) {
      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        return localizations.translate(this, args: args);
      }
    }

    // Try to use the global context from Localingo
    final globalContext = Localingo.navigatorKey.currentContext;
    if (globalContext != null) {
      final localizations = AppLocalizations.of(globalContext);
      if (localizations != null) {
        return localizations.translate(this, args: args);
      }
    }

    // Fallback: return the key itself if no context is available
    debugPrint(
        'WARNING: No context available for translation of key "$this". Returning key.');
    return this;
  }
}
