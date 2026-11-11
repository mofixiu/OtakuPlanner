import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/request.dart' show saveTaskToDatabase;
import 'package:otakuplanner/services/assistant_service.dart';
import 'package:otakuplanner/shared/category_icons.dart';
import 'package:otakuplanner/shared/planner_stats.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// The planning assistant. Replies come from the backend's /assistant/chat
/// (Gemini on the server); suggested tasks only reach the planner when the
/// user taps Add.
class OtakuPlannerAIPage extends StatefulWidget {
  const OtakuPlannerAIPage({super.key});

  @override
  State<OtakuPlannerAIPage> createState() => _OtakuPlannerAIPageState();
}

class _OtakuPlannerAIPageState extends State<OtakuPlannerAIPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  bool _hasText = false;
  final List<Map<String, dynamic>> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  final AssistantService _assistant = AssistantService();
  bool _waiting = false;

  // Suggested tasks being saved, and ones already added, keyed by suggestion.
  final Set<String> _saving = {};
  final Set<String> _added = {};

  static const _prompts = [
    'Plan the rest of my day',
    'Fit two episodes in this week',
    'Spread my study over the next three days',
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateHasText);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateHasText);
    _textController.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateHasText() {
    setState(() {
      _hasText = _textController.text.trim().isNotEmpty;
    });
  }

  /// Puts a prompt in the box so it can be sent as is or changed first.
  void _selectPrompt(String prompt) {
    _textController.text = prompt;
    _textController.selection = TextSelection.collapsed(offset: prompt.length);
    _inputFocus.requestFocus();
  }

  /// The conversation so far, without placeholders or error notes, for the
  /// assistant to read.
  List<AssistantTurn> _history() {
    return _chatMessages
        .where((m) => m['isTyping'] != true && m['isError'] != true)
        .map((m) => AssistantTurn(fromUser: m['isUser'] as bool, text: m['text'] as String))
        .toList();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _waiting) return;

    setState(() {
      _chatMessages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _textController.clear();
      _waiting = true;
    });
    final history = _history();
    setState(() {
      _chatMessages.add({'text': '', 'isUser': false, 'isTyping': true});
    });
    _scrollToBottom();

    Map<String, dynamic> answer;
    try {
      final reply = await _assistant.ask(history);
      answer = {
        'text': reply.reply,
        'isUser': false,
        'timestamp': DateTime.now(),
        'suggestions': reply.suggestedTasks,
      };
    } on AssistantException catch (error) {
      answer = {
        'text': error.message,
        'isUser': false,
        'isError': true,
        'timestamp': DateTime.now(),
      };
    } catch (error) {
      log('Assistant failed: $error');
      answer = {
        'text': "The assistant couldn't answer just now. Try again in a moment.",
        'isUser': false,
        'isError': true,
        'timestamp': DateTime.now(),
      };
    }
    if (!mounted) return;
    setState(() {
      _chatMessages.removeWhere((m) => m['isTyping'] == true);
      _chatMessages.add(answer);
      _waiting = false;
    });
    _scrollToBottom();
  }

  void _startNewChat() {
    if (_waiting) return;
    setState(() {
      _chatMessages.clear();
      _textController.clear();
    });
  }

  String _suggestionKey(SuggestedTask task) => '${task.title}|${task.dateString}|${task.time}';

  /// Saves a suggested task the same way the calendar does, then shows it in
  /// the planner. It's only added once the server has it.
  Future<void> _addSuggestedTask(SuggestedTask suggestion) async {
    final key = _suggestionKey(suggestion);
    if (_saving.contains(key) || _added.contains(key)) return;

    final messenger = ScaffoldMessenger.of(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    setState(() => _saving.add(key));
    try {
      final response = await saveTaskToDatabase(
        TaskMain(
          title: suggestion.title,
          category: suggestion.category,
          time: suggestion.time,
          date: suggestion.dateString,
          userId: userProvider.userId,
          completed: false,
        ),
      );
      final data = response?['data'];
      if (response?['status'] != 'success' || data is! Map) {
        throw Exception(response?['message'] ?? 'Task was not saved');
      }

      taskProvider.addTask(
        suggestion.day,
        Task(
          id: data['id'] is int ? data['id'] as int : int.tryParse('${data['id']}'),
          title: suggestion.title,
          category: suggestion.category,
          time: suggestion.displayTime,
          date: suggestion.day.toIso8601String(),
          color: Task.getRandomColor(),
          icon: categoryIconFor(suggestion.category),
        ),
      );
      if (!categoryProvider.categoryExists(suggestion.category)) {
        await categoryProvider.addAndSaveCategory(suggestion.category, userProvider.userId);
      }

      if (!mounted) return;
      setState(() {
        _saving.remove(key);
        _added.add(key);
      });
      messenger.showSnackBar(
        SnackBar(content: Text("Added '${suggestion.title}' to your planner")),
      );
    } catch (error) {
      log('Could not add suggested task: $error');
      if (!mounted) return;
      setState(() => _saving.remove(key));
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't add '${suggestion.title}'. Try again.")),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// "2 tasks left today, next at 5:00 PM." from the user's own planner.
  String _daySummary(PlannerStats stats) {
    final today = stats.todayTasks;
    final left = today.where((t) => !t.isChecked).length;
    final next = stats.nextToday;
    if (today.isEmpty) {
      final tomorrow = stats.tasksOn(stats.today.add(const Duration(days: 1))).length;
      return tomorrow == 0
          ? 'Nothing planned today or tomorrow.'
          : 'Nothing planned today. Tomorrow has $tomorrow ${tomorrow == 1 ? 'task' : 'tasks'}.';
    }
    if (left == 0) {
      return 'All ${today.length} of today\'s tasks are done.';
    }
    final count = '$left ${left == 1 ? 'task' : 'tasks'} left today';
    return next == null ? '$count.' : '$count, next at ${PlannerFormat.time(next.time)}.';
  }

  Widget _buildWelcomeView(BuildContext context, String name) {
    final stats = PlannerStats(Provider.of<TaskProvider>(context).tasks);
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
      children: [
        Kicker(PlannerFormat.kickerDay(stats.today), stamped: true),
        const SizedBox(height: Space.gutter),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MascotAvatar(size: 44),
            const SizedBox(width: Space.s),
            Expanded(
              child: SpeechBalloon(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Hi.' : 'Hi $name.',
                      style: context.type.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(_daySummary(stats), style: context.type.bodyMedium),
                    const SizedBox(height: Space.xs),
                    Text(
                      "Tell me what you want to fit in and I'll suggest times. Nothing is added until you tap Add.",
                      style: context.type.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.l),
        const Kicker('Try asking'),
        const SizedBox(height: Space.s),
        Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < _prompts.length; i++) ...[
                if (i > 0) const InkRule(),
                Semantics(
                  button: true,
                  child: InkWell(
                    onTap: () => _selectPrompt(_prompts[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(child: Text(_prompts[i], style: context.type.titleMedium)),
                          Icon(Icons.north_west, size: 16, color: context.ink.inkMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    final c = context.ink;
    final isUser = message['isUser'] as bool;
    final isTyping = message['isTyping'] ?? false;
    final isError = message['isError'] ?? false;
    final suggestions = (message['suggestions'] as List<SuggestedTask>?) ?? const [];
    final maxWidth = MediaQuery.of(context).size.width * 0.78;

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s),
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SpeechBalloon(
              tail: BalloonTail.right,
              filled: true,
              child: SelectableText(
                message['text'],
                style: context.type.bodyMedium?.copyWith(color: c.paper),
              ),
            ),
          ),
        ),
      );
    }

    final Widget body;
    if (isTyping) {
      body = Semantics(
        liveRegion: true,
        label: 'The assistant is writing',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: c.ink)),
            const SizedBox(width: Space.s),
            Text('Writing…', style: context.type.bodyMedium?.copyWith(color: c.inkMuted)),
          ],
        ),
      );
    } else if (isError) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.error_outline, size: 18, color: c.ink),
          ),
          const SizedBox(width: Space.s),
          Flexible(
            child: SelectableText(
              message['text'],
              style: context.type.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    } else {
      body = SelectableText(message['text'], style: context.type.bodyMedium);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MascotAvatar(size: 32),
          const SizedBox(width: Space.xs),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpeechBalloon(child: body),
                  for (final suggestion in suggestions) ...[
                    const SizedBox(height: Space.s),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildSuggestionCard(suggestion),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A task the assistant proposed, with an Add button. Nothing reaches the
  /// planner until the user taps it.
  Widget _buildSuggestionCard(SuggestedTask suggestion) {
    final c = context.ink;
    final key = _suggestionKey(suggestion);
    final saving = _saving.contains(key);
    final added = _added.contains(key);
    final when = PlannerFormat.dayTime(suggestion.day, suggestion.displayTime);

    return Panel(
      padding: const EdgeInsets.fromLTRB(Space.gutter, 10, Space.s, 10),
      child: Row(
        children: [
          ToneSwatch(category: suggestion.category, size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suggestion.title, style: context.type.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '$when · ${suggestion.category}',
                  style: context.type.bodySmall?.copyWith(fontFeatures: TypeScale.tabular),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (added)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 16, color: c.ink),
                  const SizedBox(width: 4),
                  Text('Added', style: context.type.labelMedium),
                ],
              ),
            )
          else
            InkButton.secondary(
              label: 'Add',
              small: true,
              loading: saving,
              onPressed: () => _addSuggestedTask(suggestion),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final c = context.ink;
    final canSend = _hasText && !_waiting;
    return Container(
      decoration: BoxDecoration(
        color: c.paper,
        border: Border(top: BorderSide(color: c.ink, width: Strokes.panel)),
      ),
      padding: const EdgeInsets.fromLTRB(Space.page, Space.s + 2, Space.page, Space.s + 2),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _inputFocus,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(hintText: 'Ask about your plans'),
              ),
            ),
            const SizedBox(width: Space.s),
            Semantics(
              button: true,
              enabled: canSend,
              label: 'Send',
              child: Material(
                color: canSend ? c.ink : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: Radii.controlAll,
                  side: BorderSide(color: canSend ? c.ink : c.rule, width: Strokes.panel),
                ),
                child: InkWell(
                  onTap: canSend ? _sendMessage : null,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.arrow_upward, color: canSend ? c.paper : c.inkMuted),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).username;
    final name = username.isEmpty
        ? ''
        : '${username[0].toUpperCase()}${username.substring(1).toLowerCase()}';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: InkBackBar(
          title: 'Assistant',
          actions: [
            if (_chatMessages.isNotEmpty)
              TextButton.icon(
                onPressed: _waiting ? null : _startNewChat,
                icon: const Icon(Icons.edit_note, size: 20),
                label: const Text('New chat'),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _chatMessages.isEmpty
                  ? _buildWelcomeView(context, name)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(Space.page, Space.s, Space.page, Space.m),
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) => _buildChatMessage(_chatMessages[index]),
                    ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }
}

/// The mascot's face in an ink square, speaking for the assistant.
class _MascotAvatar extends StatelessWidget {
  const _MascotAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        border: Border.all(color: context.ink.ink, width: Strokes.panel),
        borderRadius: Radii.controlAll,
      ),
      child: MascotLine(height: size),
    );
  }
}
