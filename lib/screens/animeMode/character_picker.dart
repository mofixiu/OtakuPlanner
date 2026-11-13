import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otakuplanner/models/anime_character.dart';
import 'package:otakuplanner/screens/animeMode/character_print.dart';
import 'package:otakuplanner/services/anilist_service.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';

/// Step one of Anime mode: find a character on AniList. With nothing typed
/// it shows the characters people favourite most.
///
/// Returns true when a character's colours were applied.
class CharacterPicker extends StatefulWidget {
  const CharacterPicker({super.key, this.service});

  final AniListService? service;

  @override
  State<CharacterPicker> createState() => _CharacterPickerState();
}

class _CharacterPickerState extends State<CharacterPicker> {
  late final AniListService _service = widget.service ?? AniListService();
  final _search = TextEditingController();
  Timer? _debounce;
  List<AnimeCharacter> _results = const [];
  bool _loading = true;
  bool _failed = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    // AniList allows 30 requests a minute, so wait for a pause in typing.
    _debounce = Timer(const Duration(milliseconds: 450), () => _load(text));
  }

  Future<void> _load(String query) async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final results = await _service.characters(search: query);
      if (!mounted || request != _request) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _choose(AnimeCharacter character) async {
    final applied = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CharacterPrint(character: character, service: _service)),
    );
    if (applied == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final query = _search.text.trim();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const InkBackBar(title: 'Anime mode'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.m, Space.page, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pick a character', style: context.type.headlineSmall),
                  const SizedBox(height: Space.xs),
                  Text(
                    'The planner takes their colours, their lines and their voice.',
                    style: context.type.bodyMedium?.copyWith(color: c.inkMuted),
                  ),
                  const SizedBox(height: Space.m),
                  TextField(
                    controller: _search,
                    onChanged: _onChanged,
                    onSubmitted: _load,
                    textInputAction: TextInputAction.search,
                    autocorrect: false,
                    decoration: const InputDecoration(hintText: 'Search by name', prefixIcon: Icon(Icons.search)),
                  ),
                  const SizedBox(height: Space.m),
                  Kicker(query.isEmpty ? 'Most loved on AniList' : 'Results'),
                ],
              ),
            ),
            const SizedBox(height: Space.s),
            Expanded(child: _body(query)),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.s),
              child: SafeArea(
                top: false,
                child: Text(
                  'Characters and art from AniList',
                  textAlign: TextAlign.center,
                  style: context.type.bodySmall?.copyWith(color: c.inkMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(String query) {
    final c = context.ink;
    if (_loading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return _Message(
        text: "Couldn't reach AniList. Check your connection and try again.",
        action: InkButton.secondary(label: 'Try again', small: true, onPressed: () => _load(_search.text)),
      );
    }
    if (_results.isEmpty) {
      return _Message(text: 'No one called "$query". Try their full name or another spelling.');
    }
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.m),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: Space.gutter,
            mainAxisSpacing: Space.m,
            childAspectRatio: 0.5,
          ),
          itemCount: _results.length,
          itemBuilder: (context, i) => _CharacterTile(character: _results[i], onTap: () => _choose(_results[i])),
        ),
        if (_loading)
          Positioned(
            top: 0,
            left: Space.page,
            right: Space.page,
            child: LinearProgressIndicator(minHeight: 2, color: c.ink),
          ),
      ],
    );
  }
}

class _CharacterTile extends StatelessWidget {
  const _CharacterTile({required this.character, required this.onTap});

  final AnimeCharacter character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Semantics(
      button: true,
      label: character.series.isEmpty ? character.name : '${character.name}, ${character.series}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.controlAll,
        child: LayoutBuilder(
          builder:
              (context, box) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CharacterPortrait(character: character, width: box.maxWidth, aspectRatio: 2 / 3),
                  const SizedBox(height: Space.xs),
                  Text(
                    character.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.labelLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  if (character.series.isNotEmpty)
                    Text(
                      character.series,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.bodySmall?.copyWith(color: c.inkMuted),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center, style: context.type.bodyMedium),
            if (action != null) ...[const SizedBox(height: Space.m), action!],
          ],
        ),
      ),
    );
  }
}
