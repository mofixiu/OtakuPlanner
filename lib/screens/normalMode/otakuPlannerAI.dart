// ignore_for_file: unused_local_variable, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/services/ai_service.dart';
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

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // Add user message
      _chatMessages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });

      // Clear the input field
      _textController.clear();
      
      // Add "thinking" message
      _chatMessages.add({
        'text': "Thinking...",
        'isUser': false,
        'isTyping': true,
        'timestamp': DateTime.now(),
      });
    });

    // Scroll to bottom immediately
    _scrollToBottom();

    // Get AI response
    AIService.generateResponse(text).then((response) {
      setState(() {
        // Remove the "thinking" message
        _chatMessages.removeWhere((msg) => msg['isTyping'] == true);
        
        // Add actual AI response
        _chatMessages.add({
          'text': response,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        
        // Scroll to bottom after adding message
        _scrollToBottom();
      });
    });
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
            'Hello, ${username[0].toUpperCase()}${username.substring(1).toLowerCase()}!',
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
              decoration: InputDecoration(
                hintText: "Ask me anything",
                suffixIcon: GestureDetector(
                  onTap: _hasText ? _sendMessage : null,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _hasText
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
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) 
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color.fromARGB(255, 11, 60, 100),
                child: FaIcon(FontAwesomeIcons.bolt, color: Colors.white, size: 16),
              ),
            ),
          
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isUser ? Color.fromARGB(255, 11, 60, 100) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
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
                : Text(
                    message['text'],
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
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
                icon: Icon(Icons.add_circle_outline_rounded, color: textColor),
                onPressed: () {},
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
                    decoration: InputDecoration(
                      hintText: "Ask me anything",
                      suffixIcon: GestureDetector(
                        onTap: _hasText ? _sendMessage : null,
                        child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _hasText
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
