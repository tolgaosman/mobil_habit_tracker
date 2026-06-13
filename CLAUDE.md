# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter habit + routine tracker (display name "Quests+"). Offline-first: all data lives in local Hive boxes; there is no backend except an on-the-fly Google Translate call for UI localization. Android-targeted (iOS launcher icons disabled in `pubspec.yaml`). App is locked to portrait and hardcoded to light theme.

## Commands

```bash
flutter pub get                  # install deps
flutter run                      # run on connected device/emulator
flutter analyze                  # lint (uses flutter_lints via analysis_options.yaml)
flutter test                     # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter build apk                # release Android build

# Regenerate Hive adapters after changing any @HiveType model
flutter pub run build_runner build --delete-conflicting-outputs

flutter pub run flutter_launcher_icons   # regenerate launcher icons from newLogo2.png
```

`*.g.dart` files (`habit_model.g.dart`, `user_model.g.dart`) are generated — edit the source model and rerun build_runner, never edit the generated file directly.

## Architecture

Layered under `lib/`: `data/models` (Hive entities), `core/providers` + `core/services` (state & logic), `presentation/screens` + `presentation/widgets` (UI). State management is **Provider/ChangeNotifier**, wired in `main.dart`.

### Per-user data isolation (important)
Auth and data providers are connected via `ChangeNotifierProxyProvider` in `main.dart`. `AuthProvider` is the source of truth for the current user; when it changes, `HabitProvider.updateUser` and `RoutineProvider.updateUser` fire.

Each user gets their own Hive box, opened lazily on login:
- Habits: `habits_${user.id}` (typed `Box<HabitModel>`)
- Routines: `routines_${user.id}` (untyped `Box`, stores plain maps via `RoutineTask.toMap()`)

On logout (`updateUser(null)`) the box reference is dropped. Because boxes open asynchronously, providers expose `isLoading` (`_currentUserId != null && _box == null`) — UI must handle the loading window. Don't assume `_box` is non-null; every mutating method early-returns when it is null.

### Globally-opened boxes
Opened once in `main()` before `runApp`: `users` (`Box<UserModel>`), `auth_session` (`Box<String>`, holds `current_user_id` for session restore), and `language_settings` (opened by `LanguageProvider`). `AuthProvider` reads these via `Hive.box(...)` synchronously, so they must already be open.

### Models
- `HabitModel` (typeId 0) + `HabitCompletion` (typeId 1): completions are stored as a list of date-key strings; `isCompletedOn`/`toggleCompletion` operate by date key. `repeatDays` is `List<int>?` where 1=Mon..7=Sun; null/empty means every day. `HabitProvider.habits` filters by the selected weekday.
- `UserModel` (typeId 2): login is by **email OR phone**; passwords are SHA-256 hashed (`crypto`) in `AuthProvider._hashPassword`.
- `RoutineTask`: a plain Dart class (not a Hive adapter) serialized to/from `Map` — that's why the routines box is untyped.

### Notifications
`NotificationService` is a singleton, `initialize()`-d once in `main()` (sets up timezones for `zonedSchedule`). Notification IDs are derived deterministically from a string id via `id.hashCode.abs() % 100000` so a habit/routine can later be cancelled by recomputing the same id. Schedule on add/update, cancel on delete — see how habit and routine providers call it.

### Localization
There is **no .arb / intl localization**. Instead every UI string is wrapped `'text'.tr(context)` — a `String` extension in `language_provider.dart`. `LanguageProvider.translate` returns the original string immediately and, for non-`en` languages, fires an async Google Translate request (`translate.googleapis.com/translate_a/single`), caches the result in the `language_settings` box, and calls `notifyListeners()` to repaint with the translation. So translated text appears on a second frame. New user-facing strings should be wrapped in `.tr(context)`.

### Theme
`AppTheme.lightTheme` in `core/theme/app_theme.dart` is the single source for colors/typography (uses `google_fonts`). `ThemeProvider` is currently a stub that always returns light mode.
