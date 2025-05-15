import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  static Future<String> generateResponse(String userPrompt) async {
    // Simulate network delay for realism
    await Future.delayed(Duration(milliseconds: 1200 + Random().nextInt(800)));
    
    final lowerPrompt = userPrompt.toLowerCase();
    
    // Task creation patterns
    if (lowerPrompt.contains('create') || lowerPrompt.contains('add') || lowerPrompt.contains('schedule')) {
      if (lowerPrompt.contains('task')) {
        return "I've noted your task request. To add this to your schedule, please use the task creation feature on the dashboard with the '+' button and specify the time and category.";
      }
    }
    
    // Study related
    if (lowerPrompt.contains('plan a study session') || lowerPrompt.contains('study schedule')) {
      return "Here's a study session plan I recommend:\n\n"
          "1. Break your study into 25-minute focused blocks\n"
          "2. Take 5-minute breaks between blocks\n"
          "3. After 4 blocks, take a longer 15-30 minute break\n"
          "4. Prioritize difficult subjects when your energy is highest\n"
          "5. End each session by reviewing what you've learned\n\n"
          "Would you like me to help you schedule specific study blocks in your planner?";
    }
    
    // Task prioritization
    if (lowerPrompt.contains('priority') || lowerPrompt.contains('prioritize') || lowerPrompt.contains('important')) {
      return "To identify top priority tasks, consider these factors:\n\n"
          "1. Urgency: Is there a deadline soon?\n"
          "2. Importance: What tasks align with your goals?\n"
          "3. Dependencies: Are other tasks waiting on this?\n"
          "4. Effort: How much energy will it require?\n\n"
          "Based on these, I recommend focusing on time-sensitive tasks first, then high-impact tasks that move you toward your goals.";
    }
    
    // Break suggestions
    if (lowerPrompt.contains('break') || lowerPrompt.contains('rest') || lowerPrompt.contains('relax')) {
      return "For a productive 15-minute break, try one of these:\n\n"
          "• A short walk outside for fresh air\n"
          "• Quick stretching exercises at your desk\n"
          "• Meditation or deep breathing\n"
          "• A healthy snack and water\n"
          "• Listening to one or two favorite songs\n\n"
          "Avoid social media or email during breaks as they can easily extend your break time.";
    }
    
    // Anime related
    if (lowerPrompt.contains('anime') || lowerPrompt.contains('watch') || lowerPrompt.contains('episode')) {
      return "To organize your anime watchlist effectively:\n\n"
          "1. Categorize shows by genre and length\n"
          "2. Prioritize seasonal shows that are currently airing\n"
          "3. Schedule specific watching times to avoid binge-watching\n"
          "4. Consider watching shorter series during busy weeks\n"
          "5. Track your progress in the OtakuPlanner app\n\n"
          "What genre are you currently most interested in watching?";
    }
    
    // Motivation
    if (lowerPrompt.contains('motivate') || lowerPrompt.contains('motivation') || lowerPrompt.contains('inspire')) {
      return "You've got this! Remember why you started and focus on small wins. Each task you complete is progress, and progress compounds over time. Break your big goals into smaller steps and celebrate completing each one. Your future self will thank you for the effort you put in today.";
    }

    // Help command
    if (lowerPrompt.contains('help') || lowerPrompt.contains('what can you do')) {
      return "I'm your OtakuPlanner Assistant! I can help with:\n\n"
          "• Planning study sessions\n"
          "• Prioritizing tasks\n"
          "• Suggesting productive breaks\n"
          "• Organizing anime watchlists\n"
          "• Providing motivation\n"
          "• Summarizing tasks\n\n"
          "Just ask me what you need help with!";
    }
    
    // Default response for anything else
    return "I understand you're asking about \"${userPrompt}\". While I'm a simple assistant with limited capabilities, I can help with basic task organization, study planning, and anime tracking. For more specific features, try using the dedicated tools in the OtakuPlanner app.";
  }
}