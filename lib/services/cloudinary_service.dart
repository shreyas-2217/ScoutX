import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Credentials for unsigned uploads to Cloudinary.
///
/// An unsigned upload preset is designed for client-side use and does not
/// require a server-side secret, so it is safe to embed in the app bundle.
/// Fill in the real values in `lib/cloudinary_config.dart`.
class CloudinaryConfig {
  const CloudinaryConfig({required this.cloudName, required this.uploadPreset});

  final String cloudName;
  final String uploadPreset;
}

/// Minimal Cloudinary client that performs unsigned video uploads.
///
/// Only the subset of Cloudinary's REST API needed by ScoutX is implemented:
/// a single unsigned upload to the `video/upload` endpoint, returning the
/// public `secure_url` that is stored in Firestore and played by
/// `VideoPlayer.networkUrl`.
class CloudinaryService {
  CloudinaryService(this.config);

  final CloudinaryConfig config;

  /// Derives a poster-frame image URL from a Cloudinary video delivery URL by
  /// rewriting the path (no API call). Returns null for non-Cloudinary URLs.
  ///
  /// [width]/[height] control the crop box; pass values matching the widget's
  /// aspect ratio for crisp results (e.g. 640x360 for 16:9 cards).
  static String? videoThumbnail(
    String? videoUrl, {
    int width = 400,
    int height = 600,
  }) {
    if (videoUrl == null || videoUrl.isEmpty) return null;
    const marker = '/video/upload/';
    final index = videoUrl.indexOf(marker);
    if (index == -1 || index + marker.length >= videoUrl.length) return null;

    final head = videoUrl.substring(0, index + marker.length);
    final tail = videoUrl.substring(index + marker.length);
    final lastSlash = tail.lastIndexOf('/');
    final lastDot = tail.lastIndexOf('.');
    final stem =
        (lastDot > lastSlash && lastDot != -1) ? tail.substring(0, lastDot) : tail;

    return '$head${_transform([
      'so_auto',
      'w_$width',
      'h_$height',
      'c_fill',
      'f_jpg',
      'q_auto',
    ])}/$stem.jpg';
  }

  /// Returns an auto-format/auto-quality variant of a Cloudinary video URL so
  /// playback uses less bandwidth. Non-Cloudinary URLs pass through untouched.
  static String? optimizedVideo(String? videoUrl) {
    if (videoUrl == null ||
        videoUrl.isEmpty ||
        !videoUrl.contains('/video/upload/')) {
      return videoUrl;
    }
    return videoUrl.replaceFirst(
      '/video/upload/',
      '/video/upload/${_transform(['f_auto', 'q_auto'])}/',
    );
  }

  static String _transform(List<String> components) => components.join(',');

  Uri _uploadUri() {
    final cloudName = config.cloudName;
    if (cloudName.isEmpty) {
      throw StateError(
        'Cloudinary cloudName is empty. Paste your cloud name in '
        'lib/cloudinary_config.dart.',
      );
    }
    final preset = config.uploadPreset;
    if (preset.isEmpty) {
      throw StateError(
        'Cloudinary uploadPreset is empty. Paste your unsigned preset name in '
        'lib/cloudinary_config.dart.',
      );
    }
    return Uri.https('api.cloudinary.com', '/v1_1/$cloudName/image/upload');
  }

  Uri _videoUploadUri() {
    final cloudName = config.cloudName;
    if (cloudName.isEmpty) {
      throw StateError(
        'Cloudinary cloudName is empty. Paste your cloud name in '
        'lib/cloudinary_config.dart.',
      );
    }
    final preset = config.uploadPreset;
    if (preset.isEmpty) {
      throw StateError(
        'Cloudinary uploadPreset is empty. Paste your unsigned preset name in '
        'lib/cloudinary_config.dart.',
      );
    }
    return Uri.https('api.cloudinary.com', '/v1_1/$cloudName/video/upload');
  }

  /// Uploads [bytes] (a video) and returns its delivered HTTPS URL
  /// (Cloudinary's `secure_url`).
  ///
  /// [onProgress] reports bytes-sent as a 0.0–1.0 fraction while the request
  /// body is being written to the network.
  Future<String> uploadVideo(
    String playerId,
    Uint8List bytes,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.MultipartRequest('POST', _videoUploadUri())
      ..fields['upload_preset'] = config.uploadPreset
      ..fields['public_id'] = _buildPublicId(playerId, fileName)
      ..files.add(
        http.MultipartFile(
          'file',
          _trackedChunks(bytes, onProgress),
          bytes.length,
          filename: fileName,
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(body, response.statusCode));
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = json['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary response did not include a secure_url.');
    }
    return secureUrl;
  }

  /// Lazily yields [bytes] in fixed-size chunks so the http client pulls
  /// (and writes) them one at a time — lets us report real upload progress.
  Stream<Uint8List> _trackedChunks(
    Uint8List bytes,
    void Function(double progress)? onProgress,
  ) async* {
    const chunkSize = 512 * 1024;
    var sent = 0;
    while (sent < bytes.length) {
      final end =
          (sent + chunkSize < bytes.length) ? sent + chunkSize : bytes.length;
      yield Uint8List.sublistView(bytes, sent, end);
      sent = end;
      onProgress?.call(sent / bytes.length);
    }
  }

  /// Uploads [bytes] (an image) and returns its delivered HTTPS URL.
  Future<String> uploadImage(
    String uid,
    Uint8List bytes,
    String fileName,
  ) async {
    final request = http.MultipartRequest('POST', _uploadUri())
      ..fields['upload_preset'] = config.uploadPreset
      ..fields['public_id'] = _buildImagePublicId(uid, fileName)
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(body, response.statusCode));
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = json['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary response did not include a secure_url.');
    }
    return secureUrl;
  }

  String _buildImagePublicId(String uid, String fileName) {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final stem = safeName.contains('.')
        ? safeName.substring(0, safeName.lastIndexOf('.'))
        : safeName;
    final safeUid = uid.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'scoutx/profiles/$safeUid/${stem}_$stamp';
  }

  /// Builds a filesystem-safe public id scoped under the player, e.g.
  /// `scoutx/clips/<playerId>/<filename>_<ms>`. Cloudinary treats `/` as a
  /// folder separator, keeping the media library organised.
  String _buildPublicId(String playerId, String fileName) {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final stem = safeName.contains('.')
        ? safeName.substring(0, safeName.lastIndexOf('.'))
        : safeName;
    final safePlayer = playerId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'scoutx/clips/$safePlayer/${stem}_$stamp';
  }

  String _errorMessage(String body, int status) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'];
      if (error is Map && error['message'] != null) {
        return 'Upload failed: ${error['message']} (HTTP $status).';
      }
    } catch (_) {}
    return 'Upload failed with HTTP $status: $body';
  }
}
