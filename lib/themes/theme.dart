import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';

export 'package:otakuplanner/themes/tokens.dart';

/// Builds the light and dark themes from the tokens, so stock widgets
/// (dialogs, fields, pickers, snack bars, switches) already look like the
/// rest of the app.
class OtakuPlannerTheme {
  OtakuPlannerTheme._();

  static final ThemeData lightTheme = build(PlannerColors.light, Brightness.light);
  static final ThemeData darkTheme = build(PlannerColors.dark, Brightness.dark);

  /// A full theme from paper, ink and stamp. Anime mode builds one from a
  /// character's colours.
  static ThemeData build(PlannerColors c, Brightness brightness) {
    final ink = c.ink;
    final paper = c.paper;
    final text = TypeScale.textTheme(ink);
    final panelBorder = BorderSide(color: ink, width: Strokes.panel);
    final fieldBorder = OutlineInputBorder(
      borderRadius: Radii.controlAll,
      borderSide: BorderSide(color: ink, width: Strokes.panel),
    );
    final focusBorder = fieldBorder.copyWith(borderSide: BorderSide(color: ink, width: 2.5));
    const buttonShape = RoundedRectangleBorder(borderRadius: Radii.controlAll);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: ink,
      onPrimary: paper,
      secondary: ink,
      onSecondary: paper,
      tertiary: ink,
      onTertiary: paper,
      error: ink,
      onError: paper,
      surface: paper,
      onSurface: ink,
      onSurfaceVariant: c.inkMuted,
      surfaceContainerLowest: paper,
      surfaceContainerLow: paper,
      surfaceContainer: paper,
      surfaceContainerHigh: paper,
      surfaceContainerHighest: paper,
      outline: ink,
      outlineVariant: c.rule,
      primaryContainer: paper,
      onPrimaryContainer: ink,
      secondaryContainer: ink,
      onSecondaryContainer: paper,
      shadow: Colors.transparent,
      scrim: ink.withValues(alpha: 0.35),
      surfaceTint: Colors.transparent,
      inverseSurface: ink,
      onInverseSurface: paper,
    );

    WidgetStateColor selected(Color on, Color off) =>
        WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? on : off);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: TypeScale.family,
      colorScheme: scheme,
      textTheme: text,
      extensions: [c],
      scaffoldBackgroundColor: paper,
      canvasColor: paper,
      cardColor: paper,
      dividerColor: c.rule,
      shadowColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      splashColor: ink.withValues(alpha: 0.08),
      highlightColor: ink.withValues(alpha: 0.05),
      hoverColor: ink.withValues(alpha: 0.04),
      iconTheme: IconThemeData(color: ink, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: ink),
        actionsIconTheme: IconThemeData(color: ink),
        shape: Border(bottom: panelBorder),
      ),
      dividerTheme: DividerThemeData(color: c.rule, thickness: Strokes.hairline, space: 1),
      cardTheme: CardThemeData(
        color: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: Radii.panelAll, side: panelBorder),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: Radii.panelAll, side: panelBorder),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
        barrierColor: ink.withValues(alpha: 0.35),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: paper,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.panel)),
          side: panelBorder,
        ),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: paper),
        actionTextColor: paper,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Radii.controlAll),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paper,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintStyle: text.bodyMedium?.copyWith(color: c.inkMuted),
        labelStyle: text.bodyMedium?.copyWith(color: c.inkMuted),
        floatingLabelStyle: text.bodySmall?.copyWith(color: ink, fontWeight: FontWeight.w600),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall?.copyWith(color: ink, fontWeight: FontWeight.w600),
        prefixIconColor: ink,
        suffixIconColor: ink,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: focusBorder,
        errorBorder: fieldBorder,
        focusedErrorBorder: focusBorder,
        disabledBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: c.rule, width: Strokes.panel),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ink,
        selectionColor: ink.withValues(alpha: 0.2),
        selectionHandleColor: ink,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: paper,
          disabledBackgroundColor: c.rule,
          disabledForegroundColor: c.inkMuted,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: buttonShape,
          minimumSize: const Size(64, 44),
          textStyle: text.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: paper,
          shape: buttonShape,
          minimumSize: const Size(64, 44),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: panelBorder,
          shape: buttonShape,
          minimumSize: const Size(64, 44),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ink),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ink,
        foregroundColor: paper,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: Radii.controlAll),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: Radii.controlAll),
        side: BorderSide(color: ink, width: Strokes.panel),
        fillColor: selected(ink, Colors.transparent),
        checkColor: WidgetStatePropertyAll(paper),
        overlayColor: WidgetStatePropertyAll(ink.withValues(alpha: 0.08)),
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStatePropertyAll(ink)),
      switchTheme: SwitchThemeData(
        thumbColor: selected(paper, ink),
        trackColor: selected(ink, paper),
        trackOutlineColor: WidgetStatePropertyAll(ink),
        trackOutlineWidth: const WidgetStatePropertyAll(Strokes.panel),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ink,
        linearTrackColor: c.rule,
        circularTrackColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: ink,
        textColor: ink,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: Radii.panelAll, side: panelBorder),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(paper),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: Radii.panelAll, side: panelBorder),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: text.bodyMedium,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(paper),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: Radii.panelAll, side: panelBorder),
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: Radii.panelAll, side: panelBorder),
        headerBackgroundColor: paper,
        headerForegroundColor: ink,
        dividerColor: ink,
        dayForegroundColor: selected(paper, ink),
        dayBackgroundColor: selected(ink, Colors.transparent),
        todayForegroundColor: selected(paper, c.stamp),
        todayBackgroundColor: selected(ink, Colors.transparent),
        todayBorder: BorderSide(color: c.stamp, width: Strokes.panel),
        dayShape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Radii.controlAll),
        ),
        yearForegroundColor: selected(paper, ink),
        yearBackgroundColor: selected(ink, Colors.transparent),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: ink),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: ink),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: paper,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: Radii.panelAll, side: panelBorder),
        hourMinuteShape: RoundedRectangleBorder(borderRadius: Radii.controlAll, side: panelBorder),
        hourMinuteColor: selected(ink, paper),
        hourMinuteTextColor: selected(paper, ink),
        dayPeriodShape: const RoundedRectangleBorder(borderRadius: Radii.controlAll),
        dayPeriodBorderSide: panelBorder,
        dayPeriodColor: selected(ink, paper),
        dayPeriodTextColor: selected(paper, ink),
        dialBackgroundColor: ink.withValues(alpha: 0.06),
        dialHandColor: ink,
        dialTextColor: selected(paper, ink),
        entryModeIconColor: ink,
        helpTextStyle: text.labelSmall,
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: ink),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: ink),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: ink, borderRadius: Radii.controlAll),
        textStyle: text.bodySmall?.copyWith(color: paper),
      ),
    );
  }
}
