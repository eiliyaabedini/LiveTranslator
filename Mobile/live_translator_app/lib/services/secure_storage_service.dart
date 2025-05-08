import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // API key constants
  static const String apiKeyKey = 'openai_api_key';
  
  // Save API key securely
  Future<void> saveApiKey(String apiKey) async {
    await _secureStorage.write(key: apiKeyKey, value: apiKey);
  }
  
  // Get API key
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: apiKeyKey);
  }
  
  // Delete API key
  Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: apiKeyKey);
  }
  
  // Check if API key exists
  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
}