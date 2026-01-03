// bin/generate.dart
import 'dart:convert';
import 'dart:io';

const String apiUrl = 'https://ftapi.pythonanywhere.com';

// ANSI Color Codes
class Colors {
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String green = '\x1B[32m';
  static const String red = '\x1B[31m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String cyan = '\x1B[36m';
  static const String gray = '\x1B[90m';
}

// Technical Dictionary for Mobile Apps
const Map<String, Map<String, String>> technicalDictionary = {
  'ar': {
    // Auth & Account
    'login': 'تسجيل الدخول',
    'logout': 'تسجيل الخروج',
    'sign up': 'إنشاء حساب',
    'signup': 'إنشاء حساب',
    'register': 'تسجيل',
    'forgot password': 'نسيت كلمة المرور؟',
    'reset password': 'إعادة تعيين كلمة المرور',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'confirm password': 'تأكيد كلمة المرور',
    'phone number': 'رقم الهاتف',
    'username': 'اسم المستخدم',
    'otp': 'رمز التحقق',
    'verification code': 'رمز التحقق',
    'resend code': 'إعادة إرسال الرمز',
    'profile': 'الملف الشخصي',
    'edit profile': 'تعديل الملف الشخصي',
    'account': 'الحساب',

    // UI/UX Common
    'home': 'الرئيسية',
    'settings': 'الإعدادات',
    'notifications': 'الإشعارات',
    'notification': 'إشعار',
    'search': 'بحث',
    'search...': 'بحث...',
    'filter': 'تصفية',
    'sort': 'ترتيب',
    'categories': 'الفئات',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'تم بنجاح',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'apply': 'تطبيق',
    'done': 'تم',
    'next': 'التالي',
    'back': 'رجوع',
    'skip': 'تخطي',
    'get started': 'ابدأ الآن',
    'welcome': 'مرحباً بك',
    'retry': 'إعادة المحاولة',
    'no internet': 'لا يوجد اتصال بالإنترنت',

    // E-commerce & Actions
    'cart': 'السلة',
    'shopping cart': 'سلة التسوق',
    'add to cart': 'أضف إلى السلة',
    'buy now': 'اشترِ الآن',
    'checkout': 'الدفع',
    'payment': 'الدفع',
    'order history': 'سجل الطلبات',
    'track order': 'تتبع الطلب',
    'total': 'الإجمالي',
    'discount': 'خصم',
    'coupon': 'كوبون',
    'wallet': 'المحفظة',

    // Settings & Legal
    'dark mode': 'الوضع الداكن',
    'light mode': 'الوضع الفاتح',
    'language': 'اللغة',
    'appearance': 'المظهر',
    'privacy policy': 'سياسة الخصوصية',
    'terms of service': 'شروط الخدمة',
    'about us': 'من نحن',
    'contact us': 'اتصل بنا',
    'faqs': 'الأسئلة الشائعة',
    'version': 'الإصدار',
    'update available': 'يتوفر تحديث جديد',
    'update now': 'تحديث الآن',
    'permissions': 'الأذونات',

    // Tech Protection (No translation)
    'flutter': 'Flutter',
    'firebase': 'Firebase',
    'dart': 'Dart',
    'android': 'Android',
    'ios': 'iOS',
    'apple': 'Apple',
    'google': 'Google',
    'facebook': 'Facebook',
    'whatsapp': 'WhatsApp',
    'instagram': 'Instagram',
    'github': 'GitHub',
  },
  'es': {
    'flutter': 'Flutter',
    'login': 'Iniciar sesión',
    'logout': 'Cerrar sesión',
    'sign up': 'Registrarse',
    'settings': 'Ajustes',
    'notifications': 'Notificaciones',
  }
};

class TranslationItem {
  final List<String> path;
  final String text;
  String? translated;

  TranslationItem(this.path, this.text);

