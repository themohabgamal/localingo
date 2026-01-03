<h1 align="center" style="margin-bottom: 0;">
  🌍 <b>Localingo</b> 🌍
</h1>

<div align="center" style="margin-top: 10px;">
  <div style="font-size: 14px; text-align: center;">Advanced AI-Powered Localization for Flutter</div>
  <div style="font-size: 12px; color: #888; text-align: center;">Breaking language barriers with ease</div>
</div>

## 🚀 Why Localingo?

Localingo is not just another localization package. It's an AI-powered assistant that handles the tedious parts of internationalization. From batch AI translations to generating type-safe keys with placeholder support, Localingo makes your app global in minutes.

## ✨ Key Features (v1.1.0)

- **⚡ Batch AI Translation**: Grouped requests make translation 10x faster.
- **🔄 Incremental Updates**: Only translates new keys. No redundant API calls, no loss of manual edits.
- **📚 Technical Dictionary**: Context-aware translations for mobile UI (e.g., "Notifications" -> "إشعارات").
- **🛡️ Placeholder Protection**: AI-safe handling of `{variable}` tags.
- **🎯 Type-Safe LocaleKeys**: Access your strings via `LocaleKeys.someKey()` with full IDE support.
- **🧩 Nested JSON Support**: Organise your keys into objects for better maintainability.
- **✨ Brand Protection**: Preserves technical brands like Flutter, Firebase, Android, iOS, etc.

## 📦 Installation

Add **Localingo** to your `pubspec.yaml`:

```yaml
dependencies:
  localingo: ^1.1.0
  flutter_localizations:
    sdk: flutter
```

## 🚀 Quick Start

### Step 1: Source Language
Create `assets/l10n/en.json`:
```json
{
  "welcome_user": "Welcome, {name}!",
  "auth": {
     "login": "Log In"
  }
}
```

### Step 2: Generate
Run the interactive CLI:
```bash
dart run localingo:generate
```
**Localingo will:**
1. Detect new keys.
2. Translate in batches (AI-powered).
3. Securely handle placeholders.
4. Generate `lib/locale_keys.dart`.

### Step 3: Usage
```dart
// Type-safe with arguments!
Text(LocaleKeys.welcomeUser(name: 'Mohab'))
Text(LocaleKeys.authLogin)
```

## 📋 API Reference

### Global Navigator Key
To use translations without context, register your navigator key:
```dart
MaterialApp(
  navigatorKey: Localingo.navigatorKey, // Using the global key
  localizationsDelegates: [
    AppLocalizations.delegate,
    ...
  ],
)
```

---
<div align="center">
  Made with ❤️ for the Flutter Community
</div>