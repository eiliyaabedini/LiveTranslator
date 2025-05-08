import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';
import 'webrtc_service.dart';
import '../utils/constants.dart';

class TranslationService {
  WebRTCService? _webrtcService;
  final ApiService _apiService;
  
  // Status callbacks
  final Function(bool) onStatusChange;
  final Function(String) onSpeakerChange;
  final Function(String) onError;
  
  TranslationService({
    required String apiKey,
    required this.onStatusChange,
    required this.onSpeakerChange,
    required this.onError,
  }) : _apiService = ApiService(apiKey: apiKey);
  
  // Start translation
  Future<void> startTranslation({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Check microphone permission
      final micPermission = await Permission.microphone.request();
      if (micPermission != PermissionStatus.granted) {
        onError(AppConstants.micPermissionDenied);
        return;
      }
      
      // Create WebRTC service
      _webrtcService = WebRTCService(
        apiService: _apiService,
        onSpeakerChange: onSpeakerChange,
        onError: onError,
        onConnectionClosed: () {
          onStatusChange(false);
          onError(AppConstants.connectionError);
        },
      );
      
      // Start translation
      await _webrtcService?.startTranslation(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      
      // Update status
      onStatusChange(true);
      
    } catch (e) {
      onError('Error starting translation: $e');
      await stopTranslation();
    }
  }
  
  // Stop translation
  Future<void> stopTranslation() async {
    try {
      await _webrtcService?.stopTranslation();
      _webrtcService = null;
      onStatusChange(false);
      onSpeakerChange('');
    } catch (e) {
      onError('Error stopping translation: $e');
    }
  }
  
  // Dispose
  Future<void> dispose() async {
    await _webrtcService?.dispose();
  }
}