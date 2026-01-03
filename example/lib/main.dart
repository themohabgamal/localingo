import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localingo/localingo.dart';
import 'locale_keys.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  // Create a global key for the navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Set the navigator key in Localingo
    Localingo.setNavigatorKey(_navigatorKey);
  }

  void _changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Localingo Demo',
      navigatorKey: _navigatorKey, // Pass the key to MaterialApp
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('fr'),
        Locale('es'),
        Locale('de'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        currentLocale: _locale,
        onLocaleChange: _changeLocale,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) onLocaleChange;

  const MyHomePage({
    super.key,
    required this.currentLocale,
    required this.onLocaleChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(LocaleKeys.appName), // No context needed!
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              const Icon(
                Icons.language,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 32),

              // Welcome message (Hardcoded)
              Text(
                "Welcome to Localingo!",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description (Hardcoded)
              Text(
                "A simple and powerful Flutter localization package",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Language selector title (Hardcoded)
              Text(
                "Select Language",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Language buttons (Hardcoded labels)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _LanguageButton(
                    label: "English",
                    locale: const Locale('en'),
                    isSelected: currentLocale.languageCode == 'en',
                    onPressed: onLocaleChange,
                  ),
                  _LanguageButton(
                    label: "Arabic",
                    locale: const Locale('ar'),
                    isSelected: currentLocale.languageCode == 'ar',
                    onPressed: onLocaleChange,
                  ),
                  _LanguageButton(
                    label: "French",
                    locale: const Locale('fr'),
                    isSelected: currentLocale.languageCode == 'fr',
                    onPressed: onLocaleChange,
                  ),
                  _LanguageButton(
                    label: "Spanish",
                    locale: const Locale('es'),
                    isSelected: currentLocale.languageCode == 'es',
                    onPressed: onLocaleChange,
                  ),
                  _LanguageButton(
                    label: "German",
                    locale: const Locale('de'),
                    isSelected: currentLocale.languageCode == 'de',
                    onPressed: onLocaleChange,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Current language display (Hardcoded label)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Current Language",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentLocale.languageCode.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final Locale locale;
  final bool isSelected;
  final Function(Locale) onPressed;

  const _LanguageButton({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          onPressed(locale);
        }
      },
      checkmarkColor: Colors.white,
      selectedColor: Colors.deepPurple,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
