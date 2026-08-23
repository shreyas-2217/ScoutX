import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Native platforms (Android/desktop): play the picked file directly from
/// disk. Platforms without a video_player implementation (e.g. Windows)
/// fail in [VideoPlayerController.initialize] — callers fall back gracefully.
Future<VideoPlayerController?> openPreviewController(XFile file) async {
  return VideoPlayerController.file(File(file.path));
}
