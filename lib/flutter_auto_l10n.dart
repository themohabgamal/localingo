// lib/flutter_auto_l10n.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:flutter/foundation.dart';

class FlutterAutoL10n {
  static const String _apiUrl = 'https://ftapi.pythonanywhere.com';

  /// Generates and saves localization files from English source - 100% FREE
  ///
  /// [enAssetPath] - Asset path to the English JSON file (e.g., 'assets/l10n/en.json')
  /// [targetLanguages] - List of language codes (e.g., ['ar', 'de', 'fr', 'es'])
  /// [outputDirectory] - Directory where translation files will be saved (e.g., 'assets/l10n')
  /// [onProgress] - Optional callback to track progress
  /// [delayBetweenTranslations] - Delay in milliseconds between translations (default: 200ms)
  ///
  /// Generates translations and automatically saves them to disk
  static Future<void> generateAndSaveLocalizations({
    required String enAssetPath,
    required List<String> targetLanguages,
    required String outputDirectory,
    Function(String language, String status)? onProgress,
    int delayBetweenTranslations = 200,
  }) async {
    // Generate translations
    final results = await generateLocalizations(
      enAssetPath: enAssetPath,
      targetLanguages: targetLanguages,
      onProgress: onProgress,
      delayBetweenTranslations: delayBetweenTranslations,
    );

    // Save each language file
    final outputDir = Directory(outputDirectory);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    for (final entry in results.entries) {
      final langCode = entry.key;
      final jsonContent = entry.value;
      final jsonString = getJsonString(jsonContent);

      final file = File('$outputDirectory/$langCode.json');
      await file.writeAsString(jsonString);

      if (kDebugMode) {
        print('💾 Saved: ${file.path}');
      }
    }

    if (kDebugMode) {
      print('📁 All files saved to: $outputDirectory');
    }
  }

  /// Generates localization files from English source - 100% FREE
  ///
  /// [enAssetPath] - Asset path to the English JSON file (e.g., 'assets/l10n/en.json')
  /// [targetLanguages] - List of language codes (e.g., ['ar', 'de', 'fr', 'es'])
  /// [onProgress] - Optional callback to track progress
  /// [delayBetweenTranslations] - Delay in milliseconds between translations (default: 200ms)
  ///
  /// Returns a Map with language codes as keys and translated JSON as values
  static Future<Map<String, Map<String, dynamic>>> generateLocalizations({
    required String enAssetPath,
    required List<String> targetLanguages,
    Function(String language, String status)? onProgress,
    int delayBetweenTranslations = 200,
  }) async {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    try {
      onProgress?.call('en', 'Reading English file...');

      // Read the English JSON file from assets
      final enContent = await rootBundle.loadString(enAssetPath);
      final Map<String, dynamic> enJson = jsonDecode(enContent);

      if (kDebugMode) {
        print('🌍 Starting localization generation...');
        print('📝 Source: $enAssetPath');
        print('🎯 Target languages: ${targetLanguages.join(", ")}');
        print('🔧 API: Free Translate API (ftapi.pythonanywhere.com)');
        print('');
      }

      final results = <String, Map<String, dynamic>>{};

      // Generate translations for each language
      for (final langCode in targetLanguages) {
        onProgress?.call(langCode, 'Translating...');

        if (kDebugMode) {
          print('🔄 Translating to $langCode...');
        }

        final translatedJson = await _translateJson(
          enJson,
          langCode,
          delayBetweenTranslations,
        );

        results[langCode] = translatedJson;

        onProgress?.call(langCode, 'Completed');

        if (kDebugMode) {
          print('✅ Generated: $langCode.json');
        }
      }

      if (kDebugMode) {
        print('');
        print('🎉 Localization generation completed successfully!');
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      rethrow;
    }
  }

  /// Translates a JSON map to the target language
  static Future<Map<String, dynamic>> _translateJson(
    Map<String, dynamic> sourceJson,
    String targetLangCode,
    int delayMs,
  ) async {
    final result = <String, dynamic>{};

    for (final entry in sourceJson.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        // Translate string values with retry logic
        try {
          final translatedValue = await _translateTextWithRetry(
            value,
            targetLangCode,
          );
          result[key] = translatedValue;
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to translate "$key": $e');
          }
          result[key] = value; // Keep original if translation fails
        }

        // Add delay to avoid overwhelming the API
        await Future.delayed(Duration(milliseconds: delayMs));
      } else if (value is Map) {
        // Recursively translate nested objects
        result[key] = await _translateJson(
          Map<String, dynamic>.from(value),
          targetLangCode,
          delayMs,
        );
      } else {
        // Keep non-string values as is
        result[key] = value;
      }
    }

