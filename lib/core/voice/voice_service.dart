import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:doctro/core/astra/utils/astra_config.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// Voice Service
///
/// Handles Sarvam AI integration for speech-to-text and text-to-speech.
/// This service communicates with the FastAPI backend which wraps Sarvam AI.
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  
  factory VoiceService() => _instance;
  VoiceService._internal();

  /// Base URL for voice API (through FastAPI backend)
  String get _baseUrl => AstraConfig.baseUrl;
  
  /// Sarvam API key - set via environment variable or runtime
  /// DO NOT hardcode API keys in source code
  String? _sarvamApiKey;
  
  /// Set the Sarvam API key (call this during app initialization)
  void setApiKey(String key) {
    _sarvamApiKey = key;
    AstraLogger.d('Sarvam API key configured', tag: 'VoiceService');
  }
  
  /// Get API key from environment or runtime config
  String get _apiKey {
    if (_sarvamApiKey != null) return _sarvamApiKey!;
    
    // Try environment variable first
    const apiKey = String.fromEnvironment('SARVAM_API_KEY', defaultValue: '');
    if (apiKey.isNotEmpty) return apiKey;
    
    // Fallback: log warning (do not return empty string)
    AstraLogger.w('Sarvam API key not configured', tag: 'VoiceService');
    return '';
  }

  // ============================================================
  // SPEECH TO TEXT (STT)
  // ============================================================

  /// Convert speech to text using Sarvam STT
  Future<VoiceResult> speechToText({
    required File audioFile,
    String language = 'en-IN',
  }) async {
    // Validate API key
    if (_apiKey.isEmpty) {
      throw VoiceException(
        'Sarvam API key not configured. Call VoiceService().setApiKey(key) first.',
        VoiceErrorType.permissionDenied,
      );
    }

    try {
      AstraLogger.d('Starting STT conversion', tag: 'VoiceService');

      final uri = Uri.parse('$_baseUrl/api/voice/stt');
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'application/json';

      // Add audio file
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        filename: 'recording.wav',
      ));

      // Add language parameter
      request.fields['language'] = language;

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw VoiceException('STT timeout', VoiceErrorType.timeout),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['text'] as String? ?? '';
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;

        AstraLogger.i('STT result: $text', tag: 'VoiceService');
        return VoiceResult(
          text: text,
          confidence: confidence,
          language: language,
          success: true,
        );
      } else {
        throw VoiceException(
          'STT failed: ${response.statusCode}',
          VoiceErrorType.serverError,
        );
      }
    } catch (e) {
      AstraLogger.e('STT error', error: e, tag: 'VoiceService');
      if (e is VoiceException) rethrow;
      throw VoiceException('STT failed: $e', VoiceErrorType.unknown);
    }
  }

  /// Stream audio and get real-time transcription
  Stream<VoiceResult> streamSpeechToText({
    required Stream<List<int>> audioStream,
    String language = 'en-IN',
  }) async* {
    // Note: Real-time streaming requires WebSocket
    // For now, we accumulate and send in chunks
    final chunks = <int>[];

    await for (final chunk in audioStream) {
      chunks.addAll(chunk);
    }

    if (chunks.isNotEmpty) {
      final tempFile = File('${Directory.systemTemp.path}/stream_audio.wav');
      await tempFile.writeAsBytes(chunks);
      
      yield await speechToText(audioFile: tempFile, language: language);
      await tempFile.delete();
    }
  }

  // ============================================================
  // TEXT TO SPEECH (TTS)
  // ============================================================

  /// Convert text to speech using Sarvam TTS
  Future<VoiceAudio> textToSpeech({
    required String text,
    String language = 'en-IN',
    String speaker = 'sage',
    double speed = 1.0,
  }) async {
    // Validate API key
    if (_apiKey.isEmpty) {
      throw VoiceException(
        'Sarvam API key not configured. Call VoiceService().setApiKey(key) first.',
        VoiceErrorType.permissionDenied,
      );
    }

    try {
      AstraLogger.d('Starting TTS conversion', tag: 'VoiceService');

      final uri = Uri.parse('$_baseUrl/api/voice/tts');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'language': language,
          'speaker': speaker,
          'speed': speed,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw VoiceException('TTS timeout', VoiceErrorType.timeout),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioBase64 = data['audio'] as String?;
        
        if (audioBase64 == null) {
          throw VoiceException('No audio data in response', VoiceErrorType.parseError);
        }

        final audioBytes = base64Decode(audioBase64);
        final audioFile = File(
          '${Directory.systemTemp.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav',
        );
        await audioFile.writeAsBytes(audioBytes);

        AstraLogger.i('TTS result: ${audioFile.path}', tag: 'VoiceService');
        return VoiceAudio(
          file: audioFile,
          duration: Duration(seconds: (text.length / 10).ceil()),
          language: language,
        );
      } else {
        throw VoiceException(
          'TTS failed: ${response.statusCode}',
          VoiceErrorType.serverError,
        );
      }
    } catch (e) {
      AstraLogger.e('TTS error', error: e, tag: 'VoiceService');
      if (e is VoiceException) rethrow;
      throw VoiceException('TTS failed: $e', VoiceErrorType.unknown);
    }
  }

  // ============================================================
  // LANGUAGE SUPPORT
  // ============================================================

  /// Get supported languages for voice
  static List<VoiceLanguage> get supportedLanguages => [
    VoiceLanguage(code: 'en-IN', name: 'English (India)', nativeName: 'English'),
    VoiceLanguage(code: 'hi-IN', name: 'Hindi', nativeName: 'हिंदी'),
    VoiceLanguage(code: 'bn-IN', name: 'Bengali', nativeName: 'বাংলা'),
    VoiceLanguage(code: 'ta-IN', name: 'Tamil', nativeName: 'தமிழ்'),
    VoiceLanguage(code: 'te-IN', name: 'Telugu', nativeName: 'తెలుగు'),
    VoiceLanguage(code: 'mr-IN', name: 'Marathi', nativeName: 'मराठी'),
    VoiceLanguage(code: 'gu-IN', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    VoiceLanguage(code: 'kn-IN', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    VoiceLanguage(code: 'ml-IN', name: 'Malayalam', nativeName: 'മലയാളം'),
    VoiceLanguage(code: 'pa-IN', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
  ];

  /// Check if language is supported
  static bool isLanguageSupported(String code) {
    return supportedLanguages.any((l) => l.code == code);
  }
}

/// Voice language model
class VoiceLanguage {
  final String code;
  final String name;
  final String nativeName;

  VoiceLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

/// Voice result from STT
class VoiceResult {
  final String text;
  final double confidence;
  final String language;
  final bool success;
  final String? error;

  VoiceResult({
    required this.text,
    required this.confidence,
    required this.language,
    required this.success,
    this.error,
  });

  bool get isHighConfidence => confidence > 0.8;
  bool get isLowConfidence => confidence < 0.5;
}

/// Voice audio from TTS
class VoiceAudio {
  final File file;
  final Duration duration;
  final String language;

  VoiceAudio({
    required this.file,
    required this.duration,
    required this.language,
  });

  /// Get file path
  String get path => file.path;
}

/// Voice error types
enum VoiceErrorType {
  unknown,
  timeout,
  networkError,
  serverError,
  parseError,
  permissionDenied,
  noAudio,
}

/// Voice exception
class VoiceException implements Exception {
  final String message;
  final VoiceErrorType type;

  VoiceException(this.message, this.type);

  @override
  String toString() => 'VoiceException: $message (${type.name})';

  bool get isNetworkError => type == VoiceErrorType.networkError;
  bool get isTimeout => type == VoiceErrorType.timeout;
  bool get isServerError => type == VoiceErrorType.serverError;
}
