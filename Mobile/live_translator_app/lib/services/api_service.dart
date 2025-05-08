import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  final String apiKey;
  
  ApiService({required this.apiKey});

  // Get WebSocket token from proxy server
  Future<Map<String, dynamic>> getSession({
    required String sourceLanguage, 
    required String targetLanguage,
  }) async {
    try {
      final url = '${ApiConstants.proxyServerUrl}/session?sourceLanguage=$sourceLanguage&targetLanguage=$targetLanguage';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Failed to get session';
        throw Exception('API Error: ${response.statusCode} - $errorMessage');
      }
      
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error getting session: $e');
    }
  }

  // Get WebSocket token directly from OpenAI (without proxy)
  Future<Map<String, dynamic>> getDirectSession({
    required String sourceLanguage, 
    required String targetLanguage,
  }) async {
    try {
      final url = ApiConstants.realtimeSessionsEndpoint;
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': ApiConstants.defaultModel,
          'voice': ApiConstants.defaultVoice,
          'instructions': """
            You are a MECHANICAL TRANSLATION DEVICE. You DO NOT engage in conversation.
            
            Your ONLY function is to DIRECTLY TRANSLATE the exact words spoken, nothing more:
            
            - When the user speaks in $sourceLanguage: Translate those EXACT words into $targetLanguage
            - When the user speaks in $targetLanguage: Translate those EXACT words into $sourceLanguage
            
            CRITICAL RULES:
            - NEVER respond to questions - only translate them word for word
            - NEVER answer questions like "How are you?" - just translate the question itself
            - NEVER have opinions or provide information
            - NEVER engage in conversation or act as an assistant
            - NEVER add explanations, context, or your own words
            - NEVER make up responses or answer on behalf of anyone
            
            EXAMPLE:
            User: "How are you?" 
            YOU: "¿Cómo estás?" (CORRECT - just translated)
            NOT: "Estoy bien, gracias." (WRONG - you answered instead of translating)
            
            User: "What is the capital of France?"
            YOU: "¿Cuál es la capital de Francia?" (CORRECT - just translated)
            NOT: "La capital de Francia es París." (WRONG - you answered the question)
            
            You are ONLY a translation device, not a conversational AI.
          """,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Failed to get session';
        throw Exception('API Error: ${response.statusCode} - $errorMessage');
      }
      
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error getting direct session: $e');
    }
  }
}