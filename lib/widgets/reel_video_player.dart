import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import 'instagram_image.dart';

/// A muted-by-default, looping network video with Instagram-style gestures:
/// tap to pause/play, double tap to like, and a thin scrub indicator.
class ReelVideoPlayer extends StatefulWidget {
  const ReelVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.posterUrl,
    required this.isActive,
    required this.isMuted,
    this.onDoubleTapLike,
  });

  final String? videoUrl;
  final String posterUrl;
  final bool isActive;
  final bool isMuted;
  final VoidCallback? onDoubleTapLike;

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  late final AnimationController _heartController;
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _openVideo();
  }

  Future<void> _openVideo() async {
    final url = widget.videoUrl;
    if (url == null || url.isEmpty) {
      setState(() => _failed = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.isMuted ? 0 : 1);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_handleValue);
      setState(() => _initialized = true);
      if (widget.isActive) {
        await controller.play();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  void _handleValue() {
    final value = _controller?.value;
    if (!mounted || value == null) return;
    if (value.hasError && !_failed) {
      setState(() => _failed = true);
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (controller == null) return;

    if (oldWidget.isMuted != widget.isMuted) {
      controller.setVolume(widget.isMuted ? 0 : 1);
    }
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        controller.play();
      } else {
        controller.pause();
        controller.seekTo(Duration.zero);
      }
    }
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !_initialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  void _like() {
    widget.onDoubleTapLike?.call();
    _heartController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        InstagramImage(url: widget.posterUrl, backgroundColor: Colors.black),
        if (_initialized && _controller != null)
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, _) {
              if (!value.isInitialized || value.size.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: value.size.width,
                    height: value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              );
            },
          ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePlayback,
          onDoubleTap: _like,
        ),
        if (_initialized && _controller != null)
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, _) {
              final showPause = !value.isPlaying && !value.isBuffering;
              return Center(
                child: AnimatedScale(
                  scale: showPause ? 1 : 0.7,
                  duration: const Duration(milliseconds: 180),
                  child: AnimatedOpacity(
                    opacity: showPause ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        if (_initialized && _controller != null)
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, _) => value.isBuffering
                ? const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _heartController,
                builder: (context, _) {
                  final progress = _heartController.value;
                  if (progress == 0 || progress == 1) {
                    return const SizedBox.shrink();
                  }
                  final opacity = (1 - progress).clamp(0.0, 1.0);
                  final scale = 0.55 + progress * 1.05;
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 110,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (_failed && !_initialized)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 108,
            child: Center(
              child: Text(
                'Video preview unavailable',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_initialized && _controller != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: false,
              padding: const EdgeInsets.only(top: 6),
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Color(0x66FFFFFF),
                backgroundColor: Color(0x33FFFFFF),
              ),
            ),
          ),
        if (_initialized && _controller != null)
          const Positioned(
            left: 0,
            right: 0,
            top: 3,
            child: IgnorePointer(child: SizedBox(height: 2)),
          ),
        if (!_initialized && !_failed)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 108,
            child: Center(
              child: Text(
                'Loading reel…',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Positioned(
          left: 16,
          bottom: 109,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Original audio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 14,
          top: 14,
          child: IgnorePointer(
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.red, blurRadius: 8)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleValue);
    _controller?.dispose();
    _heartController.dispose();
    super.dispose();
  }
}
