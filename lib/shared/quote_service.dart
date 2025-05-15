import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['content'] ?? json['q'] ?? 'Make today count!',
      author: json['author'] ?? json['a'] ?? 'Unknown',
    );
  }
}

class QuoteService {
  // Primary API
  static const String _quotableApi = 'https://api.quotable.io';
  // Backup API
  static const String _zenQuotesApi = 'https://zenquotes.io/api';

  // Cache for quotes - static to persist across rebuilds
  static Quote? _cachedQuote;
  static bool _isRefreshing = false;

  // Initialize quotes as early as possible
  static void initializeQuotes() {
    fetchQuoteInBackground();
  }

  // Fetch a quote in the background and cache it
  static Future<void> fetchQuoteInBackground() async {
    if (_isRefreshing) return;
    
    _isRefreshing = true;
    try {
      final quote = await _fetchFromApis();
      _cachedQuote = quote;
    } catch (e) {
      // If all fails, get a fallback quote
      if (_cachedQuote == null) {
        _cachedQuote = _getRandomFallbackQuote();
      }
    } finally {
      _isRefreshing = false;
    }
  }

  // Get a quote - immediate return from cache or fallback
  static Quote getQuote() {
    // If we have a cached quote, return it and refresh in background
    if (_cachedQuote != null) {
      // Refresh the cache for next time if not already refreshing
      if (!_isRefreshing) {
        fetchQuoteInBackground();
      }
      return _cachedQuote!;
    }
    
    // If no cached quote yet, return a fallback and start fetching
    final fallback = _getRandomFallbackQuote();
    if (!_isRefreshing) {
      fetchQuoteInBackground();
    }
    return fallback;
  }

  // Try both APIs and return a quote
  static Future<Quote> _fetchFromApis() async {
    // Try primary API (Quotable)
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse('$_quotableApi/random?tags=inspirational,motivational&t=$timestamp'),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return Quote.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('First API failed: $e');
    }

    // Try backup API
    try {
      final response = await http.get(
        Uri.parse('$_zenQuotesApi/random'),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Quote.fromJson(data[0]);
        }
      }
    } catch (e) {
      print('Second API failed: $e');
    }
    
    // If both APIs fail, fallback to local quotes
    return _getRandomFallbackQuote();
  }
  
  // Get a random fallback quote
  static Quote _getRandomFallbackQuote() {
    final random = Random();
    return _fallbackQuotes[random.nextInt(_fallbackQuotes.length)];
  }

  // Keep your existing fallback quotes list
  static final List<Quote> _fallbackQuotes = [
    Quote(text: "Every accomplishment starts with the decision to try.", author: "Unknown"),
    Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
    Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
    Quote(text: "The best way to predict the future is to create it.", author: "Peter Drucker"),
    Quote(text: "Don't count the days, make the days count.", author: "Muhammad Ali"),
    Quote(text: "Quality is not an act, it is a habit.", author: "Aristotle"),
    Quote(text: "Your time is limited, don't waste it living someone else's life.", author: "Steve Jobs"),
    Quote(text: "Success is not final, failure is not fatal: It is the courage to continue that counts.", author: "Winston Churchill"),
    Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
    Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
    Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
    Quote(text: "It always seems impossible until it's done.", author: "Nelson Mandela"),
    Quote(text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis"),
    Quote(text: "The only limit to our realization of tomorrow is our doubts of today.", author: "Franklin D. Roosevelt"),
    Quote(text: "Strive not to be a success, but rather to be of value.", author: "Albert Einstein"),
    Quote(text: "The question isn't who is going to let me; it's who is going to stop me.", author: "Ayn Rand"),
    Quote(text: "If you can dream it, you can do it.", author: "Walt Disney"),
    Quote(text: "Nothing is impossible, the word itself says 'I'm possible'!", author: "Audrey Hepburn"),
    Quote(text: "Don't let yesterday take up too much of today.", author: "Will Rogers"),
    Quote(text: "Life is 10% what happens to us and 90% how we react to it.", author: "Charles R. Swindoll"),
    Quote(text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky"),
    Quote(text: "The mind is everything. What you think you become.", author: "Buddha"),
    Quote(text: "The most difficult thing is the decision to act, the rest is merely tenacity.", author: "Amelia Earhart"),
    Quote(text: "Twenty years from now you will be more disappointed by the things you didn't do than by the ones you did.", author: "Mark Twain"),
    Quote(text: "The greatest glory in living lies not in never falling, but in rising every time we fall.", author: "Nelson Mandela"),
    Quote(text: "Life is either a daring adventure or nothing at all.", author: "Helen Keller"),
    Quote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins"),
    Quote(text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein"),
    Quote(text: "If you want to lift yourself up, lift up someone else.", author: "Booker T. Washington"),
    Quote(text: "The purpose of our lives is to be happy.", author: "Dalai Lama"),
    Quote(text: "Happiness is not something ready-made. It comes from your own actions.", author: "Dalai Lama"),
    Quote(text: "I have not failed. I've just found 10,000 ways that won't work.", author: "Thomas Edison"),
    Quote(text: "We become what we think about.", author: "Earl Nightingale"),
    Quote(text: "What you lack in talent can be made up with desire, hustle, and giving 110% all the time.", author: "Don Zimmer"),
    Quote(text: "Do what you can, with what you have, where you are.", author: "Theodore Roosevelt"),
    Quote(text: "Be yourself; everyone else is already taken.", author: "Oscar Wilde"),
    Quote(text: "Turn your wounds into wisdom.", author: "Oprah Winfrey"),
    Quote(text: "When one door of happiness closes, another opens.", author: "Helen Keller"),
    Quote(text: "You must be the change you wish to see in the world.", author: "Mahatma Gandhi"),
    Quote(text: "Tough times never last, but tough people do.", author: "Robert H. Schuller"),
    Quote(text: "You only live once, but if you do it right, once is enough.", author: "Mae West"),
    Quote(text: "The power of imagination makes us infinite.", author: "John Muir"),
    Quote(text: "If opportunity doesn't knock, build a door.", author: "Milton Berle"),
    Quote(text: "What you get by achieving your goals is not as important as what you become by achieving your goals.", author: "Zig Ziglar"),
    Quote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
    Quote(text: "Success is not the key to happiness. Happiness is the key to success.", author: "Albert Schweitzer"),
    Quote(text: "The harder I work, the luckier I get.", author: "Gary Player"),
    Quote(text: "Action is the foundational key to all success.", author: "Pablo Picasso"),
    Quote(text: "Dream big and dare to fail.", author: "Norman Vaughan"),
    Quote(text: "Small steps in the right direction can turn out to be the biggest step of your life.", author: "Unknown"),
  ];
}