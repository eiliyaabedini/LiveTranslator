class ApiConstants {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String realtimeSessionsEndpoint = '$baseUrl/realtime/sessions';
  static const String realtimeEndpoint = '$baseUrl/realtime';
  static const String defaultModel = 'gpt-4o-mini-realtime-preview-2024-12-17';
  static const String defaultVoice = 'shimmer';
  
  // This would typically be your backend server
  static const String proxyServerUrl = 'http://10.0.2.2:3000'; // For Android emulator
  // Use http://localhost:3000 for iOS simulator
}

class AppConstants {
  // App settings
  static const String appName = 'LiveTranslator';
  static const String apiKeyPrefKey = 'apiKey';
  static const String sourceLanguagePrefKey = 'sourceLanguage';
  static const String targetLanguagePrefKey = 'targetLanguage';
  static const String apiServicePrefKey = 'apiService';
  
  // Status messages
  static const String readyToTranslate = 'Ready to translate';
  static const String connecting = 'Connecting...';
  static const String translatingFormat = 'Translating: %s ↔ %s';
  static const String youSpeaking = 'You are speaking...';
  static const String otherSpeaking = 'Other person speaking...';
  
  // Error messages
  static const String micPermissionDenied = 'Microphone permission denied';
  static const String connectionError = 'Connection error. Please try again.';
  static const String apiKeyMissing = 'Please add your OpenAI API key in settings';
}