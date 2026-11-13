import 'package:flutter/material.dart';
import 'package:otakuplanner/models/anime_character.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/themes/tokens.dart';
import 'package:provider/provider.dart';

/// The character speaking in Anime mode, or null in Normal mode. Widgets
/// that call this from build rebuild when the mode or character changes;
/// pass `listen: false` from callbacks.
AnimeCharacter? speakingCharacter(BuildContext context, {bool listen = true}) {
  try {
    final theme = Provider.of<ThemeProvider>(context, listen: listen);
    return theme.isAnime ? theme.character : null;
  } on ProviderNotFoundException {
    return null;
  }
}

/// A character's portrait in an ink frame, like a small manga panel. Shows
/// the first letter of their name while loading or offline.
class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({
    super.key,
    required this.character,
    this.width = 48,
    this.aspectRatio = 1,
    this.strokeWidth = Strokes.panel,
  });

  final AnimeCharacter character;
  final double width;

  /// Width over height. AniList portraits are 2:3; square crops to the face.
  final double aspectRatio;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final initial = Center(
      child: Text(
        character.name.isEmpty ? '?' : character.name.characters.first.toUpperCase(),
        style: context.type.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
    return Semantics(
      image: true,
      label: character.name,
      child: Container(
        width: width,
        height: width / aspectRatio,
        decoration: BoxDecoration(
          color: c.paper,
          border: Border.all(color: c.ink, width: strokeWidth),
          borderRadius: Radii.controlAll,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          character.imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => initial,
          frameBuilder: (_, child, frame, wasSync) => wasSync || frame != null ? child : initial,
        ),
      ),
    );
  }
}
