import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otakuplanner/services/assistant_service.dart';

void main() {
  group('SuggestedTask', () {
    test('reads a suggestion and shows its time the way the app does', () {
      final task = SuggestedTask.tryParse({
        'title': ' Revise chapter 3 ',
        'date': '2026-11-12',
        'time': '18:05',
        'category': 'study',
      })!;
      expect(task.title, 'Revise chapter 3');
      expect(task.day, DateTime(2026, 11, 12));
      expect(task.dateString, '2026-11-12');
      expect(task.time, '18:05');
      expect(task.displayTime, '6:05 PM');
      expect(task.category, 'Study');
    });

    test('midnight and noon read as 12 AM and 12 PM', () {
      SuggestedTask at(String time) => SuggestedTask.tryParse(
          {'title': 't', 'date': '2026-11-12', 'time': time, 'category': 'Work'})!;
      expect(at('00:30').displayTime, '12:30 AM');
      expect(at('12:00').displayTime, '12:00 PM');
      expect(at('09:00').displayTime, '9:00 AM');
    });

    test('a missing category becomes Personal', () {
      final task = SuggestedTask.tryParse(
          {'title': 't', 'date': '2026-11-12', 'time': '09:00', 'category': ''})!;
      expect(task.category, 'Personal');
    });

    test('malformed suggestions are skipped, not crashed on', () {
      for (final bad in [
        null,
        'text',
        {'title': '', 'date': '2026-11-12', 'time': '09:00'},
        {'title': 't', 'date': '12/11/2026', 'time': '09:00'},
        {'title': 't', 'date': '2026-02-30', 'time': '09:00'},
        {'title': 't', 'date': '2026-11-12', 'time': '9am'},
        {'title': 't', 'date': '2026-11-12', 'time': '24:00'},
      ]) {
        expect(SuggestedTask.tryParse(bad), isNull, reason: '$bad');
      }
    });
  });

  group('AssistantReply', () {
    test('keeps the reply and the valid suggestions', () {
      final reply = AssistantReply.fromResponse({
        'status': 'success',
        'data': {
          'reply': 'Here is a plan.',
          'suggested_tasks': [
            {'title': 'Study', 'date': '2026-11-12', 'time': '09:00', 'category': 'Study'},
            {'title': 'Broken', 'date': 'soon', 'time': '09:00', 'category': 'Study'},
          ],
        },
      });
      expect(reply.reply, 'Here is a plan.');
      expect(reply.suggestedTasks.map((t) => t.title), ['Study']);
    });

    test('an empty answer is an error the user can see', () {
      expect(
        () => AssistantReply.fromResponse({'data': {'reply': '  '}}),
        throwsA(isA<AssistantException>()),
      );
      expect(() => AssistantReply.fromResponse(null), throwsA(isA<AssistantException>()));
    });
  });

  group('AssistantService', () {
    test('sends the conversation with the phone\'s own date and time', () async {
      String? sentPath;
      Map<String, dynamic>? sentBody;
      final service = AssistantService(poster: (path, body) async {
        sentPath = path;
        sentBody = body;
        return {
          'status': 'success',
          'data': {'reply': 'Hi!', 'suggested_tasks': []},
        };
      });

      final reply = await service.ask(
        const [
          AssistantTurn(fromUser: true, text: 'Hello'),
          AssistantTurn(fromUser: false, text: 'Hi, how can I help?'),
          AssistantTurn(fromUser: true, text: 'Plan my day'),
        ],
        now: DateTime(2026, 11, 5, 8, 7),
      );

      expect(reply.reply, 'Hi!');
      expect(sentPath, '/assistant/chat');
      expect(sentBody, {
        'messages': [
          {'role': 'user', 'text': 'Hello'},
          {'role': 'model', 'text': 'Hi, how can I help?'},
          {'role': 'user', 'text': 'Plan my day'},
        ],
        'today': '2026-11-05',
        'now': '08:07',
      });
    });

    DioException failure({int? status, Map<String, dynamic>? body, DioExceptionType? type}) {
      final options = RequestOptions(path: '/assistant/chat');
      return DioException(
        requestOptions: options,
        type: type ?? DioExceptionType.badResponse,
        response: status == null
            ? null
            : Response(requestOptions: options, statusCode: status, data: body),
      );
    }

    test('server messages for limits and outages reach the user', () async {
      final service = AssistantService(
        poster: (_, __) async => throw failure(
          status: 429,
          body: {'message': "You've asked a lot this hour. Try again a bit later."},
        ),
      );
      expect(
        () => service.ask(const [AssistantTurn(fromUser: true, text: 'hi')]),
        throwsA(isA<AssistantException>().having(
          (e) => e.message,
          'message',
          "You've asked a lot this hour. Try again a bit later.",
        )),
      );
    });

    test('an expired login and a dead connection get plain explanations', () {
      expect(
        AssistantService.messageFor(failure(status: 401, body: {'message': 'Please log in again.'})),
        contains('log'),
      );
      expect(
        AssistantService.messageFor(failure(type: DioExceptionType.connectionError)),
        contains("Can't reach"),
      );
      expect(
        AssistantService.messageFor(failure(type: DioExceptionType.receiveTimeout)),
        contains('too long'),
      );
    });
  });
}
