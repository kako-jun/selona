import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/media_file.dart';

/// Video player widget with controls
class VideoPlayerWidget extends StatefulWidget {
  final MediaFile file;
  final bool showControls;

  const VideoPlayerWidget({
    super.key,
    required this.file,
    this.showControls = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isMuted = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    // TODO: Initialize with decrypted video data
    // For now, show placeholder
    setState(() {
      _isInitialized = false;
    });
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _toggleMute() {
    if (_controller == null) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _setPlaybackSpeed(double speed) {
    if (_controller == null) return;

    setState(() {
      _playbackSpeed = speed;
      _controller!.setPlaybackSpeed(speed);
    });
  }

  void _seekRelative(Duration offset) {
    if (_controller == null) return;

    final current = _controller!.value.position;
    final duration = _controller!.value.duration;
    var newPosition = current + offset;

    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > duration) {
      newPosition = duration;
    }

    _controller!.seekTo(newPosition);
  }

  void _stepFrame(bool forward) {
    // Approximately 1/30th of a second
    _seekRelative(Duration(milliseconds: forward ? 33 : -33));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildPlaceholder();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),

        // Video controls overlay
        if (widget.showControls)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: _buildVideoControls(),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam,
            size: 80,
            color: SelonaColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            widget.file.name,
            style: const TextStyle(
              color: SelonaColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatFileSize(widget.file.fileSize),
            style: const TextStyle(
              color: SelonaColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: SelonaColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Video playback will be available\nafter encryption integration',
              style: TextStyle(
                color: SelonaColors.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    final position = _controller?.value.position ?? Duration.zero;
    final duration = _controller?.value.duration ?? Duration.zero;
    final isPlaying = _controller?.value.isPlaying ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Slider(
                  value: duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0,
                  onChanged: (value) {
                    final newPosition = duration * value;
                    _controller?.seekTo(newPosition);
                  },
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Frame step backward
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () => _stepFrame(false),
              ),
              // Rewind
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () => _seekRelative(const Duration(seconds: -10)),
              ),
              // Play/Pause
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: _togglePlayPause,
              ),
              // Forward
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () => _seekRelative(const Duration(seconds: 10)),
              ),
              // Frame step forward
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () => _stepFrame(true),
              ),
            ],
          ),

          // Secondary controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed selector
              _buildSpeedButton(0.5),
              _buildSpeedButton(1.0),
              _buildSpeedButton(1.5),
              _buildSpeedButton(2.0),
              // Mute button
              IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: _toggleMute,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(double speed) {
    final isSelected = _playbackSpeed == speed;
    return TextButton(
      onPressed: () => _setPlaybackSpeed(speed),
      style: TextButton.styleFrom(
        backgroundColor:
            isSelected ? SelonaColors.primaryAccent.withAlpha(51) : null,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
      ),
      child: Text(
        '${speed}x',
        style: TextStyle(
          color: isSelected ? SelonaColors.primaryAccent : Colors.white,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
