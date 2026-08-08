import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:doctro/core/voice/voice_service.dart';
import 'package:doctro/core/voice/voice_recorder.dart';
import 'package:doctro/core/voice/voice_player.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// Voice Controller
///
/// Manages voice input/output for Astra AI conversations.
/// Coordinates between recorder, player, and Astra service.
class VoiceController extends ChangeNotifier {
  static final VoiceController _instance = VoiceController._internal();
  
  factory VoiceController() => _instance;
  VoiceController._internal();

  final VoiceService _voiceService = VoiceService();

  // State
  VoiceState _state = VoiceState.idle;
  VoiceState get state => _state;
  
  bool get isRecording => _state == VoiceState.recording;
  bool get isTranscribing => _state == VoiceState.transcribing;
  bool get isPlaying => _state == VoiceState.playing;
  bool get isIdle => _state == VoiceState.idle;
  bool get isError => _state == VoiceState.error;

  // Recording
  File? _lastRecording;
  File? get lastRecording => _lastRecording;

  // Transcription
  VoiceResult? _lastTranscription;
  VoiceResult? get lastTranscription => _lastTranscription;
  String get transcribedText => _lastTranscription?.text ?? '';

  // Playback
  VoiceAudio? _lastTtsAudio;
  VoiceAudio? get lastTtsAudio => _lastTtsAudio;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Settings
  String _language = 'en-IN';
  String get language => _language;

  // ============================================================
  // SETUP
  // ============================================================

  /// Set voice language
  void setLanguage(String languageCode) {
    if (VoiceService.isLanguageSupported(languageCode)) {
      _language = languageCode;
      AstraLogger.d('Voice language set to: $languageCode');
      notifyListeners();
    }
  }

  // ============================================================
  // RECORD & TRANSCRIBE
  // ============================================================

  /// Start recording audio
  Future<void> startRecording({
    VoidCallback? onRecordingComplete,
  }) async {
    try {
      _state = VoiceState.recording;
      _errorMessage = null;
      notifyListeners();

      AstraLogger.d('Voice recording started', tag: 'VoiceController');
    } catch (e) {
      _handleError('Failed to start recording: $e');
    }
  }

  /// Stop recording and transcribe
  Future<void> stopRecordingAndTranscribe({
    required File audioFile,
  }) async {
    try {
      _state = VoiceState.transcribing;
      _lastRecording = audioFile;
      notifyListeners();

      AstraLogger.d('Transcribing audio...', tag: 'VoiceController');

      final result = await _voiceService.speechToText(
        audioFile: audioFile,
        language: _language,
      );

      _lastTranscription = result;
      _state = VoiceState.idle;
      
      if (result.isLowConfidence) {
        AstraLogger.w('Low transcription confidence: ${result.confidence}');
      }

      notifyListeners();
      AstraLogger.i('Transcription complete: ${result.text}', tag: 'VoiceController');
    } catch (e) {
      _handleError('Transcription failed: $e');
    }
  }

  /// Transcribe existing audio file
  Future<VoiceResult> transcribeFile(File audioFile) async {
    try {
      _state = VoiceState.transcribing;
      notifyListeners();

      final result = await _voiceService.speechToText(
        audioFile: audioFile,
        language: _language,
      );

      _lastTranscription = result;
      _state = VoiceState.idle;
      notifyListeners();

      return result;
    } catch (e) {
      _handleError('Transcription failed: $e');
      rethrow;
    }
  }

  // ============================================================
  // TEXT TO SPEECH
  // ============================================================

  /// Convert text to speech
  Future<VoiceAudio> speak({
    required String text,
    String? language,
    String speaker = 'sage',
  }) async {
    try {
      _state = VoiceState.speaking;
      notifyListeners();

      AstraLogger.d('Converting text to speech...', tag: 'VoiceController');

      final audio = await _voiceService.textToSpeech(
        text: text,
        language: language ?? _language,
        speaker: speaker,
      );

      _lastTtsAudio = audio;
      _state = VoiceState.playing;
      notifyListeners();

      AstraLogger.i('TTS complete: ${audio.path}', tag: 'VoiceController');
      return audio;
    } catch (e) {
      _handleError('Text to speech failed: $e');
      rethrow;
    }
  }

  /// Play TTS audio
  Future<void> playTtsAudio(VoiceAudio audio) async {
    _lastTtsAudio = audio;
    _state = VoiceState.playing;
    notifyListeners();
  }

  /// Stop playback
  void stopPlayback() {
    _state = VoiceState.idle;
    notifyListeners();
  }

  // ============================================================
  // COMPLETE VOICE FLOW
  // ============================================================

  /// Complete voice flow: record -> transcribe -> get AI response -> speak
  /// This coordinates the entire voice conversation cycle.
  Future<VoiceConversationResult> completeVoiceFlow({
    required File audioFile,
    required Future<String> Function(String text) getAIResponse,
    VoidCallback? onTranscription,
    VoidCallback? onSpeechReady,
    VoidCallback? onPlaybackComplete,
  }) async {
    VoiceConversationResult result = VoiceConversationResult();

    try {
      // Step 1: Transcribe
      result.transcription = await transcribeFile(audioFile);
      onTranscription?.call();

      if (result.transcription!.text.isEmpty) {
        throw VoiceException('No speech detected', VoiceErrorType.noAudio);
      }

      // Step 2: Get AI response
      result.aiResponse = await getAIResponse(result.transcription!.text);

      // Step 3: Convert response to speech
      result.speechAudio = await speak(text: result.aiResponse!);
      onSpeechReady?.call();

      // Step 4: Mark as ready for playback
      result.success = true;
      _state = VoiceState.idle;
      notifyListeners();

      return result;
    } catch (e) {
      result.error = e.toString();
      _handleError(result.error!);
      return result;
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  void _handleError(String message) {
    _state = VoiceState.error;
    _errorMessage = message;
    AstraLogger.e('Voice error', error: message, tag: 'VoiceController');
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == VoiceState.error) {
      _state = VoiceState.idle;
    }
    notifyListeners();
  }

  /// Reset to idle state
  void reset() {
    _state = VoiceState.idle;
    _errorMessage = null;
    _lastTranscription = null;
    _lastRecording = null;
    _lastTtsAudio = null;
    notifyListeners();
  }

  // ============================================================
  // UTILITIES
  // ============================================================

  /// Get supported languages
  List<VoiceLanguage> get supportedLanguages => VoiceService.supportedLanguages;

  /// Get language display name
  String getLanguageName(String code) {
    final language = supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => VoiceLanguage(code: code, name: code, nativeName: code),
    );
    return '${language.name} (${language.nativeName})';
  }
}

/// Voice state enum
enum VoiceState {
  idle,
  recording,
  transcribing,
  speaking,
  playing,
  error,
}

/// Result of a complete voice conversation
class VoiceConversationResult {
  VoiceResult? transcription;
  String? aiResponse;
  VoiceAudio? speechAudio;
  bool success = false;
  String? error;

  bool get hasTranscription => transcription != null;
  bool get hasAIResponse => aiResponse != null;
  bool get hasSpeech => speechAudio != null;
}
