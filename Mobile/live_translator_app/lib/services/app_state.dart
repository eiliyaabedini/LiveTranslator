import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  String _apiKey = '';
  String _sourceLanguage = 'English';
  String _targetLanguage = 'Spanish';
  String _apiService = 'openai';
  bool _isTranslating = false;
  String _currentSpeaker = '';

  // Getters
  String get apiKey => _apiKey;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get apiService => _apiService;
  bool get isTranslating => _isTranslating;
  String get currentSpeaker => _currentSpeaker;

  // Language code mappings
  final Map<String, String> languageCodes = {
    'English': 'en-US',
    'Spanish': 'es-ES',
    'Farsi': 'fa-IR',
    'French': 'fr-FR',
    'German': 'de-DE',
    'Italian': 'it-IT',
    'Portuguese': 'pt-PT',
    'Russian': 'ru-RU',
    'Japanese': 'ja-JP',
    'Chinese': 'zh-CN',
    'Korean': 'ko-KR',
    'Arabic': 'ar-SA',
  };

  // Available languages
  List<String> get availableLanguages => languageCodes.keys.toList();

  AppState() {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('apiKey') ?? '';
    _sourceLanguage = prefs.getString('sourceLanguage') ?? 'English';
    _targetLanguage = prefs.getString('targetLanguage') ?? 'Spanish';
    _apiService = prefs.getString('apiService') ?? 'openai';
    notifyListeners();
  }

  // Save settings
  Future<void> saveSettings({
    required String apiKey,
    required String sourceLanguage,
    required String targetLanguage,
    required String apiService,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    _apiKey = apiKey;
    _sourceLanguage = sourceLanguage;
    _targetLanguage = targetLanguage;
    _apiService = apiService;
    
    await prefs.setString('apiKey', apiKey);
    await prefs.setString('sourceLanguage', sourceLanguage);
    await prefs.setString('targetLanguage', targetLanguage);
    await prefs.setString('apiService', apiService);
    
    notifyListeners();
  }

  // Set translation status
  void setTranslationStatus(bool isTranslating) {
    _isTranslating = isTranslating;
    notifyListeners();
  }

  // Set current speaker
  void setCurrentSpeaker(String speaker) {
    _currentSpeaker = speaker;
    notifyListeners();
  }

  // Swap languages
  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    
    // Save to SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('sourceLanguage', _sourceLanguage);
      prefs.setString('targetLanguage', _targetLanguage);
    });
    
    notifyListeners();
  }
}