import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/translation_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/language_selector.dart';
import '../widgets/mic_button.dart';
import 'settings_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.backgroundEndColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    const Icon(
                      FontAwesomeIcons.language,
                      size: 32,
                      color: AppTheme.primaryColor,
                    ),
                    
                    // Language selector
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LanguageSelector(
                          sourceLanguage: appState.sourceLanguage,
                          targetLanguage: appState.targetLanguage,
                          onSwap: () => appState.swapLanguages(),
                          onSourceChanged: (language) {
                            appState.saveSettings(
                              apiKey: appState.apiKey,
                              sourceLanguage: language,
                              targetLanguage: appState.targetLanguage,
                              apiService: appState.apiService,
                            );
                          },
                          onTargetChanged: (language) {
                            appState.saveSettings(
                              apiKey: appState.apiKey,
                              sourceLanguage: appState.sourceLanguage,
                              targetLanguage: language,
                              apiService: appState.apiService,
                            );
                          },
                          availableLanguages: appState.availableLanguages,
                        ),
                      ),
                    ),
                    
                    // Action buttons
                    Row(
                      children: [
                        // Settings button
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                          color: AppTheme.iconColor,
                        ),
                        
                        // Info button
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const InfoScreen()),
                            );
                          },
                          color: AppTheme.iconColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mic button and status
                      MicButton(
                        isTranslating: appState.isTranslating,
                        onPressed: () {
                          if (appState.apiKey.isEmpty) {
                            _showApiKeyMissing(context);
                            return;
                          }
                          
                          // Toggle translation status
                          if (appState.isTranslating) {
                            _stopTranslation(context);
                          } else {
                            _startTranslation(context);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Status text
                      Text(
                        appState.isTranslating 
                            ? AppConstants.translatingFormat
                                .replaceFirst('%s', appState.sourceLanguage)
                                .replaceFirst('%s', appState.targetLanguage)
                            : AppConstants.readyToTranslate,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Speaker indicator
                      if (appState.isTranslating && appState.currentSpeaker.isNotEmpty)
                        Text(
                          appState.currentSpeaker,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApiKeyMissing(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key Required'),
        content: const Text(AppConstants.apiKeyMissing),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: const Text('Go to Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Translation service instance
  TranslationService? _translationService;

  void _startTranslation(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (appState.apiKey.isEmpty) {
      _showApiKeyMissing(context);
      return;
    }
    
    // Create translation service if it doesn't exist
    _translationService ??= TranslationService(
      apiKey: appState.apiKey,
      onStatusChange: (isTranslating) {
        appState.setTranslationStatus(isTranslating);
      },
      onSpeakerChange: (speaker) {
        appState.setCurrentSpeaker(speaker);
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
    
    // Start translation
    _translationService!.startTranslation(
      sourceLanguage: appState.sourceLanguage,
      targetLanguage: appState.targetLanguage,
    );
  }

  void _stopTranslation(BuildContext context) {
    if (_translationService != null) {
      _translationService!.stopTranslation();
    }
  }
  
  @override
  void dispose() {
    _translationService?.dispose();
    super.dispose();
  }
}