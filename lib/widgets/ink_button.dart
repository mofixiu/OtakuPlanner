import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';

enum InkButtonStyle {
  /// Solid ink, paper text. One per screen.
  primary,

  /// Ink outline.
  secondary,

  /// Text only, for low-stakes actions like "Cancel".
  quiet,
}

/// The app's only button. Replaces the old CustomButton, CircleButton,
/// RounderButton, Tustom and their icon/small-text copies.
class InkButton extends StatelessWidget {
  const InkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = InkButtonStyle.primary,
    this.icon,
    this.expand = false,
    this.small = false,
    this.loading = false,
  });

  const InkButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.small = false,
    this.loading = false,
  }) : style = InkButtonStyle.secondary;

  const InkButton.quiet({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.small = false,
    this.loading = false,
  }) : style = InkButtonStyle.quiet;

  final String label;

  /// Null shows the button disabled.
  final VoidCallback? onPressed;
  final InkButtonStyle style;
  final IconData? icon;

  /// Fill the available width.
  final bool expand;

  /// 36px tall instead of 48.
  final bool small;

  /// Shows a small ink spinner in place of the label and ignores taps.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final enabled = onPressed != null && !loading;
    final solid = style == InkButtonStyle.primary;
    // A disabled button keeps its outline but loses its ink: faint rule and
    // muted text, the same on cream and on night. A loading one stays solid.
    final inked = enabled || loading;
    final fg = solid && inked ? c.paper : (inked ? c.ink : c.inkMuted);
    final bg = solid && inked ? c.ink : Colors.transparent;
    final border = style == InkButtonStyle.quiet
        ? BorderSide.none
        : BorderSide(color: inked ? c.ink : c.rule, width: Strokes.panel);
    final textStyle = (small ? context.type.labelMedium : context.type.labelLarge)?.copyWith(
      color: fg,
      fontWeight: FontWeight.w600,
    );

    Widget content = loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: small ? 16 : 18, color: textStyle?.color),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    final button = Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: Radii.controlAll, side: border),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        child: Container(
          constraints: BoxConstraints(minHeight: small ? 36 : 48, minWidth: small ? 36 : 64),
          padding: EdgeInsets.symmetric(horizontal: small ? 12 : 18),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? '$label, working' : null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// A square icon button with an ink outline, for app bars and rows.
class InkIconButton extends StatelessWidget {
  const InkIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 36,
    this.outlined = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.controlAll,
          side: outlined ? BorderSide(color: c.ink, width: Strokes.panel) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.5, color: c.ink, semanticLabel: tooltip),
          ),
        ),
      ),
    );
  }
}
