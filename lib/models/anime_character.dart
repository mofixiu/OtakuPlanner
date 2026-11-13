/// A character from AniList, as much as Anime mode needs to remember.
class AnimeCharacter {
  const AnimeCharacter({required this.id, required this.name, required this.series, required this.imageUrl});

  final int id;
  final String name;

  /// The character's best-known show, or empty when AniList has none.
  final String series;
  final String imageUrl;

  Map<String, Object> toJson() => {'id': id, 'name': name, 'series': series, 'imageUrl': imageUrl};

  static AnimeCharacter? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final name = json['name'];
    final imageUrl = json['imageUrl'];
    if (id is! int || name is! String || imageUrl is! String) return null;
    final series = json['series'];
    return AnimeCharacter(id: id, name: name, series: series is String ? series : '', imageUrl: imageUrl);
  }

  @override
  bool operator ==(Object other) => other is AnimeCharacter && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
