// ignore_for_file: unused_local_variable, prefer_final_fields

import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/calendar.dart' show categoryIcons;
import 'package:otakuplanner/screens/request.dart' show saveTaskToDatabase;
import 'package:otakuplanner/services/assistant_service.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:provider/provider.dart';

class OtakuPlannerAIPage extends StatefulWidget {
  const OtakuPlannerAIPage({super.key});

  @override
  State<OtakuPlannerAIPage> createState() => _OtakuPlannerAIPageState();
}

class _OtakuPlannerAIPageState extends State<OtakuPlannerAIPage> {
  TextEditingController _textController = TextEditingController();
  bool _hasText = false;
  List<Map<String, dynamic>> _chatMessages = [];
  ScrollController _scrollController = ScrollController();
  final AssistantService _assistant = AssistantService();
  bool _waiting = false;

  // Suggested tasks being saved, and ones already added, keyed by suggestion.
  final Set<String> _saving = {};
  final Set<String> _added = {};

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateHasText);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateHasText);
    _textController.dispose();
    super.dispose();
  }

  void _updateHasText() {
    setState(() {
      _hasText = _textController.text.isNotEmpty;
    });
  }

  void _selectPrompt(String prompt) {
    setState(() {
      _textController.text = prompt;
      _hasText = true; // Make sure this gets updated immediately
    });
    // Option to auto-focus the text field after selecting a prompt
    FocusScope.of(context).requestFocus(FocusNode());
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
          icon: categoryIcons[suggestion.category] ?? FontAwesomeIcons.listCheck,
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

  // Helper method for scrolling
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildWelcomeView(BuildContext context, String username, Color textColor, Color buttonColor) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Reduced top spacing
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 11, 60, 100),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.bolt,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            username.isEmpty
                ? 'Hello!'
                : 'Hello, ${username[0].toUpperCase()}${username.substring(1).toLowerCase()}!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: buttonColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'How can OtakuPlanner assistant help you today?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          SizedBox(height: 24),
          
          // Text field moved here - before the prompts
          Container(
            width: MediaQuery.of(context).size.width - 20,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: TextField(
              obscureText: false,
              controller: _textController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: "Ask me anything",
                suffixIcon: GestureDetector(
                  onTap: _hasText && !_waiting ? _sendMessage : null,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _hasText && !_waiting
                            ? Color.fromARGB(255, 11, 60, 100)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Icon(
                          Icons.send_sharp,
                          color: _hasText
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minHeight: 25,
                  minWidth: 50,
                ),
                filled: false,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(252, 242, 232, 1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(252, 242, 232, 1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Color(0xFF1E293B),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Prompt suggestions
          Text(
            'Or try one of these prompts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          SizedBox(height: 16),
          
          // Prompt containers in a wrap
          Wrap(
            spacing: 8.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: [
              _buildPromptContainer(
                icon: Icons.calendar_month_outlined,
                label: 'Plan study session',
                onTap: () => _selectPrompt('Plan a study session for my upcoming exams'),
              ),
              _buildPromptContainer(
                icon: Icons.task_alt_outlined,
                label: 'Identify top tasks',
                onTap: () => _selectPrompt('Help me identify my top priority tasks for today'),
              ),
              _buildPromptContainer(
                icon: Icons.coffee_outlined, 
                label: 'Suggest a break',
                onTap: () => _selectPrompt('Suggest activities for a productive 15-minute break'),
              ),
              _buildPromptContainer(
                icon: Icons.summarize_outlined,
                label: 'Summarize weekly tasks',
                onTap: () => _selectPrompt('Summarize all my tasks for this week'),
              ),
              _buildPromptContainer(
                icon: Icons.emoji_emotions_outlined,
                label: 'Motivate me',
                onTap: () => _selectPrompt('Give me some motivation to finish my tasks'),
              ),
              _buildPromptContainer(
                icon: Icons.format_list_bulleted,
                label: 'Organize watchlist',
                onTap: () => _selectPrompt('Help me organize my anime watchlist by priority'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final isTyping = message['isTyping'] ?? false;
    final isError = message['isError'] ?? false;
    final suggestions = (message['suggestions'] as List<SuggestedTask>?) ?? const [];

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isUser
            ? Color.fromARGB(255, 11, 60, 100)
            : isError
                ? Colors.red.shade50
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: isError ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: isTyping
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Thinking",
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color.fromARGB(255, 11, 60, 100),
                  ),
                ),
              ],
            )
          : SelectableText(
              message['text'],
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : isError
                        ? Colors.red.shade900
                        : Colors.black87,
                fontSize: 16,
              ),
            ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: isError ? Colors.red.shade300 : Color.fromARGB(255, 11, 60, 100),
                child: FaIcon(
                  isError ? FontAwesomeIcons.triangleExclamation : FontAwesomeIcons.bolt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

          Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              bubble,
              for (final suggestion in suggestions) _buildSuggestionCard(suggestion),
            ],
          ),

          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  /// A task the assistant proposed, with an Add button. Nothing reaches the
  /// planner until the user taps it.
  Widget _buildSuggestionCard(SuggestedTask suggestion) {
    final key = _suggestionKey(suggestion);
    final saving = _saving.contains(key);
    final added = _added.contains(key);
    final when = '${DateFormat('EEE d MMM').format(suggestion.day)} · ${suggestion.displayTime}';

    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          FaIcon(
            categoryIcons[suggestion.category] ?? FontAwesomeIcons.listCheck,
            size: 16,
            color: Color.fromARGB(255, 11, 60, 100),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  '$when · ${suggestion.category}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (added)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text('Added', style: TextStyle(fontSize: 13, color: Colors.green.shade700)),
                ],
              ),
            )
          else
            TextButton(
              onPressed: saving ? null : () => _addSuggestedTask(suggestion),
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 11, 60, 100),
                minimumSize: const Size(56, 36),
              ),
              child: saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildPromptContainer({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade800,
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final borderColor = OtakuPlannerTheme.getBorderColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 1,
          titleSpacing: 0,
          title: Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, size: 20, color: textColor),
                label: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    'Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),

              IconButton(
                tooltip: 'New chat',
                icon: Icon(Icons.add_circle_outline_rounded, color: textColor),
                onPressed: _chatMessages.isEmpty || _waiting ? null : _startNewChat,
              ),
              IconButton(
                icon: Icon(Icons.history, color: textColor),
                onPressed: () {},
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Chat messages area
              Expanded(
                child: _chatMessages.isEmpty 
                    ? _buildWelcomeView(context, username, textColor, buttonColor)
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = _chatMessages[index];
                          return _buildChatMessage(message);
                        },
                      ),
              ),
              
              // Text field only shown when in chat mode
              if (_chatMessages.isNotEmpty) 
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: TextField(
                    obscureText: false,
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask me anything",
                      suffixIcon: GestureDetector(
                        onTap: _hasText && !_waiting ? _sendMessage : null,
                        child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _hasText && !_waiting
                                      ? Color.fromARGB(255, 11, 60, 100)
                                      : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Icon(
                                Icons.send_sharp,
                                color:
                                    _hasText
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      suffixIconConstraints: BoxConstraints(
                        minHeight: 25,
                        minWidth: 50,
                      ),

                      filled: false,
                      fillColor: Colors.white12,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 242, 232, 1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 242, 232, 1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Color(0xFF1E293B),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
