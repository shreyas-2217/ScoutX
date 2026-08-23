import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../../models/clip.dart' as models;
import '../shared/share_sheet.dart';

/// Shown right after a highlight is published — plays the uploaded clip,
/// offers a share deep-link and returns the player to Home.
class UploadSuccessScreen extends StatefulWidget {
  final models.Clip clip;

  const UploadSuccessScreen({super.key, required this.clip});

  @override
  State<UploadSuccessScreen> createState() => _UploadSuccessScreenState();
}

class _UploadSuccessScreenState extends State<UploadSuccessScreen> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final ctrl =
          VideoPlayerController.networkUrl(Uri.parse(widget.clip.videoUrl));
      await ctrl.initialize();
      ctrl.setLooping(true);
      ctrl.setVolume(0);
      unawaited(ctrl.play());
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      setState(() => _controller = ctrl);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    c.value.isPlaying ? c.pause() : c.play();
    setState(() {});
  }

  void _toggleMute() {
    final c = _controller;
    if (c == null) return;
    c.setVolume(c.value.volume > 0 ? 0 : 1);
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      // Success badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                size: 18, color: Colors.white),
                          ).animate(delay: 100.ms).scale(
                                duration: 350.ms,
                                curve: Curves.easeOutBack,
                              ),
                          const SizedBox(width: 10),
                          Text(
                            'Highlight published!',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 250.ms),
                      const SizedBox(height: 16),

                      // Published clip player — sized to fit the screen:
                      // portrait clips are capped by height instead of
                      // stretching tall enough to overflow the page.
                      LayoutBuilder(
                        builder: (context, cons) {
                          final ready = c?.value.isInitialized ?? false;
                          final ratio = ready ? c!.value.aspectRatio : 9 / 16;
                          final maxH = (MediaQuery.of(context).size.height *
                                  0.45)
                              .clamp(260.0, 460.0)
                              .toDouble();
                          double w = cons.maxWidth;
                          double h = w / ratio;
                          if (h > maxH) {
                            h = maxH;
                            w = h * ratio;
                          }
                          return Center(
                            child: SizedBox(
                              width: w,
                              height: h,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                            if (c != null && c.value.isInitialized)
                              GestureDetector(
                                onTap: _togglePlayPause,
                                child: VideoPlayer(c),
                              )
                            else
                              Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainer,
                                alignment: Alignment.center,
                                child: _failed
                                    ? Icon(Icons.movie_outlined,
                                        size: 48,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)
                                    : CircularProgressIndicator(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                              ),
                            if (c != null && c.value.isInitialized && !c.value.isPlaying)
                              Center(
                                child: IgnorePointer(
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow,
                                        size: 40, color: Colors.white),
                                  ),
                                ),
                              ),
                            // Top-right mute toggle
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.black.withValues(alpha: 0.5),
                                ),
                                icon: Icon(
                                  (c?.value.volume ?? 0) > 0
                                      ? Icons.volume_up
                                      : Icons.volume_off,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleMute,
                              ),
                            ),
                            // Bottom-left duration
                            if (c != null && c.value.isInitialized)
                              Positioned(
                                left: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                   child: Text(
                                     _formatDuration(c.value.duration),
                                     style: const TextStyle(
                                       color: Colors.white,
                                       fontSize: 12,
                                       fontWeight: FontWeight.w600,
                                     ),
                                   ),
                                 ),
                               ),
                           ],
                          ), // Stack
                          ), // SizedBox
                          ); // Center + end return
                        },
                      ),
                      const SizedBox(height: 12),

                      // Clip info
                      Text(
                        widget.clip.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _InfoChip(label: widget.clip.sport),
                          if (widget.clip.position.isNotEmpty)
                            _InfoChip(label: widget.clip.position),
                          if (widget.clip.skills.isNotEmpty)
                            _InfoChip(label: '${widget.clip.skills.length} skills'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (_) =>
                                      ShareSheet(clip: widget.clip),
                                );
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.35)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .popUntil((r) => r.isFirst),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Done',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                         ],
                       ).animate(delay: 150.ms).fadeIn(),
                     ],
                   ), // Column
                  ), // SingleChildScrollView
                 ), // ConstrainedBox
               ), // Center
             ),
           ],
         ),
       ),
     );
   }
 }

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
