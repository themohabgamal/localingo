# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-03

### Added
- **Batch Translation**: Optimized AI translation by grouping items, making generation up to 10x faster.
- **Technical Dictionary**: Added pre-defined translations for mobile development terms (Arabic & Spanish).
- **Placeholder Protection**: Secured `{variable}` tags during translation to prevent corruption.
- **Nested JSON Support**: Now supports organizing translation keys in nested objects while maintaining type-safety.
- **Type-Safe Arguments**: Automatically generates methods for keys with placeholders (e.g., `LocaleKeys.welcome(name: 'John')`).
- **Brand Protection**: Terms like "Flutter", "Firebase", and "Dart" are now preserved during translation.
- **Flatten/Unflatten Logic**: Improved handling of complex JSON structures.

### Improved
- **Error Handling**: Added exponential backoff and automatic retries for more reliable translations.
- **CLI Experience**: Enhanced terminal output with better progress tracking and summary.
- **Type-Safety**: Refined `LocaleKeys` generation for better IDE support.

## [1.0.2] - 2025-11-22

### Fixed
- Fixed missing core files `localingo.dart` and `app_localizations.dart`.
- Updated documentation.

## [1.0.0] - 2025-11-22

### Added
- Initial release of **Localingo**.
- Renamed from `multilingo`.
- Automatic translation generation.
- Type-safe `LocaleKeys`.
- Global context support.
