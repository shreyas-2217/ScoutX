import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'widgets.dart';

/// Full-screen video player used when a clip is opened.
class ClipPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const ClipPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title,
  });

  @override
  State<ClipPlayerScreen> createState() => _ClipPlayerScreenState();
}

class _ClipPlayerScreenState extends State<ClipPlayerScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _failed = false;
  bool _showControls = true;

  late final AnimationController _controlsController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _initialized = true);
      _controller.setLooping(true);
      _controller.play();
    }).catchError((e) {
      if (!mounted) return;
      setState(() => _failed = true);
    });

    _controlsController = AnimationController(
      vsync: this,
      duration: DSMotion.fast,
    );
    _autoHideControls();
  }

  Future<void> _autoHideControls() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && _controller.value.isPlaying) {
      _controlsController.forward();
    }
  }

  void _toggleControls() {
    if (_showControls) {
      _controlsController.forward();
    } else {
      _controlsController.reverse();
    }
    setState(() => _showControls = !_showControls);
  }

  @override
  void dispose() {
    _controller.dispose();
    _controlsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(DSSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(DSIcons.arrowLeft, color: DSColors.onSurface, size: DSIconSize.md),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.title ?? 'Clip',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: Center(
        child: _failed
            ? _ErrorState(onRetry: () {
                setState(() => _failed = false);
                _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
                _controller.initialize().then((_) {
                  if (!mounted) return;
                  setState(() => _initialized = true);
                  _controller.setLooping(true);
                  _controller.play();
                });
              })
            : !_initialized
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: DSColors.onSurface),
                      SizedBox(height: DSSpacing.md),
                      Text(
                        'Loading video...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DSColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _toggleControls,
                    onDoubleTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        // Play/pause overlay
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return AnimatedOpacity(
                              opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                              duration: DSMotion.fast,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(DSSpacing.lg),
                                child: Icon(
                                  _controller.value.isPlaying
                                      ? DSIcons.pauseCircle
                                      : DSIcons.playCircle,
                                  size: 80,
                                  color: DSColors.onSurface,
                                ),
                              ),
                            );
                          },
                        ),
                        // Top gradient
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              opacity: _showControls ? 1.0 : 0.0,
                              duration: DSMotion.fast,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.5),
                                      Colors.transparent,
                                    ],
                                  ),
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
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              opacity: _showControls ? 1.0 : 0.0,
                              duration: DSMotion.fast,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Video progress bar
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            opacity: _showControls ? 1.0 : 0.0,
                            duration: DSMotion.fast,
                            child: SafeArea(
                              top: false,
                              child: VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                padding: EdgeInsets.symmetric(
                                  horizontal: DSSpacing.md,
                                  vertical: DSSpacing.sm,
                                ),
                                colors: VideoProgressColors(
                                  playedColor: DSColors.onSurface,
                                  bufferedColor: DSColors.onSurface.withValues(alpha: 0.3),
                                  backgroundColor: DSColors.onSurface.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DSSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DSColors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                DSIcons.warningCircle,
                size: DSIconSize.xxl,
                color: DSColors.red,
              ),
            ),
            SizedBox(height: DSSpacing.lg),
            Text(
              'Could not play this video',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DSSpacing.sm),
            Text(
              'The video may be unavailable or the format is not supported.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DSColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DSSpacing.xl),
            DSButton(
              label: 'Try Again',
              leadingIcon: DSIcons.arrowsClockwise,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}


