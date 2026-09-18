# doctro (docv1) — repository notes

Flutter telehealth app for doctors. Branch: `astra-ai-integration`.

## Commands

```bash
# Flutter 3.47.4 stable. The SDK lives in /workspace, not $HOME: the
# sandbox recycles $HOME mid-session and wipes anything installed there.
export PATH="/workspace/tools/flutter/bin:$PATH"
flutter analyze                                   # expect 0 errors, 0 warnings
flutter test                                      # 132 tests
flutter build web --release
dart format lib test
```

`flutter analyze` must stay at **0 errors / 0 warnings**. The remaining
~726 `info`s are mostly style noise (`constant_identifier_names`,
`avoid_print` in CLI scripts), not app bugs.

## CI

`build-apk.yml` runs three enforcing verification steps. Do not add
`|| true` back onto them, and do not broaden the format target back to
`.`:

| Step | Command | Fails build on |
|---|---|---|
| Verify Formatting | `dart format --output=none --set-exit-if-changed lib test` | any unformatted file in `lib`/`test` |
| Analyze Code | `flutter analyze --no-fatal-infos` | errors, warnings |
| Run Tests | `flutter test` | any failing test |

`--no-fatal-infos` is a deliberate policy, not a suppression: infos are
printed but do not fail. Everything with a real severity does. These
steps were previously suffixed with `|| true`, which is how 10 analyzer
errors went unnoticed; each gate has since been verified to fail when
handed a real error, a failing assertion, and an unformatted file.

Formatting is scoped to `lib test` on purpose. Running it over `.` also
sweeps untracked scratch and CLI scripts, which would fail the build for
files nobody committed.

## Architecture

- `lib/theme/ayureze_theme.dart` — the design system. 39 colour tokens plus
  `ThemeData` for light/dark, with a full `textTheme`.
- `lib/widgets/osler_*.dart` — shared UI kit (button, card, input, hero,
  toast, modal, skeleton, dropdown, tag, tooltip, loader, status badge).
- `lib/features/<feature>/` — screens, grouped by feature. `consultation`
  is the largest (29 files, incl. chat and video call).
- `lib/core/astra/` — the AI "Astra" integration (actions, controllers,
  services, widgets). Each folder has a barrel file.

## Layout tokens

`AyurezeTheme` has a named radius scale (`radiusXs` 6, `radiusSm` 8,
`radiusMd` 12, `radiusLg` 16, `radiusXl` 24, `radius2xl` 28, `radiusPill`
999) and a 4pt spacing scale (`spaceXs`..`space3xl`). Use these instead of
literal `BorderRadius.circular(16)` or ad-hoc `EdgeInsets`.

Before the scale existed the UI used 14 different radii with no shared
vocabulary, so two surfaces meant to match could be 12, 16 or 24
depending on who wrote them. The Osler kit was migrated to the tokens;
feature screens still largely hardcode, so expect mixed usage and
converge on the tokens when you touch a file.

## Screen layout: the kit is under-used

28 screens have a `Scaffold`. Ten of them use **zero** Osler widgets,
including `login_home` (the dashboard), `chat_page` and
`cancel_appointment` - the highest-traffic surfaces in the app. New work
on those screens should move them onto the kit rather than adding more
hand-rolled Flutter.

`profile.dart` is 2,395 lines - by far the largest file, with 52
hardcoded font sizes and 26 raw insets. Treat edits there carefully and
prefer extracting a section over growing it.

Repo-wide drift, measured: 147 hardcoded `fontSize:`, 200 raw
`EdgeInsets`, 74 `BorderRadius.circular` across 14 distinct values, 56
`Colors.white`, and only 14 literal `Color(0x..)` (low, which is the
healthy signal that the token system is followed).

## Conventions

- Use `AyurezeTheme` tokens rather than `Color(0xFF...)` literals.
  Hardcoded `Colors.white` is *not* automatically a dark-mode bug here:
  most screens open with white text on an `AyurezeTheme.heroDecoration()`
  gradient, which is correct in both themes. It is only a bug when used
  as a **surface** (card, tray, avatar background). Judging these by
  count rather than by role led to an overstated bug list once already -
  see the Dark mode section for the test that actually decides it.
- The theme defines text styles (`headlineLarge` … `labelLarge`). Prefer
  `Theme.of(context).textTheme.*` over a literal `fontSize:` — there are
  still ~108 hardcoded `fontSize` values.
- Guard `BuildContext` use after any `await` with `if (!mounted) return;`
  (or `context.mounted` in view models). This was a genuine crash source
  across the auth and video-call flows.
- Barrel files that start with a `///` doc comment need a `library;`
  directive, otherwise `dangling_library_doc_comments` fires.
- Empty `catch` blocks should keep a comment explaining why swallowing is
  correct, otherwise it reads as a bug.

## Dark mode

`AyurezeTheme` mixes two kinds of token, and picking the wrong one is the
main source of dark-mode bugs:

- **Dark-aware getters** — `surface`, `surfaceMuted`, `canvas`, `border`,
  `textPrimary`, `textSecondary`, `iconPrimary`. These read
  `_isDark` and are the correct choice for any background, border, or
  body text. `updateThemeMode()` is driven by `ThemeProvider`.
- **Light-only constants** — `lightSurface`, `healingGreen10`,
  `oslerGray10`, `lightGreenSoft`, `forestDeep`, `healingGreen100`, etc.
  These keep their light value in dark mode. They are fine as *brand
  accents* (a badge, an icon on a pale chip) but wrong as a page or card
  background, where they strand pale fills behind themed text.

