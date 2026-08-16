import 'services/cloudinary_service.dart';

/// ---------------------------------------------------------------------------
/// Cloudinary configuration (replaces Firebase Storage for clip uploads)
/// ---------------------------------------------------------------------------
///
/// To get your free values (free tier includes unsigned uploads):
///   1. Sign up at https://cloudinary.com/ and copy your "Cloud name"
///      from the dashboard.
///   2. Settings > Upload > Upload presets > "Add upload preset"
///      -> toggle "Unsigned" -> "Save" -> copy the preset name.
///
/// An unsigned preset needs no server secret, so it is safe to keep in the app
/// bundle. Paste your real values over the placeholders below.
const CloudinaryConfig scoutxCloudinary = CloudinaryConfig(
  cloudName: 'fo2utqym',
  uploadPreset: 'scoutx_clips',
);
