import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:doctro/core/voice/voice_service.dart';
import 'package:doctro/theme/ayureze_theme.dart';

/// Voice Recorder Widget
///
/// Provides a UI for recording audio and converting to text.
/// Uses the device microphone for recording.
class VoiceRecorder extends StatefulWidget {
  /// Callback when recording completes with audio file
  final void Function(File audioFile)? onRecordingComplete;
  
  /// Callback when transcription is ready
  final void Function(VoiceResult result)? onTranscriptionComplete;
  
  /// Callback on error
  final void Function(String error)? onError;
  
  /// Whether to auto-transcribe after recording
  final bool autoTranscribe;
  
  /// Recording language (Sarvam language code)
  final String language;
  
  /// Button size
  final double size;
  
  /// Button color
  final Color? color;

  const VoiceRecorder({
    super.key,
    this.onRecordingComplete,
    this.onTranscriptionComplete,
    this.onError,
    this.autoTranscribe = true,
    this.language = 'en-IN',
    this.size = 56,
    this.color,
  });

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final VoiceService _voiceService = VoiceService();
  
  late AnimationController _animationController;
  
  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _hasPermission = false;
  
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _checkPermission();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _durationTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      setState(() => _hasPermission = hasPermission);
    } catch (e) {
      setState(() => _hasPermission = false);
    }
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      await _checkPermission();
      if (!_hasPermission) {
        widget.onError?.call('Microphone permission denied');
        return;
      }
    }

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _recordingDuration = Duration.zero;
      });

      _animationController.repeat(reverse: true);
      _startDurationTimer();
    } catch (e) {
      widget.onError?.call('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      _durationTimer?.cancel();
      _animationController.stop();
      _animationController.reset();

      final path = await _recorder.stop();
      if (path == null) {
        widget.onError?.call('No recording path');
        return;
      }

      final audioFile = File(path);
      widget.onRecordingComplete?.call(audioFile);

      if (widget.autoTranscribe) {
        await _transcribeAudio(audioFile);
      }

      setState(() {
        _isRecording = false;
        _recordingPath = null;
      });
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      widget.onError?.call('Failed to stop recording: $e');
    }
  }

  Future<void> _transcribeAudio(File audioFile) async {
    setState(() => _isTranscribing = true);

    try {
      final result = await _voiceService.speechToText(
        audioFile: audioFile,
        language: widget.language,
      );
      
      widget.onTranscriptionComplete?.call(result);
    } catch (e) {
      widget.onError?.call('Transcription failed: $e');
    } finally {
      setState(() => _isTranscribing = false);
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _isRecording 
          ? 'Recording audio. Tap to stop' 
          : 'Record audio. Tap to start',
      button: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRecordButton(),
          if (_isRecording) _buildDurationIndicator(),
          if (_isTranscribing) _buildTranscribingIndicator(),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    final color = widget.color ?? AyurezeTheme.healingGreen50;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = _isRecording 
            ? 1.0 + (_animationController.value * 0.2) 
            : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _isRecording ? _stopRecording : _startRecording,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isRecording ? Colors.red : color,
            boxShadow: [
              BoxShadow(
                color: (_isRecording ? Colors.red : color).withOpacity(0.3),
                blurRadius: _isRecording ? 20 : 10,
                spreadRadius: _isRecording ? 5 : 2,
              ),
            ],
          ),
          child: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: widget.size * 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationIndicator() {
    final minutes = _recordingDuration.inMinutes;
    final seconds = _recordingDuration.inSeconds % 60;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscribingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AyurezeTheme.healingGreen50,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Transcribing...',
            style: TextStyle(
              fontSize: 12,
              color: AyurezeTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact voice input button
class VoiceInputButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isListening;
  final double size;

  const VoiceInputButton({
    super.key,
    this.onTap,
    this.isListening = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isListening ? 'Stop listening' : 'Start voice input',
      button: true,
      child: Material(
        color: isListening 
            ? Colors.red 
            : AyurezeTheme.healingGreen50.withOpacity(0.1),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              isListening ? Icons.stop : Icons.mic,
              color: isListening ? Colors.white : AyurezeTheme.healingGreen50,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