    return result;
  }

  /// Translates text with automatic retry on failure
  static Future<String> _translateTextWithRetry(
    String text,
    String targetLangCode, {
    int maxRetries = 3,
  }) async {
    // Skip empty strings
    if (text.trim().isEmpty) return text;

    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await _translateText(text, targetLangCode);
      } catch (e) {
        attempts++;

        if (attempts < maxRetries) {
          // Wait before retry: 1s, 2s, 3s
          await Future.delayed(Duration(seconds: attempts));
        }
      }
    }

    // If all retries failed, return original text
    if (kDebugMode) {
      print('⚠️ Translation failed after $maxRetries attempts: $text');
    }
    return text;
  }

  /// Translates a single text string using Free Translate API
  static Future<String> _translateText(
    String text,
    String targetLangCode,
  ) async {
    try {
      // URL encode the text
      final encodedText = Uri.encodeComponent(text);

      // Build the API URL
      final url =
          '$_apiUrl/translate?sl=en&dl=$targetLangCode&text=$encodedText';

      final request = await HttpClient().getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'Mozilla/5.0');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);

        // Extract the translated text
        final translatedText = data['destination-text'];

        if (translatedText != null &&
            translatedText.toString().trim().isNotEmpty) {
          return translatedText.toString().trim();
        }

        return text;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Translation API error: $e');
    }
  }

  /// Get JSON string for a specific language
  static String getJsonString(Map<String, dynamic> json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  /// Get list of supported locale codes
  static List<String> getSupportedLocaleCodes() {
    return ['en', 'ar', 'de', 'fr', 'es'];
  }

  /// Get Locale objects for supported languages
  static List<dynamic> getSupportedLocales() {
    return getSupportedLocaleCodes()
        .map((code) => {'languageCode': code})
        .toList();
  }

  /// Get list of supported languages
  static Map<String, String> getSupportedLanguages() {
    return {
      'ar': 'Arabic (العربية)',
      'de': 'German (Deutsch)',
      'fr': 'French (Français)',
      'es': 'Spanish (Español)',
      'it': 'Italian (Italiano)',
      'pt': 'Portuguese (Português)',
      'ru': 'Russian (Русский)',
      'ja': 'Japanese (日本語)',
      'ko': 'Korean (한국어)',
      'zh-CN': 'Chinese Simplified (简体中文)',
      'zh-TW': 'Chinese Traditional (繁體中文)',
      'hi': 'Hindi (हिन्दी)',
      'tr': 'Turkish (Türkçe)',
      'nl': 'Dutch (Nederlands)',
      'pl': 'Polish (Polski)',
      'sv': 'Swedish (Svenska)',
      'da': 'Danish (Dansk)',
      'no': 'Norwegian (Norsk)',
      'fi': 'Finnish (Suomi)',
      'el': 'Greek (Ελληνικά)',
      'he': 'Hebrew (עברית)',
      'th': 'Thai (ไทย)',
      'vi': 'Vietnamese (Tiếng Việt)',
      'id': 'Indonesian (Bahasa Indonesia)',
      'ms': 'Malay (Bahasa Melayu)',
      'cs': 'Czech (Čeština)',
      'sk': 'Slovak (Slovenčina)',
      'ro': 'Romanian (Română)',
      'hu': 'Hungarian (Magyar)',
      'uk': 'Ukrainian (Українська)',
      'bg': 'Bulgarian (Български)',
      'hr': 'Croatian (Hrvatski)',
      'sr': 'Serbian (Српски)',
      'bn': 'Bengali (বাংলা)',
      'ta': 'Tamil (தமிழ்)',
      'te': 'Telugu (తెలుగు)',
      'mr': 'Marathi (मराठी)',
      'ur': 'Urdu (اردو)',
      'fa': 'Persian (فارسی)',
      'sw': 'Swahili (Kiswahili)',
    };
  }
}
