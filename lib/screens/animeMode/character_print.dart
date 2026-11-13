import 'package:flutter/material.dart';
import 'package:otakuplanner/models/anime_character.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/services/anilist_service.dart';
import 'package:otakuplanner/themes/character_inks.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Step two of Anime mode: the colours read from the character's art, with
/// the planner previewed in each, and a button to print the planner in it.
///
/// Pops true when the colours were applied.
class CharacterPrint extends StatefulWidget {
  const CharacterPrint({super.key, required this.character, this.service});

  final AnimeCharacter character;
  final AniListService? service;

  @override
  State<CharacterPrint> createState() => _CharacterPrintState();
}

class _CharacterPrintState extends State<CharacterPrint> {
  late final AniListService _service = widget.service ?? AniListService();
  List<Color>? _colours;
  bool _failed = false;
  int _chosen = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _read();
  }

  Future<void> _read() async {
    setState(() {
      _colours = null;
      _failed = false;
    });
    try {
      final bytes = await _service.portraitBytes(widget.character);
      final colours = await CharacterInks.candidatesFromBytes(bytes);
      if (!mounted) return;
      // Picking the same character again starts on the colour already in use.
      final current = context.read<ThemeProvider>();
      final keep =
          current.character == widget.character && current.seed != null
              ? colours.indexWhere((c) => c.toARGB32() == current.seed!.toARGB32())
              : -1;
      setState(() {
        _colours = colours;
        _chosen = keep < 0 ? 0 : keep;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _use() async {
    final colours = _colours;
    if (colours == null || colours.isEmpty) return;
    setState(() => _saving = true);
    await context.read<ThemeProvider>().useCharacter(widget.character, colours[_chosen]);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final colours = _colours;
    final character = widget.character;
    return Scaffold(
      appBar: const InkBackBar(title: 'Anime mode'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.m, Space.page, Space.l),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CharacterPortrait(character: character, width: 104, aspectRatio: 2 / 3),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(character.name, style: context.type.headlineSmall),
                    if (character.series.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(character.series, style: context.type.bodyMedium?.copyWith(color: c.inkMuted)),
                    ],
                    const SizedBox(height: Space.m),
                    const Kicker('Colours from their art'),
                    const SizedBox(height: Space.s),
                    _swatches(colours),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.l),
          const Kicker('Preview'),
          const SizedBox(height: Space.s),
          if (colours != null && colours.isNotEmpty)
            _Preview(seed: colours[_chosen])
          else
            _PreviewPlaceholder(failed: _failed, empty: colours != null && colours.isEmpty, onRetry: _read),
          const SizedBox(height: Space.l),
          InkButton(
            label: 'Use these colours',
            expand: true,
            loading: _saving,
            onPressed: colours == null || colours.isEmpty ? null : _use,
          ),
          const SizedBox(height: Space.s),
          Text(
            'Their lines and voice come too. Switch back to Normal any time in Settings.',
            textAlign: TextAlign.center,
            style: context.type.bodySmall?.copyWith(color: c.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _swatches(List<Color>? colours) {
    final c = context.ink;
    if (colours == null) {
      return Text(
        _failed ? "Couldn't load the picture." : 'Reading the colours…',
        style: context.type.bodySmall?.copyWith(color: c.inkMuted),
      );
    }
    if (colours.isEmpty) {
      return Text('This art is too grey to take a colour from.', style: context.type.bodySmall);
    }
    return Wrap(
      spacing: Space.s,
      runSpacing: Space.s,
      children: [
        for (var i = 0; i < colours.length; i++)
          Semantics(
            button: true,
            selected: i == _chosen,
            label: 'Colour ${i + 1} of ${colours.length}',
            child: InkWell(
              onTap: () => setState(() => _chosen = i),
              borderRadius: Radii.controlAll,
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: i == _chosen ? c.ink : c.rule, width: i == _chosen ? 2.5 : Strokes.panel),
                  borderRadius: Radii.controlAll,
                ),
                child: DecoratedBox(decoration: BoxDecoration(color: colours[i], borderRadius: Radii.controlAll)),
              ),
            ),
          ),
      ],
    );
  }
}

/// A slice of the dashboard in the chosen colours, built from the real
/// widgets so it shows exactly what the planner will look like.
class _Preview extends StatelessWidget {
  const _Preview({required this.seed});

  final Color seed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = OtakuPlannerTheme.build(CharacterInks.colorsFor(seed, brightness), brightness);
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final c = context.ink;
          return Panel(
            padding: EdgeInsets.zero,
            child: ColoredBox(
              color: c.paper,
              child: Padding(
                padding: const EdgeInsets.all(Space.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [const Kicker('Today', stamped: true), const Spacer(), const Stamp('7-day streak')]),
                    const SizedBox(height: Space.xs),
                    Text('2 of 3 done', style: context.type.titleLarge),
                    const SizedBox(height: Space.s),
                    const ToneBar(value: 2 / 3),
                    const SizedBox(height: Space.s),
                    const TaskRow(title: 'Read chapter 4', category: 'Study', time: '09:00', done: true),
                    const InkRule(),
                    const TaskRow(title: 'Gym, legs', category: 'Health', time: '17:30', done: true),
                    const InkRule(),
                    const TaskRow(title: 'Watch the new episode', category: 'Leisure', time: '21:00', done: false),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.failed, required this.empty, required this.onRetry});

  final bool failed;
  final bool empty;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Panel(
      child: SizedBox(
        height: 160,
        child: Center(
          child:
              failed
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Couldn't reach AniList.", style: context.type.bodyMedium),
                      const SizedBox(height: Space.s),
                      InkButton.secondary(label: 'Try again', small: true, onPressed: onRetry),
                    ],
                  )
                  : empty
                  ? Text(
                    'Pick another character, or a different picture of this one.',
                    textAlign: TextAlign.center,
                    style: context.type.bodyMedium?.copyWith(color: c.inkMuted),
                  )
                  : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
