import 'package:dio/dio.dart';
import 'package:otakuplanner/models/anime_character.dart';
import 'package:otakuplanner/screens/request.dart' as api;

/// One message in the conversation, as the backend expects it.
class AssistantTurn {
  final bool fromUser;
  final String text;

  const AssistantTurn({required this.fromUser, required this.text});

  Map<String, String> toJson() => {
        'role': fromUser ? 'user' : 'model',
        'text': text,
      };
}

/// A task the assistant proposes. Nothing is added until the user taps Add.
class SuggestedTask {
  final String title;
  final DateTime day;

  /// 24-hour time, e.g. 18:30, as the database stores it.
  final String time;
  final String category;

  const SuggestedTask({
    required this.title,
    required this.day,
    required this.time,
    required this.category,
  });

  static final RegExp _dateRe = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  static final RegExp _timeRe = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

  /// Returns null for anything malformed, so a bad suggestion is skipped
  /// instead of breaking the chat.
  static SuggestedTask? tryParse(dynamic json) {
    if (json is! Map) return null;
    final title = (json['title'] ?? '').toString().trim();
    final dateMatch = _dateRe.firstMatch((json['date'] ?? '').toString());
    final time = (json['time'] ?? '').toString();
    if (title.isEmpty || dateMatch == null || !_timeRe.hasMatch(time)) {
      return null;
    }
    final year = int.parse(dateMatch.group(1)!);
    final month = int.parse(dateMatch.group(2)!);
    final dayOfMonth = int.parse(dateMatch.group(3)!);
    final day = DateTime(year, month, dayOfMonth);
    if (day.month != month || day.day != dayOfMonth) return null;

    final rawCategory = (json['category'] ?? '').toString().trim();
    final category = rawCategory.isEmpty
        ? 'Personal'
        : rawCategory[0].toUpperCase() + rawCategory.substring(1).toLowerCase();
    return SuggestedTask(title: title, day: day, time: time, category: category);
  }

  /// The date the database expects, e.g. 2026-11-12.
  String get dateString =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  /// The 12-hour time the rest of the app shows, e.g. 6:30 PM.
  String get displayTime {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${parts[1]} $period';
  }
}

class AssistantReply {
  final String reply;
  final List<SuggestedTask> suggestedTasks;

  const AssistantReply({required this.reply, this.suggestedTasks = const []});

  factory AssistantReply.fromResponse(dynamic body) {
    final data = body is Map ? body['data'] : null;
    final reply = data is Map ? (data['reply'] ?? '').toString().trim() : '';
    if (reply.isEmpty) {
      throw const AssistantException(
        "The assistant sent an empty answer. Try asking again.",
      );
    }
    final rawTasks = data is Map ? data['suggested_tasks'] : null;
    final tasks = rawTasks is List
        ? rawTasks.map(SuggestedTask.tryParse).whereType<SuggestedTask>().toList()
        : <SuggestedTask>[];
    return AssistantReply(reply: reply, suggestedTasks: tasks);
  }
}

class AssistantException implements Exception {
  final String message;
  const AssistantException(this.message);

  @override
  String toString() => message;
}

typedef AssistantPoster = Future<dynamic> Function(
  String path,
  Map<String, dynamic> body,
);

/// Talks to the backend's /assistant/chat endpoint. The Gemini key lives on
/// the server; the app only ever sends its usual login token.
class AssistantService {
  static const Duration _timeout = Duration(seconds: 45);

  final AssistantPoster _post;

  AssistantService({AssistantPoster? poster})
      : _post = poster ??
            ((path, body) => api.postWithTimeout(path, body, _timeout));

  /// Builds the request body. The phone's own date and time are sent so the
  /// assistant plans around the user's day, not the server's. In Anime mode
  /// the character is sent too, and the assistant answers in their voice.
  static Map<String, dynamic> buildRequest(
    List<AssistantTurn> history,
    DateTime now, {
    AnimeCharacter? persona,
  }) {
    String two(int n) => n.toString().padLeft(2, '0');
    return {
      'messages': history.map((turn) => turn.toJson()).toList(),
      'today': '${now.year}-${two(now.month)}-${two(now.day)}',
      'now': '${two(now.hour)}:${two(now.minute)}',
      if (persona != null) 'persona': {'name': persona.name, 'series': persona.series},
    };
  }

  Future<AssistantReply> ask(List<AssistantTurn> history, {DateTime? now, AnimeCharacter? persona}) async {
    try {
      final body = await _post(
        '/assistant/chat',
        buildRequest(history, now ?? DateTime.now(), persona: persona),
      );
      return AssistantReply.fromResponse(body);
    } on DioException catch (error) {
      throw AssistantException(messageFor(error));
    }
  }

  /// Turns a failed request into something worth showing the user.
  static String messageFor(DioException error) {
    final body = error.response?.data;
    final serverMessage = body is Map ? body['message']?.toString() : null;
    switch (error.response?.statusCode) {
      case 401:
        return 'Your login has expired. Log out and back in to keep chatting.';
      case 429:
      case 400:
      case 502:
      case 503:
        if (serverMessage != null && serverMessage.isNotEmpty) {
          return serverMessage;
        }
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return "Can't reach OtakuPlanner right now. Check your connection.";
      case DioExceptionType.receiveTimeout:
        return 'The assistant took too long to answer. Try again.';
      default:
        return "The assistant couldn't answer just now. Try again in a moment.";
    }
  }
}