  String get pathKey => path.join('.');
}

void main(List<String> args) async {
  final startTime = DateTime.now();

  _printHeader();

  try {
    final enFile = File('assets/l10n/en.json');
    if (!await enFile.exists()) {
      _printError('assets/l10n/en.json not found!');
      exit(1);
    }

    final enContent = await enFile.readAsString();
    final Map<String, dynamic> enJson = jsonDecode(enContent);

    final items = <TranslationItem>[];
    _collectItems(enJson, [], items);

    _printInfo('Source: assets/l10n/en.json (${items.length} items)');

    List<String> targetLanguages = [];

    if (args.contains('--all')) {
      targetLanguages = availableLanguages.keys.toList();
    } else if (args.any((arg) => arg.startsWith('--langs='))) {
      final langArg = args.firstWhere((arg) => arg.startsWith('--langs='));
      final langs = langArg.split('=')[1].split(',');
      targetLanguages = langs
          .map((l) => l.trim())
          .where((l) => availableLanguages.containsKey(l))
          .toList();
    }

    if (targetLanguages.isEmpty) {
      targetLanguages = await _selectLanguages();
    }

    if (targetLanguages.isEmpty) {
      _printError('No languages selected!');
      exit(1);
    }

    print('');
    _printDivider();
    print('');

    final batchResults = <String, int>{};

    for (int i = 0; i < targetLanguages.length; i++) {
      final langCode = targetLanguages[i];
      final langStartTime = DateTime.now();

      // Read existing translation file
      final outputFile = File('assets/l10n/$langCode.json');
      Map<String, String> existingTranslations = {};

      if (await outputFile.exists()) {
        try {
          final content = await outputFile.readAsString();
          final Map<String, dynamic> existingJson = jsonDecode(content);
          _collectFlatMap(existingJson, [], existingTranslations);
        } catch (e) {
          _printInfo(
              'Could not parse existing $langCode.json, starting fresh.');
        }
      }

      // Mark existing items as already translated
      final itemsForThisLang =
          items.map((e) => TranslationItem(e.path, e.text)).toList();
      int skippedCount = 0;
      for (final item in itemsForThisLang) {
        if (existingTranslations.containsKey(item.pathKey)) {
          item.translated = existingTranslations[item.pathKey];
          skippedCount++;
        }
      }

      final itemsToProcess =
          itemsForThisLang.where((e) => e.translated == null).toList();

      if (itemsToProcess.isEmpty) {
        stdout.write(
          '${Colors.green}✓ [${i + 1}/${targetLanguages.length}] ${availableLanguages[langCode]} ($langCode) is up to date (Skipped $skippedCount items)${Colors.reset}\n',
        );
        batchResults[langCode] = itemsForThisLang.length;
        continue;
      }

      stdout.write(
        '${Colors.cyan}⏳ [${i + 1}/${targetLanguages.length}] Translating ${itemsToProcess.length} new items to ${availableLanguages[langCode]} ($langCode)... (Skipped $skippedCount existing)${Colors.reset}',
      );

      final translatedItems =
          await _translateInBatches(itemsForThisLang, langCode);

      final Map<String, dynamic> resultJson = {};
      for (final item in translatedItems) {
        _unflatten(resultJson, item.path, item.translated ?? item.text);
      }

      final outputDir = Directory('assets/l10n');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(resultJson);
      await outputFile.writeAsString(jsonString);

      batchResults[langCode] = itemsForThisLang.length;
      final duration = DateTime.now().difference(langStartTime);

      stdout.write('\r\x1B[K');
      _printSuccess(
        '[${i + 1}/${targetLanguages.length}] Updated $langCode.json in ${duration.inSeconds}.${(duration.inMilliseconds % 1000).toString().padLeft(1, '0')}s',
      );
    }

    print('');
    _printDivider();
    print('');

    _printSimpleSummary(batchResults);

    print('');
    stdout.write('${Colors.cyan}📝 Generating LocaleKeys...${Colors.reset}');
    await _generateLocaleKeys(enJson);
    stdout.write('\r\x1B[K');
    _printSuccess('Generated lib/locale_keys.dart');

    final totalDuration = DateTime.now().difference(startTime);
    print('');
    _printSuccess(
      'Completed in ${totalDuration.inSeconds}.${(totalDuration.inMilliseconds % 1000).toString().padLeft(1, '0')}s',
    );
  } catch (e) {
    print('');
    _printError('$e');
    exit(1);
  }
}

void _collectItems(Map<String, dynamic> json, List<String> currentPath,
    List<TranslationItem> items) {
  for (final entry in json.entries) {
    final path = [...currentPath, entry.key];
    if (entry.value is Map) {
      _collectItems(Map<String, dynamic>.from(entry.value), path, items);
    } else {
      items.add(TranslationItem(path, entry.value.toString()));
    }
  }
}

void _collectFlatMap(Map<String, dynamic> json, List<String> currentPath,
    Map<String, String> result) {
  for (final entry in json.entries) {
    final path = [...currentPath, entry.key];
    if (entry.value is Map) {
      _collectFlatMap(Map<String, dynamic>.from(entry.value), path, result);
    } else {
      result[path.join('.')] = entry.value.toString();
    }
  }
}

void _unflatten(Map<String, dynamic> json, List<String> path, String value) {
  Map<String, dynamic> current = json;
  for (int i = 0; i < path.length - 1; i++) {
    current = current.putIfAbsent(path[i], () => <String, dynamic>{});
  }
  current[path.last] = value;
}

Future<List<TranslationItem>> _translateInBatches(
    List<TranslationItem> items, String targetLangCode) async {
  final dict = technicalDictionary[targetLangCode] ?? {};

  // Separate items that need translation
  final itemsToTranslate = items.where((e) => e.translated == null).toList();

  // Step 1: Dictionary translation for new items
  for (final item in itemsToTranslate) {
    final lowercaseText = item.text.toLowerCase().trim();
    if (dict.containsKey(lowercaseText)) {
      item.translated = dict[lowercaseText];
    }
  }

  // Final list to send to API
  final remainingForApi =
      itemsToTranslate.where((e) => e.translated == null).toList();
  if (remainingForApi.isEmpty) return items;

  const int batchSize = 10;
  for (int i = 0; i < remainingForApi.length; i += batchSize) {
    final end = (i + batchSize < remainingForApi.length)
        ? i + batchSize
        : remainingForApi.length;
    final batch = remainingForApi.sublist(i, end);

    // Placeholder Protection Map
    final Map<TranslationItem, Map<String, String>> placeholderMaps = {};

    final List<String> processedTexts = [];
    for (final item in batch) {
      final Map<String, String> pMap = {};
      String text = item.text;
      final matches = RegExp(r'\{([a-zA-Z0-9_]+)\}').allMatches(text);
      int phCounter = 0;

      for (final match in matches) {
        final ph = match.group(0)!;
        final replacement = '__PH_${phCounter}__';
        pMap[replacement] = ph;
        text = text.replaceFirst(ph, replacement);
        phCounter++;
      }
      placeholderMaps[item] = pMap;
      processedTexts.add(text);
    }

    const String delimiter = '\n-----\n';
    final combinedText = processedTexts.join(delimiter);

    try {
      final translatedBatch =
          await _translateTextWithRetry(combinedText, targetLangCode);
      final parts = translatedBatch.split(RegExp(r'\n\s*-----\s*\n'));

      if (parts.length == batch.length) {
        for (int j = 0; j < batch.length; j++) {
          String translated = parts[j].trim();
          // Restore Placeholders
          placeholderMaps[batch[j]]?.forEach((code, original) {
            translated = translated.replaceFirst(code, original);
          });
          batch[j].translated = translated;
        }
      } else {
        // Individual fallback
        for (final item in batch) {
          item.translated = await _translateIndividually(item, targetLangCode);
        }
      }
    } catch (e) {
      for (final item in batch) {
        item.translated = await _translateIndividually(item, targetLangCode);
      }
    }

    if (i + batchSize < remainingForApi.length) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  return items;
}

Future<String> _translateIndividually(
    TranslationItem item, String targetLangCode) async {
  try {
    return await _translateTextWithRetry(item.text, targetLangCode);
  } catch (_) {
    return item.text;
  }
}

Future<String> _translateTextWithRetry(String text, String targetLangCode,
    {int maxRetries = 3}) async {
  if (text.trim().isEmpty) return text;
  int attempts = 0;
  while (attempts < maxRetries) {
    try {
      return await _translateText(text, targetLangCode);
    } catch (e) {
      attempts++;
      if (attempts < maxRetries) {
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }
  throw Exception('Failed after $maxRetries retries');
}

Future<String> _translateText(String text, String targetLangCode) async {
  try {
    final encodedText = Uri.encodeComponent(text);
    final url = '$apiUrl/translate?sl=en&dl=$targetLangCode&text=$encodedText';
    final request = await HttpClient().getUrl(Uri.parse(url));
    request.headers.set('User-Agent', 'Mozilla/5.0');
    request.headers.set('Accept', 'application/json');
    final response = await request.close();
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      final translatedText = data['destination-text'];
      if (translatedText != null &&
          translatedText.toString().trim().isNotEmpty) {
        return translatedText.toString().trim();
      }
      throw Exception('Empty response');
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> _generateLocaleKeys(Map<String, dynamic> enJson) async {
  final buffer = StringBuffer();
  buffer.writeln('// lib/locale_keys.dart');
  buffer.writeln('// Auto-generated file. Do not edit manually.');
  buffer.writeln('');
  buffer.writeln('import \'package:localingo/localingo.dart\';');
  buffer.writeln('');
  buffer.writeln('/// Type-safe translation keys');
  buffer.writeln('class LocaleKeys {');
  final Map<String, String> flatMap = {};
  _flattenForKeys(enJson, '', flatMap);
  for (final entry in flatMap.entries) {
    final key = entry.key;
    final value = entry.value;
    final propertyName = _toCamelCase(key);
    final placeholders = _extractPlaceholders(value);
    if (placeholders.isEmpty) {
      buffer.writeln('  static String get $propertyName => \'$key\'.tr();');
    } else {
      final args = placeholders.map((p) => 'required dynamic $p').join(', ');
      final mapArgs = placeholders.map((p) => '\'$p\': $p').join(', ');
      buffer.writeln(
          '  static String $propertyName({$args}) => \'$key\'.tr(args: {$mapArgs});');
    }
  }
  buffer.writeln('}');
  final file = File('lib/locale_keys.dart');
  await file.writeAsString(buffer.toString());
}

void _flattenForKeys(
    Map<String, dynamic> json, String prefix, Map<String, String> result) {
  for (final entry in json.entries) {
    final key = prefix.isEmpty ? entry.key : '${prefix}_${entry.key}';
    if (entry.value is Map) {
      _flattenForKeys(Map<String, dynamic>.from(entry.value), key, result);
    } else {
      result[key] = entry.value.toString();
    }
  }
}

List<String> _extractPlaceholders(String value) {
  final regex = RegExp(r'\{([a-zA-Z0-9_)...]+)\}');
  final matches = regex.allMatches(value);
  return matches.map((m) => m.group(1)!).toSet().toList();
}

String _toCamelCase(String str) {
  final parts = str.split(RegExp(r'[_.-]'));
  if (parts.isEmpty) return str;
  final buffer = StringBuffer(parts[0]);
  for (int i = 1; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      buffer.write(parts[i][0].toUpperCase());
      if (parts[i].length > 1) buffer.write(parts[i].substring(1));
    }
  }
  return buffer.toString();
}

Future<List<String>> _selectLanguages() async {
  print(
      '${Colors.bold}${Colors.cyan}Select languages to generate:${Colors.reset}');
  final languages = availableLanguages.entries.toList();
  for (int i = 0; i < languages.length; i++) {
    print(
        '  ${Colors.cyan}${(i + 1).toString().padLeft(2)}${Colors.reset}. ${languages[i].value}');
  }
  stdout.write(
      '\n${Colors.bold}Your selection (e.g. 1 3 5 or "all"): ${Colors.reset}');
  final input = stdin.readLineSync()?.trim() ?? '';
  if (input.toLowerCase() == 'all') return languages.map((e) => e.key).toList();
  final selected = <String>{};
  for (final numStr in input.split(RegExp(r'[\s,]+'))) {
    final num = int.tryParse(numStr);
    if (num != null && num >= 1 && num <= languages.length)
      selected.add(languages[num - 1].key);
  }
  return selected.isEmpty
      ? ['ar', 'de', 'fr', 'es']
      : (selected.toList()..sort());
}

const Map<String, String> availableLanguages = {
  'ar': 'Arabic',
  'de': 'German',
  'fr': 'French',
  'es': 'Spanish',
  'it': 'Italian',
  'pt': 'Portuguese',
  'ru': 'Russian',
  'ja': 'Japanese',
  'ko': 'Korean',
  'zh-CN': 'Chinese Simplified',
  'hi': 'Hindi',
  'tr': 'Turkish',
  'nl': 'Dutch',
  'pl': 'Polish',
};

void _printHeader() {
  print(
      '\n${Colors.bold}${Colors.cyan}╔════════════════════════════════════════════════╗');
  print('║         Localingo - Translation Generator      ║');
  print('╚════════════════════════════════════════════════╝\n');
}

void _printDivider() => print(
    '${Colors.gray}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Colors.reset}');
void _printSuccess(String m) => print('${Colors.green}✓${Colors.reset} $m');
void _printError(String m) => print('${Colors.red}✗ Error: $m${Colors.reset}');
void _printInfo(String m) => print('${Colors.blue}ℹ${Colors.reset} $m');
void _printSimpleSummary(Map<String, int> results) {
  print('${Colors.bold}📊 Summary:${Colors.reset}');
  results.forEach((lang, count) {
    print(
        '  • ${lang.padRight(5)} : $count items ${Colors.green}✓${Colors.reset}');
  });
}
