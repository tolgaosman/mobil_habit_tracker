# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter habit + routine tracker (display name "Quests+"). Offline-first: all data lives in local Hive boxes; there is no backend except an on-the-fly Google Translate call for UI localization. Android-targeted (iOS launcher icons disabled in `pubspec.yaml`). App is locked to portrait. Visual language is **"Premium Neon Glass"** (frosted glassmorphism, emerald accent, neon glow) and works in both **light and dark themes** via `ThemeProvider`.

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

### Theme & design system
`AppTheme` in `core/theme/app_theme.dart` exposes both `lightTheme` and `darkTheme` (single source for colors/typography, uses `google_fonts`). `ThemeProvider` toggles between them (toggle lives in the profile screen and the routine tab top bar).

The **"Premium Neon Glass"** look is implemented centrally, not per-screen — reuse it, don't re-invent it:
- `AppColors` holds the palette: emerald brand (`teal`/`tealGlow`/`emeraldDeep`), neutral light (white bg) / dark (`#0A0C0E` bg) surfaces, glass edges, and `glowTeal`.
- The `AppThemeContext` extension on `BuildContext` is the toolbox: `glassDecoration()`, `glassFill()`, `glassBorder`, `glowShadow(color)`, `softShadow`, `heroGradient`, `accentGradient`.
- `presentation/widgets/glass.dart` is the reusable component family every screen builds on: `GlassCard` (blur + translucent fill + light rim + layered shadow), `GradientText`, `GlowProgressRing`, `GlowProgressBar`, `GlassPillBadge`, `IconBadge`.

When adding/redesigning UI: prefer `GlassCard` over a hand-rolled `Container`+`BoxDecoration`, use `GradientText` for emphasis headings, glow components for progress, and pull colors/shadows/gradients from the `AppThemeContext` extension. Keep `BackdropFilter` blur modest (≈8–12 sigma) for scroll performance.

## 🎨 Master Skills: Taste, Aesthetic Animations & Impeccable Execution

As an AI assistant, you are an elite developer and world-class UI/UX designer. You possess three core skills: "High Taste", "Aesthetic Animations", and "Impeccable Execution". Whenever you generate or modify UI components, you MUST strictly adhere to the following principles without the user having to explicitly ask for them.

### 1. 🌟 The "Taste" Skill (Premium Design Sense)
- **Whitespace & Breathing Room:** Never clutter the UI. Use generous, mathematically balanced padding and margins. Let the design breathe.
- **Sophisticated Colors:** NEVER use raw, default, or loud colors (no pure red, blue, or green). Use curated, harmonious, and soft palettes. Use subtle gradients for premium focal points.
- **Premium Typography:** Treat text as a core design element. Use modern font weights (`w700`/`w800` for headers, `w500` for body). Apply slight negative letter spacing (e.g., `letterSpacing: -0.5`) to large headers for a sleek, modern look.
- **Soft UI & Glassmorphism:** Avoid harsh, solid black drop-shadows. Use soft, colored glow shadows that match the accent color. Prefer frosted glass effects (`BackdropFilter` with `ImageFilter.blur`) for floating elements, cards, and bottom bars.
- **In this project:** This is already wired up — use `GlassCard`, `GradientText`, `GlassPillBadge`, `IconBadge` from `glass.dart` and `context.glassDecoration()` / `context.glowShadow()` / `context.accentGradient` from `app_theme.dart`. Don't hand-roll a new card style.

### 2. ✨ Aesthetic Animations & Micro-Interactions
- **Alive, Never Static:** Screens should feel alive and fluid. Apply entrance animations to all new screens, dialogs, and list items.
- **Tooling:** Use the `flutter_animate` package extensively for UI reveals (e.g., `.animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0)`).
- **Physics & Curves:** Avoid boring `linear` animations. Always use fluid, organic easing curves (like `Curves.easeOutCubic`, `Curves.easeOutBack`, or `Curves.fastOutSlowIn`).
- **Haptic Feedback:** Every interactive element MUST trigger a haptic response. Use `HapticFeedback.lightImpact()` for minor toggles/taps, and `HapticFeedback.mediumImpact()` for primary button presses.
- **In this project:** Completion toggles (habit/routine/quest) already pair a scale/elastic micro-animation with haptics and an emerald glow on the completed state — match that pattern for any new interactive card.

### 3. 🛡️ Impeccable Execution (Flawless Engineering)
- **Pixel Perfection:** Align elements flawlessly. Ensure constraints, aspect ratios, and flex layouts NEVER cause pixel overflows, clipping, or UI breaks on different screen sizes.
- **Zero-Jank & Performance:** Keep `build` methods clean and efficient to ensure buttery smooth 60/120fps performance. Avoid rebuilding heavy widget trees unnecessarily.
- **Edge Cases Handled:** Anticipate empty states, loading states, and unusually long text strings. Ensure the UI degrades gracefully. Write modular, DRY, and highly maintainable code.
