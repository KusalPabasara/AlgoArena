import 'dart:convert';
import 'package:http/http.dart' as http;

/// LeoAssist Chatbot Service - Connects to CATMS Assistance API
/// Based on the chatbot widget configuration:
/// - Agent ID: 11e6bc4e-ad0a-11f0-b074-4e013e2ddde4
/// - Chatbot ID: p2qYRpi8plPD9ygp-DUyk0HyVA08RNh0
class LeoAssistService {
  static const String _baseUrl = 'https://v7q4gmwfs544kyun3ta77hgy.agents.do-ai.run';
  static const String _agentId = '11e6bc4e-ad0a-11f0-b074-4e013e2ddde4';
  static const String _chatbotId = 'p2qYRpi8plPD9ygp-DUyk0HyVA08RNh0';
  
  String? _conversationId;
  
  /// Send a message to the chatbot and get a response
  Future<String> sendMessage(String message) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/chat');
      
      final body = {
        'message': message,
        'agent_id': _agentId,
        'chatbot_id': _chatbotId,
        if (_conversationId != null) 'conversation_id': _conversationId,
      };
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Store conversation ID for context
        if (data['conversation_id'] != null) {
          _conversationId = data['conversation_id'];
        }
        
        // Return the bot's response
        return data['response'] ?? data['message'] ?? 'I apologize, I couldn\'t process your request.';
      } else {
        // Try alternative endpoint
        return await _sendMessageAlternative(message);
      }
    } catch (e) {
      // Try alternative approach
      return await _sendMessageAlternative(message);
    }
  }
  
  /// Alternative method using different endpoint structure
  Future<String> _sendMessageAlternative(String message) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/chat/message');
      
      final body = {
        'query': message,
        'agentId': _agentId,
        'chatbotId': _chatbotId,
        if (_conversationId != null) 'conversationId': _conversationId,
      };
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['conversationId'] != null) {
          _conversationId = data['conversationId'];
        }
        
        return data['answer'] ?? data['response'] ?? data['text'] ?? 'I apologize, I couldn\'t process your request.';
      } else {
        // Try streaming endpoint
        return await _sendMessageStreaming(message);
      }
    } catch (e) {
      return await _sendMessageStreaming(message);
    }
  }
  
  /// Streaming endpoint approach
  Future<String> _sendMessageStreaming(String message) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/agents/$_agentId/chat');
      
      final body = {
        'input': message,
        'chatbot_id': _chatbotId,
        if (_conversationId != null) 'session_id': _conversationId,
      };
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['session_id'] != null) {
          _conversationId = data['session_id'];
        }
        
        return data['output'] ?? data['response'] ?? data['text'] ?? _getLocalResponse(message);
      } else {
        return _getLocalResponse(message);
      }
    } catch (e) {
      return _getLocalResponse(message);
    }
  }
  
  /// Local fallback responses for common questions
  String _getLocalResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('leoassist') || lowerMessage.contains('leo assist')) {
      return 'LeoAssist is your AI-powered assistant designed to help Leo Club members with information about activities, events, and community service initiatives. I\'m here to make your Leo experience better!';
    }
    
    if (lowerMessage.contains('leo club') || lowerMessage.contains('what is leo')) {
      return 'Leo Club is a youth organization sponsored by Lions Clubs International. It stands for Leadership, Experience, and Opportunity. Leo members participate in community service projects, develop leadership skills, and make a positive impact in their communities. Would you like to know more about specific activities?';
    }
    
    if (lowerMessage.contains('faq') || lowerMessage.contains('question')) {
      return 'Here are some frequently asked questions:\n\n• How do I join a Leo Club?\n• What activities do Leo Clubs organize?\n• How can I start a Leo Club?\n• What are the benefits of being a Leo?\n\nFeel free to ask about any of these topics!';
    }
    
    if (lowerMessage.contains('join') || lowerMessage.contains('member')) {
      return 'To join a Leo Club, you can:\n\n1. Find a local Leo Club in your area\n2. Contact your school\'s Leo Club advisor\n3. Reach out to a local Lions Club for sponsorship\n4. Visit the Lions Clubs International website\n\nLeo membership is open to young people ages 12-30!';
    }
    
    if (lowerMessage.contains('event') || lowerMessage.contains('activity')) {
      return 'Leo Clubs organize various activities including:\n\n• Community service projects\n• Environmental initiatives\n• Youth leadership workshops\n• Fundraising events\n• Social gatherings\n\nCheck the Events page for upcoming activities in your area!';
    }
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      return 'Hello! I\'m LeoAssist, your AI companion for all things Leo Club. How can I help you today? You can ask me about Leo Clubs, membership, events, or any other questions you might have!';
    }
    
    if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! If you have any more questions, feel free to ask. I\'m here to help make your Leo experience amazing! 🦁';
    }
    
    if (lowerMessage.contains('help')) {
      return 'I can help you with:\n\n• Information about Leo Clubs\n• Membership questions\n• Event details\n• Leadership resources\n• Community service ideas\n\nJust type your question and I\'ll do my best to assist you!';
    }
    
    return 'Thank you for your message! I\'m LeoAssist, and I\'m here to help with any questions about Leo Club activities, membership, events, or community service. Could you please rephrase your question or ask about a specific topic?';
  }
  
  /// Reset conversation
  void resetConversation() {
    _conversationId = null;
  }
}
