import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../shared/models/media_file.dart';
import '../../../shared/models/app_settings.dart';
import 'widgets/image_viewer.dart';
import 'widgets/video_player_widget.dart';
import 'widgets/viewer_controls.dart';

/// Unified viewer screen for images and videos
class ViewerScreen extends ConsumerStatefulWidget {
  final ViewerScreenArguments arguments;

  const ViewerScreen({
    super.key,
    required this.arguments,
  });

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;
  bool _isFullscreen = true;
  bool _isSlideshow = false;
  ImageViewMode _viewMode = ImageViewMode.horizontal;

  /// Slideshow interval in seconds (adjustable 1-30 seconds)
  double _slideshowIntervalSeconds = 5.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.arguments.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Hide system UI for immersive viewing
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  List<MediaFile> get _files => widget.arguments.files;

  MediaFile get _currentFile => _files[_currentIndex];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Restart slideshow timer for new page
    if (_isSlideshow) {
      _startSlideshowTimer();
    }
  }

  /// Stop slideshow on any user interaction
  void _stopSlideshowOnInteraction() {
    if (_isSlideshow) {
      setState(() {
        _isSlideshow = false;
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _goToPrevious() {
    _stopSlideshowOnInteraction();
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goToNext() {
    _stopSlideshowOnInteraction();
    if (_currentIndex < _files.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onRotate() {
    // TODO: Update rotation in database
    setState(() {
      // Rotate current file
    });
  }

  void _onViewModeChanged(ImageViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _toggleSlideshow() {
    setState(() {
      _isSlideshow = !_isSlideshow;
      if (_isSlideshow) {
        _startSlideshowTimer();
      }
    });
  }

  void _startSlideshowTimer() {
    if (!_isSlideshow) return;

    // For images: wait fixed interval then advance
    // For videos: VideoPlayerWidget will call onVideoEnded when done
    if (_currentFile.isImage) {
      Future.delayed(
          Duration(milliseconds: (_slideshowIntervalSeconds * 1000).toInt()),
          () {
        if (_isSlideshow && mounted) {
          _advanceSlideshow();
        }
      });
    }
    // Videos auto-advance when they end (handled by onVideoEnded callback)
  }

  void _advanceSlideshow() {
    if (!_isSlideshow || !mounted) return;

    if (_currentIndex < _files.length - 1) {
      // Use pageController directly to avoid stopping slideshow
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      // Timer will restart in _onPageChanged
    } else {
      // End of playlist - loop back to start
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Called when a video finishes playing (for slideshow auto-advance)
  void _onVideoEnded() {
    if (_isSlideshow && mounted) {
      // Small delay before advancing
      Future.delayed(const Duration(milliseconds: 500), () {
        _advanceSlideshow();
      });
    }
  }

  void _onBookmarkToggle() {
    // TODO: Toggle bookmark in database
    HapticFeedback.lightImpact();
  }

  void _onRatingChanged(int rating) {
    // TODO: Update rating in database
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Content viewer
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                if (file.isVideo) {
                  return VideoPlayerWidget(
                    file: file,
                    showControls: _showControls,
                    isSlideshow: _isSlideshow,
                    onVideoEnded: _onVideoEnded,
                  );
                } else {
                  return ImageViewerWidget(
                    file: file,
                    viewMode: _viewMode,
                  );
                }
              },
            ),

            // Controls overlay
            if (_showControls) ...[
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(179),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          // Slideshow toggle and interval slider
                          if (_isSlideshow) ...[
                            SizedBox(
                              width: 100,
                              child: Slider(
                                value: _slideshowIntervalSeconds,
                                min: 1,
                                max: 30,
                                divisions: 29,
                                onChanged: (value) {
                                  setState(() {
                                    _slideshowIntervalSeconds = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${_slideshowIntervalSeconds.toInt()}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          IconButton(
                            icon: Icon(
                              _isSlideshow
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: _isSlideshow
                                  ? SelonaColors.primaryAccent
                                  : Colors.white,
                            ),
                            onPressed: _toggleSlideshow,
                          ),
                          // Fullscreen toggle
                          IconButton(
                            icon: Icon(
                              _isFullscreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed: _toggleFullscreen,
                          ),
                          IconButton(
                            icon: Icon(
                              _currentFile.isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _currentFile.isBookmarked
                                  ? SelonaColors.primaryAccent
                                  : Colors.white,
                            ),
                            onPressed: _onBookmarkToggle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withAlpha(179),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ViewerControls(
                      file: _currentFile,
                      currentIndex: _currentIndex,
                      totalFiles: _files.length,
                      viewMode: _viewMode,
                      onViewModeChanged:
                          _currentFile.isImage ? _onViewModeChanged : null,
                      onRotate: _onRotate,
                      onRatingChanged: _onRatingChanged,
                      onPrevious: _currentIndex > 0 ? _goToPrevious : null,
                      onNext:
                          _currentIndex < _files.length - 1 ? _goToNext : null,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
