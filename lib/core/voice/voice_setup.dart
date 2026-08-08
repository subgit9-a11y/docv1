import 'dart:io';
import 'voice_service.dart';

/// Voice Setup
///
/// Configuration helper for Sarvam AI voice services.
/// 
/// IMPORTANT: Never hardcode API keys in source code.
/// API keys are loaded from .env file (which is in .gitignore).
///
/// Setup in main.dart:
/// ```dart
/// import 'package:doctro/core/voice/voice_setup.dart';
///
/// void main() async {
///   await VoiceSetup.loadFromEnv();
///   runApp(MyApp());
/// }
/// ```
class VoiceSetup {
  VoiceSetup._();

  static bool _isConfigured = false;

  /// Load configuration from .env file
  /// 
  /// Returns true if configuration was loaded successfully
  static Future<bool> loadFromEnv() async {
    try {
      // Try to read from .env file
      final envFile = File('.env');
      if (await envFile.exists()) {
        final contents = await envFile.readAsString();
        final lines = contents.split('\n');
        
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
          
          final parts = trimmed.split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            
            if (key == 'SARVAM_API_KEY' && value.isNotEmpty) {
              configure(sarvamApiKey: value);
              return true;
            }
          }
        }
      }
      
      // Fallback: try environment variable
      final envKey = Platform.environment['SARVAM_API_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        configure(sarvamApiKey: envKey);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Configure voice services with API keys
  /// 
  /// [sarvamApiKey] - Sarvam AI API key for STT/TTS
  static void configure({
    required String sarvamApiKey,
  }) {
    if (sarvamApiKey.isEmpty) {
      throw ArgumentError('Sarvam API key cannot be empty');
    }

    final voiceService = VoiceService();
    voiceService.setApiKey(sarvamApiKey);
    
    _isConfigured = true;
  }

  /// Check if voice services are configured
  static bool get isConfigured => _isConfigured;

  /// Get configuration status message
  static String get statusMessage {
    if (_isConfigured) {
      return 'Voice services configured';
    }
    return 'Voice services NOT configured - call VoiceSetup.loadFromEnv()';
  }
}
