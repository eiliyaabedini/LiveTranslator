import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About This App'),
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
            const Text(
              "This app uses OpenAI's GPT-4o-mini-realtime-preview API with WebRTC to provide real-time voice translation between different languages.",
              style: TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'How to use:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildNumberedList([
              'Enter your OpenAI API key in the settings',
              'Select your language and the target language',
              'Click the microphone button to start',
              'Speak in your language',
              'The app translates your speech in real-time',
              'When the other person speaks, it automatically translates back to your language',
              'Click the microphone button again to stop',
            ]),
            
            const SizedBox(height: 24),
            
            const Text(
              'Your API key and conversations remain secure and are sent directly to OpenAI\'s servers using encrypted WebRTC connections. No proxy server is required.',
              style: TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Note: This mobile app is the Flutter version of the LiveTranslator web application, with the same functionality and user experience.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}