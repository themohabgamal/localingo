export 'app_localizations.dart';
export 'flutter_auto_l10n.dart';
import 'package:flutter/material.dart';

class Localingo {
  static GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static BuildContext? get context => _navigatorKey.currentContext;

  /// Set the navigator key to enable global context access
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Change the app locale and notify the app
  /// This requires the app to be listening to locale changes
  static void setLocale(BuildContext context, Locale locale) {
    // This is a placeholder for a more robust locale management
    // In a real app, you might use a Provider or Bloc to manage locale
    // For now, we provide the method as a standard entry point
    debugPrint('Localingo: Changing locale to ${locale.languageCode}');
  }
}
