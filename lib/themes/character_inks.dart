import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:otakuplanner/themes/tokens.dart';

/// Anime mode prints the manga page in a character's colours.
///
/// The page is still paper and ink: the navy ink becomes a deep shade of the
/// character's colour, and the vermilion stamp (today, the streak, the active
/// tab) becomes the colour itself. Nothing else on the page changes, so the
/// character is felt in the print rather than pasted over it.
class CharacterInks {
  CharacterInks._();

  // Score falls back to Google Blue when nothing in the art is usable; a
  // transparent sentinel lets us tell that apart from a real colour.
  static const int _noColour = 0x00000000;

  /// Up to four colours from the art, most characterful first. Empty when the
  /// art is too grey to pick from.
  ///
  /// Portraits are mostly face, so skin tones go to the back of the list
  /// (they're kept: pale pink hair looks the same to a computer), and
  /// near-whites and greys are dropped because their hue means nothing.
  static Future<List<Color>> candidatesFromPixels(List<int> argb) async {
    if (argb.isEmpty) return const [];
    final quantized = await QuantizerCelebi().quantize(argb, 128);
    final scored = [
      for (final c in Score.score(quantized.colorToCount, desired: 8, fallbackColorARGB: _noColour))
        if (c != _noColour) Hct.fromInt(c),
    ];
    final coloured = scored.where((h) => h.chroma >= 12).toList();
    final picks = coloured.isEmpty ? scored : coloured;
    final ordered = [...picks.where((h) => !_looksLikeSkin(h)), ...picks.where(_looksLikeSkin)];
    return [for (final h in ordered.take(4)) Color(h.toInt())];
  }

  static bool _looksLikeSkin(Hct h) => h.hue >= 30 && h.hue <= 75 && h.chroma < 40 && h.tone > 55;

  /// The opaque pixels of [image] as ARGB. Decode it small first (about 112px
  /// wide): colour picking only needs the overall mix.
  static Future<List<int>> pixelsOf(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return const [];
    final bytes = data.buffer.asUint8List();
    final pixels = <int>[];
    for (var i = 0; i + 3 < bytes.length; i += 4) {
      if (bytes[i + 3] < 250) continue; // transparent background
      pixels.add(0xFF000000 | (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]);
    }
    return pixels;
  }

  /// Decodes image [bytes] small and returns its candidate colours.
  static Future<List<Color>> candidatesFromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 112);
    final frame = await codec.getNextFrame();
    final pixels = await pixelsOf(frame.image);
    frame.image.dispose();
    return candidatesFromPixels(pixels);
  }

  /// The page printed in [seed], for light or dark pages. Contrast matches
  /// the normal theme: the stamp reads as text on the paper (4.5:1 or more)
  /// and the ink is as dark (or, on night pages, as light) as the navy it
  /// replaces.
  static PlannerColors colorsFor(Color seed, Brightness brightness) {
    final hct = Hct.fromInt(seed.toARGB32());
    final hue = hct.hue;
    // Yellows darkened enough to read on cream turn olive. Dark inks print
    // them as ochre instead, the way a yellow ink is darkened on a press.
    final darkHue = hue >= 85 && hue <= 125 ? 70.0 : hue;
    // A stamp needs to look like ink, not dust: lift greyish picks a little.
    final stampChroma = hct.chroma < 36 ? 36.0 : hct.chroma;

    if (brightness == Brightness.light) {
      const paper = Palette.paper;
      final paperTone = Hct.fromInt(paper.toARGB32()).tone;
      final maxStampTone = Contrast.darker(tone: paperTone, ratio: 4.6);
      final stampTone = hct.tone < maxStampTone ? hct.tone : maxStampTone;
      return PlannerColors(
        paper: paper,
        ink: Color(Hct.from(darkHue, hct.chroma < 18 ? hct.chroma : 18, 20).toInt()),
        stamp: Color(Hct.from(darkHue, stampChroma, stampTone).toInt()),
      );
    }

    final paper = Color(Hct.from(darkHue, hct.chroma < 10 ? hct.chroma : 10, 9).toInt());
    final paperTone = Hct.fromInt(paper.toARGB32()).tone;
    final minStampTone = Contrast.lighter(tone: paperTone, ratio: 6);
    final stampTone = hct.tone > minStampTone ? hct.tone : minStampTone;
    return PlannerColors(
      paper: paper,
      ink: Color(Hct.from(hue, 6, 92).toInt()),
      stamp: Color(Hct.from(hue, stampChroma, stampTone).toInt()),
    );
  }
}
