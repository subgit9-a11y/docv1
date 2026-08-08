import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:doctro/core/voice/voice_service.dart';
import 'package:doctro/theme/ayureze_theme.dart';

/// Voice Player Widget
///
/// Provides a UI for playing audio responses from TTS.
class VoicePlayer extends StatefulWidget {
  /// Audio file to play
  final File audioFile;
  
  /// Callback when playback completes
  final VoidCallback? onComplete;
  
  /// Callback on error
  final void Function(String error)? onError;
  
  /// Whether to auto-play on load
  final bool autoPlay;
  
  /// Visual style
  final VoicePlayerStyle style;

  const VoicePlayer({
    super.key,
    required this.audioFile,
    this.onComplete,
    this.onError,
    this.autoPlay = false,
    this.style = VoicePlayerStyle.compact,
  });

  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  final AudioPlayer _player = AudioPlayer();
  
  bool _isPlaying = false;
  bool _isLoaded = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _setupPlayer() async {
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _player.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
          _isLoaded = true;
        });
      }
    });

    _player.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        widget.onComplete?.call();
      }
    });

    try {
      await _player.setSource(DeviceFileSource(widget.audioFile.path));
      if (widget.autoPlay) {
        await _player.resume();
      }
    } catch (e) {
      widget.onError?.call('Failed to load audio: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    setState(() => _position = Duration.zero);
  }

  Future<void> _setSpeed(double speed) async {
    await _player.setPlaybackRate(speed);
    setState(() => _playbackSpeed = speed);
  }

  void _seekTo(double value) {
    final position = Duration(milliseconds: (value * _duration.inMilliseconds).round());
    _player.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case VoicePlayerStyle.compact:
        return _buildCompactPlayer();
      case VoicePlayerStyle.expanded:
        return _buildExpandedPlayer();
      case VoicePlayerStyle.minimal:
        return _buildMinimalPlayer();
    }
  }

  Widget _buildCompactPlayer() {
    return Semantics(
      label: _isPlaying ? 'Playing audio. Tap to pause' : 'Paused. Tap to play',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AyurezeTheme.healingGreen50.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayButton(),
            if (_isLoaded && _duration.inSeconds > 0) ...[
              const SizedBox(width: 8),
              _buildProgressIndicator(),
              const SizedBox(width: 8),
              _buildDurationText(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer() {
    return Semantics(
      label: _isPlaying ? 'Playing audio' : 'Paused',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AyurezeTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AyurezeTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: AyurezeTheme.healingGreen50,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Voice Response',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AyurezeTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                _buildSpeedSelector(),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoaded && _duration.inSeconds > 0) ...[
              _buildProgressBar(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDurationText(),
                  _buildPlayButton(iconSize: 32),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalPlayer() {
    return Semantics(
      label: _isPlaying ? 'Playing' : 'Play',
      button: true,
      child: InkWell(
        onTap: _togglePlayPause,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AyurezeTheme.healingGreen50.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: AyurezeTheme.healingGreen50,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton({double iconSize = 24}) {
    return Semantics(
      label: _isPlaying ? 'Pause' : 'Play',
      button: true,
      child: InkWell(
        onTap: _togglePlayPause,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AyurezeTheme.healingGreen50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (_duration.inMilliseconds == 0) return const SizedBox.shrink();
    
    final progress = _position.inMilliseconds / _duration.inMilliseconds;
    
    return SizedBox(
      width: 60,
      height: 4,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation(AyurezeTheme.healingGreen50),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_duration.inMilliseconds == 0) return const SizedBox.shrink();
    
    final progress = _position.inMilliseconds / _duration.inMilliseconds;
    
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AyurezeTheme.healingGreen50,
        inactiveTrackColor: Colors.grey.shade300,
        thumbColor: AyurezeTheme.healingGreen50,
        overlayColor: AyurezeTheme.healingGreen50.withOpacity(0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: _seekTo,
      ),
    );
  }

  Widget _buildDurationText() {
    final durationStr = _formatDuration(_duration);
    return Text(
      durationStr,
      style: TextStyle(
        fontSize: 12,
        color: AyurezeTheme.textSecondary,
      ),
    );
  }

  Widget _buildSpeedSelector() {
    final speeds = [0.75, 1.0, 1.25, 1.5];
    
    return PopupMenuButton<double>(
      initialValue: _playbackSpeed,
      onSelected: _setSpeed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_playbackSpeed}x',
              style: const TextStyle(fontSize: 12),
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => speeds.map((speed) {
        return PopupMenuItem<double>(
          value: speed,
          child: Text('${speed}x'),
        );
      }).toList(),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Voice player styles
enum VoicePlayerStyle {
  compact,
  expanded,
  minimal,
}

/// Waveform visualizer for voice input
class VoiceWaveform extends StatelessWidget {
  final bool isActive;
  final int barCount;
  final double height;

  const VoiceWaveform({
    super.key,
    this.isActive = false,
    this.barCount = 5,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isActive ? 'Recording audio' : 'Audio waveform',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 100)),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 3,
            height: isActive ? (height * (0.5 + (index % 3) * 0.25)) : height * 0.4,
            decoration: BoxDecoration(
              color: isActive 
                  ? AyurezeTheme.healingGreen50 
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
