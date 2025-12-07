import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// LeoAssist Chatbot Service - Connects to CATMS Assistance API
/// Optimized with parallel calls and timeouts for faster responses
class LeoAssistService {
  static const String _baseUrl = 'https://v7q4gmwfs544kyun3ta77hgy.agents.do-ai.run';
  static const String _agentId = '11e6bc4e-ad0a-11f0-b074-4e013e2ddde4';
  static const String _chatbotId = 'p2qYRpi8plPD9ygp-DUyk0HyVA08RNh0';
  
  // Optimized timeout
  static const Duration _apiTimeout = Duration(seconds: 12);
  
  // Reuse HTTP client for connection pooling
  static final http.Client _client = http.Client();
  
  String? _conversationId;
  
  /// Send a message - tries all endpoints in parallel for fastest response
  Future<String> sendMessage(String message) async {
    try {
      // Race all endpoints - first successful response wins
      return await Future.any([
        _callEndpoint1(message),
        _callEndpoint2(message).then((r) => Future.delayed(const Duration(milliseconds: 100), () => r)),
        _callEndpoint3(message).then((r) => Future.delayed(const Duration(milliseconds: 200), () => r)),
      ]).timeout(_apiTimeout);
    } on TimeoutException {
      return 'I apologize, the server is taking too long to respond. Please try again.';
    } catch (e) {
      return 'I apologize, I\'m having trouble connecting. Please check your internet and try again.';
    }
  }
  
  Future<String> _callEndpoint1(String message) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v1/chat'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'message': message,
        'agent_id': _agentId,
        'chatbot_id': _chatbotId,
        if (_conversationId != null) 'conversation_id': _conversationId,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['conversation_id'] != null) _conversationId = data['conversation_id'];
      final text = data['response'] ?? data['message'] ?? data['answer'];
      if (text != null && text.toString().isNotEmpty) return text.toString();
    }
    throw Exception('Endpoint 1 failed');
  }
  
  Future<String> _callEndpoint2(String message) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/chat/message'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'query': message,
        'agentId': _agentId,
        'chatbotId': _chatbotId,
        if (_conversationId != null) 'conversationId': _conversationId,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['conversationId'] != null) _conversationId = data['conversationId'];
      final text = data['answer'] ?? data['response'] ?? data['text'];
      if (text != null && text.toString().isNotEmpty) return text.toString();
    }
    throw Exception('Endpoint 2 failed');
  }
  
  Future<String> _callEndpoint3(String message) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v1/agents/$_agentId/chat'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'input': message,
        'chatbot_id': _chatbotId,
        if (_conversationId != null) 'session_id': _conversationId,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['session_id'] != null) _conversationId = data['session_id'];
      final text = data['output'] ?? data['response'] ?? data['text'];
      if (text != null && text.toString().isNotEmpty) return text.toString();
    }
    throw Exception('Endpoint 3 failed');
  }
  
  void resetConversation() => _conversationId = null;
}
