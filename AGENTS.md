# doctro (docv1) — repository notes

Flutter telehealth app for doctors. Branch: `astra-ai-integration`.

## Commands

```bash
export PATH="/home/openhands/flutter/bin:$PATH"   # Flutter 3.47.4 stable
flutter analyze                                   # expect 0 errors, 0 warnings
flutter test                                      # 125 tests
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