import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_typography.dart';

/// Design system tokens for the Live Screen V3 ("Storybook UX").
///
/// Composed from the app's existing typography surface ([AppTypography])
/// rather than introducing a new font dependency. The "storybook display feel"
/// comes from weight, size, and tracking tuning — not a new typeface.
///
/// **Scope:** Currently scoped to the Live screen revamp. Other screens keep
/// using [AppColors] / [AppTypography] until a separate sprint propagates the
/// design system app-wide.
///
/// See `docs/live-screen-v3-audit.md` and the plan for context.
class DoraTheme {
  DoraTheme._();
}

/// Semantic color tokens — each role has its own color, no monochrome.
///
/// Brand = teal/mint. Warn = amber. Advisory = purple. Each token has one job.
class DoraColors {
  DoraColors._();

  // Brand
  static const Color brandPrimary = Color(0xFF0EA5A0);
  static const Color brandAccent = Color(0xFF5EEAD4);

  // Surfaces
  static const Color surfaceCream = Color(0xFFFFF4E6);
  static const Color surfaceMint = Color(0xFFF0FDFA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Ink
  static const Color inkPrimary = Color(0xFF0F2A2E);
  static const Color inkSecondary = Color(0xFF5A716E);
  static const Color inkTertiary = Color(0xFF8FA3A0);

  // Semantic — each has a distinct role on the map
  static const Color warn = Color(0xFFFB923C); // amber — warn pin, pulse ring
  static const Color advisory = Color(0xFF7C3AED); // purple — Dora speech, ambient advisory
  static const Color success = Color(0xFF22C55E); // green — saved confirmations
  static const Color info = brandPrimary; // teal — info messages

  // Shadow color (low-opacity ink)
  static const Color shadow = Color(0x14000000); // 8% black
}

/// Spacing tokens — 4-pt grid.
class DoraSpacing {
  DoraSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Border radius tokens.
class DoraRadius {
  DoraRadius._();

  static const Radius card = Radius.circular(24);
  static const Radius chip = Radius.circular(16);
  static const Radius pill = Radius.circular(999);
  static const Radius small = Radius.circular(8);

  static const BorderRadius cardAll = BorderRadius.all(card);
  static const BorderRadius chipAll = BorderRadius.all(chip);
  static const BorderRadius pillAll = BorderRadius.all(pill);
}

/// Soft elevation shadows. Single shadow recipe; depth comes from blur, not stacking.
class DoraShadow {
  DoraShadow._();

  /// Default soft shadow — used on cards, callouts, floating chrome.
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: DoraColors.shadow,
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  /// Tighter shadow for smaller elements (pills, chips).
  static const List<BoxShadow> tight = [
    BoxShadow(
      color: DoraColors.shadow,
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}

/// Typography presets composed from [AppTypography].
///
/// Display variants tune size + weight + tracking on the existing SF Pro
/// Display font for the storybook feel. No new font dependency.
class DoraTypography {
  DoraTypography._();

  // ── Display: Dora speech bubbles, big surface titles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.2,
    color: DoraColors.inkPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.15,
    color: DoraColors.inkPrimary,
  );

  // Speech-bubble headline — slightly looser tracking, friendly weight
  static const TextStyle bubble = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.1,
    color: DoraColors.inkPrimary,
  );

  // ── Body
  static const TextStyle body = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DoraColors.inkPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DoraColors.inkSecondary,
  );

  // ── Callout / chip / time-ago
  static const TextStyle callout = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: DoraColors.inkPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: DoraColors.inkSecondary,
  );

  // ── Labels (chips, button text)
  static const TextStyle label = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
    color: DoraColors.inkPrimary,
  );
}

/// Motion vocabulary — only these 4 across the live screen.
///
/// Each motion has a single role. Don't reach for other curves/durations
/// — consistency is what makes the experience feel coherent.
class DoraMotion {
  DoraMotion._();

  // Reveal — slide up + fade. Used by entrances of bubbles, cards, callouts.
  static const Curve revealCurve = Curves.easeOutCubic;
  static const Duration reveal = Duration(milliseconds: 400);

  // Emphasis — scale 1.0 -> 1.05 -> 1.0 with overshoot. Used by "Dora has
  // something for you" moments (pill pulse, capture confirmation).
  static const Curve emphasisCurve = Curves.easeInOutBack;
  static const Duration emphasis = Duration(milliseconds: 600);

  // Dismiss — slide down + fade. Used by exits.
  static const Curve dismissCurve = Curves.easeInCubic;
  static const Duration dismiss = Duration(milliseconds: 250);

  // Camera fly — used by Mapbox flyTo / easeTo for cinematic camera moves.
  static const Curve cameraCurve = Curves.easeInOutQuart;
  static const Duration cameraFly = Duration(milliseconds: 800);
}
