import 'dart:math' as math;

import 'package:doctro/theme/ayureze_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 relative luminance for an sRGB colour.
double _luminance(double r, double g, double b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4) as double;
  return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
}

/// WCAG contrast ratio between two opaque colours, 1.0 .. 21.0.
double contrastRatio(int a, int b) {
  double lum(int argb) => _luminance(
        ((argb >> 16) & 0xFF) / 255,
        ((argb >> 8) & 0xFF) / 255,
        (argb & 0xFF) / 255,
      );
  final double la = lum(a);
  final double lb = lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('WCAG helper', () {
    test('black on white is the maximum 21:1', () {
      expect(contrastRatio(0xFF000000, 0xFFFFFFFF), closeTo(21.0, 0.01));
    });

    test('a colour against itself is 1:1', () {
      expect(contrastRatio(0xFF3D3D3D, 0xFF3D3D3D), closeTo(1.0, 0.001));
    });
  });

  group('body text meets WCAG AA (4.5:1) on its surface', () {
    test('light theme primary text', () {
      expect(
        contrastRatio(
          AyurezeTheme.lightTextPrimary.toARGB32(),
          AyurezeTheme.lightSurface.toARGB32(),
        ),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('light theme secondary text on both light surfaces', () {
      for (final int surface in [
        AyurezeTheme.lightSurface.toARGB32(),
        AyurezeTheme.lightSurfaceMuted.toARGB32(),
      ]) {
        expect(
          contrastRatio(AyurezeTheme.lightTextSecondary.toARGB32(), surface),
          greaterThanOrEqualTo(4.5),
          reason: 'lightTextSecondary is unreadable on surface $surface',
        );
      }
    });

    test('dark theme primary text', () {
      expect(
        contrastRatio(
          AyurezeTheme.darkTextPrimary.toARGB32(),
          AyurezeTheme.darkSurface.toARGB32(),
        ),
        greaterThanOrEqualTo(4.5),
      );
    });

    // Regression guard: darkTextSecondary was #A0A0A0, which scored only
    // 4.15:1 on darkSurfaceMuted and failed AA.
    test('dark theme secondary text on both dark surfaces', () {
      for (final int surface in [
        AyurezeTheme.darkSurface.toARGB32(),
        AyurezeTheme.darkSurfaceMuted.toARGB32(),
      ]) {
        expect(
          contrastRatio(AyurezeTheme.darkTextSecondary.toARGB32(), surface),
          greaterThanOrEqualTo(4.5),
          reason: 'darkTextSecondary is unreadable on surface $surface',
        );
      }
    });
  });
}
