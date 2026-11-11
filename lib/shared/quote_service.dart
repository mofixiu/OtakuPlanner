/// A line from an anime for the dashboard, one per day.
///
/// The lines live in the app, so the dashboard never waits on a quote API
/// and every day's line is the same wherever it's opened.
class Quote {
  const Quote({required this.text, required this.character, required this.series});

  final String text;
  final String character;
  final String series;

  /// "Kyojuro Rengoku, Demon Slayer"
  String get attribution => '$character, $series';
}

class QuoteService {
  QuoteService._();

  /// Kept so app start-up doesn't change; nothing needs loading any more.
  static void initializeQuotes() {}

  /// Today's line. The same all day, a different one tomorrow.
  static Quote getQuote({DateTime? now}) {
    final d = now ?? DateTime.now();
    final dayNumber = DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;
    return quotes[dayNumber % quotes.length];
  }

  static const List<Quote> quotes = [
    Quote(text: 'Set your heart ablaze.', character: 'Kyojuro Rengoku', series: 'Demon Slayer'),
    Quote(
      text: "If you don't take risks, you can't create a future.",
      character: 'Monkey D. Luffy',
      series: 'One Piece',
    ),
    Quote(
      text: 'A lesson without pain is meaningless.',
      character: 'Edward Elric',
      series: 'Fullmetal Alchemist: Brotherhood',
    ),
    Quote(
      text: 'A dropout will beat a genius through hard work.',
      character: 'Rock Lee',
      series: 'Naruto',
    ),
    Quote(
      text: "When you give up, that's when the game ends.",
      character: 'Mitsuyoshi Anzai',
      series: 'Slam Dunk',
    ),
    Quote(
      text: 'You should enjoy the little detours to the fullest.',
      character: 'Ging Freecss',
      series: 'Hunter x Hunter',
    ),
    Quote(
      text: "I'll leave tomorrow's problems to tomorrow's me.",
      character: 'Saitama',
      series: 'One-Punch Man',
    ),
    Quote(
      text: 'No matter how deep the night, it always turns to day, eventually.',
      character: 'Brook',
      series: 'One Piece',
    ),
    Quote(
      text: 'Fear is not evil. It tells you what your weakness is.',
      character: 'Gildarts Clive',
      series: 'Fairy Tail',
    ),
    Quote(
      text: 'Being weak is nothing to be ashamed of. Staying weak is.',
      character: 'Fuegoleon Vermillion',
      series: 'Black Clover',
    ),
    Quote(
      text: 'Power comes in response to a need, not a desire.',
      character: 'Goku',
      series: 'Dragon Ball Z',
    ),
    Quote(text: 'Go beyond! Plus Ultra!', character: 'All Might', series: 'My Hero Academia'),
    Quote(
      text: 'Hard work is worthless for those that don\'t believe in themselves.',
      character: 'Naruto Uzumaki',
      series: 'Naruto',
    ),
    Quote(
      text: "Whatever you lose, you'll find it again. But what you throw away you'll never get back.",
      character: 'Kenshin Himura',
      series: 'Rurouni Kenshin',
    ),
    Quote(
      text: 'Simplicity is the easiest path to true beauty.',
      character: 'Seishu Handa',
      series: 'Barakamon',
    ),
    Quote(
      text: 'If you win, you live. If you lose, you die. If you don\'t fight, you can\'t win!',
      character: 'Eren Yeager',
      series: 'Attack on Titan',
    ),
    Quote(
      text: "Life is not a game of luck. If you wanna win, work hard.",
      character: 'Sora',
      series: 'No Game No Life',
    ),
  ];
}
