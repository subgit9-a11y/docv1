# doctro (docv1) — repository notes

Flutter telehealth app for doctors. Branch: `astra-ai-integration`.

## Commands

```bash
export PATH="/home/openhands/flutter/bin:$PATH"   # Flutter 3.47.4 stable
flutter analyze                                   # expect 0 errors, 0 warnings
flutter test                                      # 119 tests
flutter build web --release
dart format lib/
```

`flutter analyze` must stay at **0 errors / 0 warnings**. The remaining
~726 `info`s are mostly style noise (`constant_identifier_names`,
`avoid_print` in CLI scripts), not app bugs.

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

- Use `AyurezeTheme` tokens, never `Colors.white` / `Color(0xFF...)`
  literal. Hardcoded white is the usual cause of white-on-white text in
  dark mode; there were real bugs of this kind in chat.
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