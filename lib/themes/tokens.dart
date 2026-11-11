
import 'package:flutter/material.dart';

/// The whole look of the app in one place: ink on paper.
///
/// Navy ink is the only colour for text and lines. One vermilion, taken from
/// the "today" cell in the logo, works like a hanko stamp and marks only
/// today, the streak and the active tab. Fills are screentone patterns
/// (see `widgets/screentone.dart`), never extra colours.
class Palette {
  Palette._();

  // Light: cream paper, navy ink.
  static const Color paper = Color(0xFFFCF2E8);
  static const Color navy = Color(0xFF1C384E);

  /// Hanko vermilion on paper. Same hue as the logo's today cell, deep
  /// enough to read as text on cream (4.6:1).
  static const Color vermilion = Color(0xFFC2412C);

  // Dark: the page turns to night and the ink to cream.
  static const Color night = Color(0xFF111C27);
  static const Color cream = Color(0xFFF3E6D6);

  /// The logo's today cell exactly; reads at 6.3:1 on night.
  static const Color vermilionOnNight = Color(0xFFEF7A69);
}

/// Colours for the current brightness. Read them with `context.ink`.
@immutable
class PlannerColors extends ThemeExtension<PlannerColors> {
  const PlannerColors({
    required this.paper,
    required this.ink,
    required this.stamp,
  });

  /// The page.
  final Color paper;

  /// Text, borders, icons and solid fills.
  final Color ink;

  /// Hanko vermilion: today, the streak and the active tab. Nothing else.
  final Color stamp;

  /// Secondary text: the same ink, lighter.
  Color get inkMuted => ink.withValues(alpha: 0.66);

  /// Hairlines between rows inside a panel.
  Color get rule => ink.withValues(alpha: 0.22);

  /// Text and icons on a solid ink or stamp fill.
  Color get onInk => paper;

  static const light = PlannerColors(
    paper: Palette.paper,
    ink: Palette.navy,
    stamp: Palette.vermilion,
  );

  static const dark = PlannerColors(
    paper: Palette.night,
    ink: Palette.cream,
    stamp: Palette.vermilionOnNight,
  );

  @override
  PlannerColors copyWith({Color? paper, Color? ink, Color? stamp}) =>
      PlannerColors(
        paper: paper ?? this.paper,
        ink: ink ?? this.ink,
        stamp: stamp ?? this.stamp,
      );

  @override
  PlannerColors lerp(PlannerColors? other, double t) {
    if (other == null) return this;
    return PlannerColors(
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      stamp: Color.lerp(stamp, other.stamp, t)!,
    );
  }
}

/// Corners: panels are cut, not rounded.
class Radii {
  Radii._();

  /// Buttons, fields, stamps, segments.
  static const double control = 2;

  /// Panels and dialogs.
  static const double panel = 4;

  static const BorderRadius controlAll = BorderRadius.all(Radius.circular(control));
  static const BorderRadius panelAll = BorderRadius.all(Radius.circular(panel));
}

/// Line weights.
class Strokes {
  Strokes._();

  /// Panel borders, buttons, fields.
  static const double panel = 1.5;

  /// Rules between rows.
  static const double hairline = 1;
}

/// Spacing. The gutter between panels is always 12.
class Space {
  Space._();

  static const double xs = 4;
  static const double s = 8;
  static const double gutter = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;

  /// Left and right edge of every page.
  static const double page = 16;
}

/// The type scale. Poppins only; headings are set tight.
///
/// Use these through `context.type` (the app's [TextTheme]):
/// - `displaySmall`  page titles and the greeting (26, bold, tight)
/// - `titleLarge`    panel titles (18, semibold)
/// - `titleMedium`   row titles, button labels (15, medium)
/// - `bodyMedium`    body text (14)
/// - `bodySmall`     meta lines under a row (12)
/// - `labelSmall`    the one uppercase label ("TODAY · SAT 1 NOV"); use
///                   the `Kicker` widget so it is always uppercase.
/// - [stat]          numbers in stats, with tabular figures.
class TypeScale {
  TypeScale._();

  static const String family = 'Poppins';

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme(Color ink) {
    final muted = ink.withValues(alpha: 0.66);
    return TextTheme(
      displaySmall: TextStyle(
        fontFamily: family,
        fontSize: 26,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: ink,
      ),
      headlineSmall: TextStyle(
        fontFamily: family,
        fontSize: 22,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontFamily: family,
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        color: ink,
      ),
      titleSmall: TextStyle(
        fontFamily: family,
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: family,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodySmall: TextStyle(
        fontFamily: family,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: family,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      labelMedium: TextStyle(
        fontFamily: family,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      labelSmall: TextStyle(
        fontFamily: family,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.3,
        color: muted,
      ),
    );
  }

  /// Big numbers in stats: tabular so they don't jump.
  static TextStyle stat(Color ink) => TextStyle(
        fontFamily: family,
        fontSize: 24,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: ink,
        fontFeatures: tabular,
      );
}

extension PlannerTheme on BuildContext {
  /// Paper, ink and stamp for the current brightness.
  PlannerColors get ink => Theme.of(this).extension<PlannerColors>()!;

  /// The type scale (see [TypeScale]).
  TextTheme get type => Theme.of(this).textTheme;
}