Where such a fill already carries the accent 100 shade as foreground
(`healingGreen100` on `healingGreen10` is 14:1), the pairing is
intentional and readable in both modes — leave it alone. It only breaks
when the foreground is a *dark-aware* text token, because then the
foreground flips and the background does not.

`Colors.white` as a foreground is usually correct here: most feature
screens open with white text on an `AyurezeTheme.heroDecoration()`
gradient. Only treat it as a bug when it is a **surface** colour (a card,
tray, or avatar background), where it produces white-on-white in dark
mode.

### White content on a green fill

Use `healingGreenFill` (not `healingGreen50`) whenever a filled control
carries a white glyph or label: FAB, checkbox, circular play/AI/record
buttons, success discs. `healingGreen50` is the brand emerald but reaches
only 2.54:1 against white, which fails WCAG AA (4.5:1) and even the 3:1
UI-component threshold, and it fails in *both* modes. `healingGreenFill`
is the same hue at 5.48:1.

`healingGreen50` remains correct as a bare accent: an icon or border on a
neutral surface, or the 10%-alpha tint used behind an idle control.

Accent-on-tint pairs follow a shade 10 background with a shade 100
foreground (`healingGreen10`/`healingGreen100` and the equivalents for
red, yellow, blue, violet). Those pairings are all 13:1 or better and are
the intended pattern; the contrast test covers them.

Body text must clear WCAG AA (4.5:1) on its surface.
`test/theme/theme_contrast_test.dart` enforces this for the theme's text
and surface tokens using a self-contained contrast-ratio helper; add a
case there when introducing a new text/surface pair. `darkTextSecondary`
is `#B4B4B4` rather than `#A0A0A0` because the latter scored only 4.15:1
on `darkSurfaceMuted`.

## Testing notes

- Widgets that depend on wall-clock time take an injectable clock rather
  than calling `DateTime.now()` inline, so behavior is deterministic in
  tests (see `lib/widgets/session_timeout_handler.dart`).
- Parse/transform logic belongs in a pure function or factory (e.g.
  `UserChat.fromMap`) so it can be unit-tested without Firestore. Do not
  implement `DocumentSnapshot` in a test — it is a sealed class and the
  analyzer flags it.
- **Screen size comes from `tester.view`, not `setSurfaceSize`.**
  `tester.view.physicalSize` (with `devicePixelRatio`) is what drives
  `MediaQuery`; `setSurfaceSize` leaves it at the default 800x600, so a
  width-dependent layout bug silently cannot reproduce. Always pair them
  with `addTearDown(tester.view.resetPhysicalSize)`.
- **One `testWidgets` per file per app boot.** Booting a `MaterialApp`
  with an async `LocalizationsDelegate` works in the first `testWidgets`
  of a file and silently builds *no child* in the rest, so assertions
  see an empty tree. Re-pump at different sizes inside one test body
  instead of adding more `testWidgets`.
- The `_locale == null` branch in `main.dart` is unreachable (`_locale`
  is initialised to `en_US`); it is defensive only. It must return
  `ColoredBox`, never a bare `SizedBox`: with no `Material` or
  `Directionality` ancestor it has nothing to paint.

## Build configuration

All runtime configuration resolves through `Env` in `lib/core/config/env.dart`.
Never read `dotenv` or `String.fromEnvironment` directly elsewhere; add a getter
to `Env` instead, so there is one precedence rule rather than several.

Precedence is `--dart-define` first, then `.env`, then empty string. The
resolver never throws, because it is called on release paths where `dotenv.load`
has not run.

`.env` is deliberately NOT declared under `assets:` in pubspec.yaml. Adding it
would ship the file inside every APK, where it can be extracted from the bundle.
It is loaded in debug builds only. For local work that matches a release build,
use `flutter run --dart-define-from-file=.env.json`; that file is gitignored.

Keys split into two groups:

- Required and public by design: `SUPABASE_URL`, `SUPABASE_ANON_KEY`,
  `FIREBASE_API_KEY`. Safe to embed; they identify the project rather than
  authorising anything on their own. Missing values are reported once at
  startup by `Env.missingKeys()`.
- Server authority, must not ship in a client build: `FIREBASE_SERVER_KEY`,
  `ASTRA_API_KEY`, `SARVAM_API_KEY`. `--dart-define` embeds values in the
  binary and they are recoverable from a release APK. The legacy FCM server key
  can push to every device in the project. Do not add these to the CI build
  step; move the calls that need them to the backend.

CI (`build-apk.yml`) passes only the public keys. If you add a new key, decide
which group it belongs to before wiring it up.

`test/core/env_test.dart` asserts behavior under both configured and
unconfigured builds, so CI runs the suite twice (see the two "Run Tests"
steps). Adding a test that only makes sense in one mode will fail the other;
branch on `String.fromEnvironment` in the test instead.

## Startup flow

The app has no opening or splash screen. `main()` initializes
`SharedPreferences` before `runApp`, and `StartupGate`
(`lib/features/startup_gate.dart`) reads `Preferences.is_logged_in`
synchronously to pick the first screen: `LoginHomeScreen` when a session is
stored, `SignIn` otherwise. There is no delay and no branding screen.

Two things to keep true if you touch this:

- Do not add a timer or an `await` before the destination is chosen. The gate is
  meant to render the real screen on the first frame.
- The native launch window (Android `launch_background.xml`, iOS
  `LaunchScreen.storyboard`) paints a flat background only. `flutter_native_splash`
  and its config were removed, so re-adding the package would reintroduce a
  branded launch screen.
