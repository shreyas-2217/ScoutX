// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Web: image_picker gives us bytes in memory — wrap them in an object URL
/// so the underlying <video> element can stream the local pick without an
/// upload round-trip.
Future<VideoPlayerController?> openPreviewController(XFile file) async {
  final bytes = await file.readAsBytes();
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  return VideoPlayerController.networkUrl(Uri.parse(url));
}
