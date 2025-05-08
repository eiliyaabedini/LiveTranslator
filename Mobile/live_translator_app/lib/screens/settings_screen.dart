import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late String _sourceLanguage;
  late String _targetLanguage;
  late String _apiService;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _apiKeyController = TextEditingController(text: appState.apiKey);
    _sourceLanguage = appState.sourceLanguage;
    _targetLanguage = appState.targetLanguage;
    _apiService = appState.apiService;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Key Input
            const Text(
              'OpenAI API Key',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                hintText: 'Enter your OpenAI API key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 4),
            const Text(
              'Your API key is stored locally and never sent to our servers',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Language Selection
            const Text(
              'Languages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Language',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _sourceLanguage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sourceLanguage = value;
                            });
                          }
                        },
                        items: appState.availableLanguages
                            .map((language) => DropdownMenuItem(
                                  value: language,
                                  child: Text(language),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Language',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _targetLanguage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _targetLanguage = value;
                            });
                          }
                        },
                        items: appState.availableLanguages
                            .map((language) => DropdownMenuItem(
                                  value: language,
                                  child: Text(language),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // API Selection
            const Text(
              'AI Service',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildApiServiceButton(
                    label: 'OpenAI',
                    value: 'openai',
                    icon: Icons.check,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildApiServiceButton(
                    label: 'Google Gemini',
                    value: 'gemini',
                    icon: null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiServiceButton({
    required String label,
    required String value,
    required IconData? icon,
  }) {
    final isSelected = _apiService == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _apiService = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFCBD5E1),
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && isSelected) ...[
              Icon(
                icon,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    appState.saveSettings(
      apiKey: _apiKeyController.text,
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
      apiService: _apiService,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }
}