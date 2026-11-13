import 'package:flutter/material.dart';
import 'package:otakuplanner/models/anime_character.dart';
import 'package:otakuplanner/shared/notifications.dart' show rootScaffoldMessengerKey;
import 'package:otakuplanner/shared/quote_service.dart';
import 'package:otakuplanner/themes/tokens.dart';
import 'package:otakuplanner/widgets/character_portrait.dart';

/// Anime mode's reminders and celebrations: the character's portrait, what
/// happened, and one of their own lines, as a snack bar.
class CharacterToast {
  CharacterToast._();

  static void show({required AnimeCharacter character, required String kicker, required String headline, Quote? line}) {
    rootScaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: line == null ? 3 : 6),
          padding: const EdgeInsets.all(Space.gutter),
          content: CharacterToastBody(character: character, kicker: kicker, headline: headline, line: line),
        ),
      );
  }
}

class CharacterToastBody extends StatelessWidget {
  const CharacterToastBody({
    super.key,
    required this.character,
    required this.kicker,
    required this.headline,
    this.line,
  });

  final AnimeCharacter character;
  final String kicker;
  final String headline;
  final Quote? line;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final quote = line;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // On the solid ink of a snack bar the frame is paper.
          Theme(
            data: Theme.of(context).copyWith(extensions: [c.copyWith(ink: c.paper, paper: c.ink)]),
            child: CharacterPortrait(character: character, width: 44, aspectRatio: 2 / 3),
          ),
          const SizedBox(width: Space.gutter),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker.toUpperCase(),
                  style: context.type.labelSmall?.copyWith(
                    color: c.paper.withValues(alpha: 0.75),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(headline, style: context.type.titleSmall?.copyWith(color: c.paper, fontWeight: FontWeight.w700)),
                if (quote != null) ...[
                  const SizedBox(height: Space.xs),
                  Text('“${quote.text}”', style: context.type.bodyMedium?.copyWith(color: c.paper)),
                  Text(
                    quote.character,
                    style: context.type.bodySmall?.copyWith(color: c.paper.withValues(alpha: 0.75)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
