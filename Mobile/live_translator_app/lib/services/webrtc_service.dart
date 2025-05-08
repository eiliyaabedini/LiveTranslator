import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../utils/constants.dart';

class WebRTCService {
  // WebRTC connection
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCDataChannel? _dataChannel;
  final _audioElement = RTCVideoRenderer();
  
  // API service
  final ApiService _apiService;
  
  // Status callbacks
  final Function(String) onSpeakerChange;
  final Function(String) onError;
  final Function() onConnectionClosed;
  
  WebRTCService({
    required ApiService apiService,
    required this.onSpeakerChange,
    required this.onError,
    required this.onConnectionClosed,
  }) : _apiService = apiService {
    _initAudioElement();
  }
  
  Future<void> _initAudioElement() async {
    await _audioElement.initialize();
  }
  
  Future<void> dispose() async {
    await stopTranslation();
    await _audioElement.dispose();
  }
  
  // Start translation with WebRTC
  Future<void> startTranslation({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Get user media
      final mediaConstraints = <String, dynamic>{
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      };
      
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      
      // Get session token
      final sessionData = await _apiService.getDirectSession(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      
      // Initialize WebRTC with the token
      await _initializeWebRTC(sessionData);
      
      // Set the initial speaker
      onSpeakerChange(AppConstants.youSpeaking);
      
    } catch (e) {
      onError('Error starting translation: $e');
      await stopTranslation();
      rethrow;
    }
  }
  
  // Initialize WebRTC connection
  Future<void> _initializeWebRTC(Map<String, dynamic> sessionData) async {
    try {
      final ephemeralKey = sessionData['client_secret']['value'];
      
      // Create peer connection
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      });
      
      // Set up to play remote audio
      _audioElement.srcObject = await createLocalMediaStream('remote');
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        _handleTrack(event);
      };
      
      // Add local audio track
      if (_localStream != null) {
        _localStream!.getAudioTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }
      
      // Create data channel for events
      _dataChannel = await _peerConnection!.createDataChannel(
        'oai-events',
        RTCDataChannelInit(),
      );
      _dataChannel!.onMessage = (message) {
        // Handle events from the realtime server
        print('Event received: ${message.text}');
      };
      
      // Set up event handlers
      _peerConnection!.onIceCandidate = (candidate) {
        print('ICE candidate: ${candidate.toMap()}');
      };
      
      _peerConnection!.onConnectionState = (state) {
        print('Connection state changed: $state');
        
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          onConnectionClosed();
        }
      };
      
      _peerConnection!.onIceConnectionState = (state) {
        print('ICE connection state: $state');
      };
      
      // Create offer
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      
      await _peerConnection!.setLocalDescription(offer);
      
      // Send the offer to OpenAI's realtime API
      final model = ApiConstants.defaultModel;
      final url = '${ApiConstants.realtimeEndpoint}?model=$model';
      
      final sdpResponse = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $ephemeralKey',
          'Content-Type': 'application/sdp',
        },
        body: offer.sdp,
      );
      
      if (sdpResponse.statusCode != 200) {
        throw Exception('SDP response error: ${sdpResponse.statusCode}');
      }
      
      // Set the remote description with the answer
      final answer = RTCSessionDescription(
        sdpResponse.body,
        'answer',
      );
      
      await _peerConnection!.setRemoteDescription(answer);
      print('WebRTC connection established successfully');
      
    } catch (e) {
      print('Error initializing WebRTC: $e');
      throw e;
    }
  }
  
  // Handle audio track from peer connection
  void _handleTrack(RTCTrackEvent event) {
    print('Track received: ${event.track.kind}');
    
    if (event.track.kind == 'audio') {
      // Connect the remote audio track to the audio element
      final remoteStream = _audioElement.srcObject;
      remoteStream?.addTrack(event.track);
      _audioElement.srcObject = remoteStream;
      
      // Set the volume
      _audioElement.volume = 0.8; // Fixed at 80%
      
      // Update the speaker indicator
      onSpeakerChange(AppConstants.otherSpeaking);
    }
  }
  
  // Stop translation
  Future<void> stopTranslation() async {
    // Close peer connection
    if (_peerConnection != null) {
      _dataChannel?.close();
      await _peerConnection!.close();
      _peerConnection = null;
    }
    
    // Stop microphone access
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) => track.stop());
      _localStream = null;
    }
    
    // Clear audio element
    _audioElement.srcObject = null;
  }
}