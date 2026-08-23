library;

/// Conditional import: IO variant on native platforms, web variant on web.
export 'preview_video_io.dart' if (dart.library.html) 'preview_video_web.dart';
