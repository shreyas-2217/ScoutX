import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoutx/design_system.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../constants.dart';
import '../../models/clip.dart' as models;
import '../../providers/auth_provider.dart'
    show AuthProvider;
import '../../services/database.dart'
    show Database;
import '../../services/ai/ai_config.dart' show AIConfig;
import '../../services/ai/skill_suggestion_service.dart';
import '../../utils/preview_video.dart';
import '../../widgets/skill_selector.dart';
import '../shared/widgets.dart'
    show DSSpacing, DSRadius, DSCard, DSButton, SectionHeader;
import 'upload_success_screen.dart';

class UploadClipScreen extends StatefulWidget {
  const UploadClipScreen({super.key});

  @override
  State<UploadClipScreen> createState() => _UploadClipScreenState();
}

class _UploadClipScreenState extends State<UploadClipScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  final _skillSuggester = SkillSuggestionService();

  XFile? _video;
  VideoPlayerController? _previewCtrl;
  bool _previewFailed = false;

  // Upload progress (0.0–1.0) surfaced to the progress dialog.
  final _uploadProgress = ValueNotifier<double>(0);

  // AI skill suggester state.
  bool _suggesting = false;
  bool _aiAvailable = true; // flips false permanently on any failure
  bool _aiSuggested = false; // one shot per picked video

  String? _sport;
  String? _position;
  String? _highlightType;
  String? _ageGroup;
  String? _location;
  List<String> _selectedSkills = [];
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    // Rebuild so the Suggest button's enable-state tracks text changes.
    _title.addListener(_onTextChanged);
    _description.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _title.removeListener(_onTextChanged);
    _description.removeListener(_onTextChanged);
    _title.dispose();
    _description.dispose();
    _previewCtrl?.dispose();
    _uploadProgress.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Pre-upload preview player
  // -------------------------------------------------------------------------

  Future<void> _initPreview(XFile file) async {
    _disposePreviewController();
    try {
      final ctrl = await openPreviewController(file);
      if (ctrl == null || !mounted) {
        await ctrl?.dispose();
        if (mounted) setState(() => _previewFailed = true);
        return;
      }
      await ctrl.initialize(); // throws where video_player is unsupported
      ctrl.setLooping(true);
      ctrl.setVolume(0); // muted autoplay — avoids web autoplay blocking
      unawaited(ctrl.play());
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _previewCtrl = ctrl;
        _previewFailed = false;
      });
    } catch (_) {
      // Graceful fallback to the simple "picked" view on this platform.
      if (mounted) setState(() => _previewFailed = true);
    }
  }

  void _disposePreviewController() {
    _previewCtrl?.dispose();
    _previewCtrl = null;
  }

  Future<void> _removeVideo() async {
    setState(() => _video = null);
    _aiSuggested = false; // new video, allow suggesting again
    _disposePreviewController();
  }

  void _togglePlayPause() {
    final c = _previewCtrl;
    if (c == null || !c.value.isInitialized) return;
    c.value.isPlaying ? c.pause() : c.play();
    setState(() {});
  }

  void _toggleMute() {
    final c = _previewCtrl;
    if (c == null) return;
    c.setVolume(c.value.volume > 0 ? 0 : 1);
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // -------------------------------------------------------------------------
  // AI skill suggestions
  // -------------------------------------------------------------------------

  bool get _canSuggest =>
      _aiAvailable &&
      !_aiSuggested &&
      !_suggesting &&
      !_uploading &&
      _sport != null &&
      (_title.text.trim().length >= 4 ||
          _description.text.trim().length >= 10);

  Future<void> _onSuggestSkills() async {
    // Missing key is a config problem, not an AI failure — tell the runner
    // instead of silently hiding the button.
    if (!AIConfig.hasAnyKey) {
      _snack('AI suggestions need a Gemini API key. Run with '
          '--dart-define=GEMINI_API_KEY=your_key');
      return;
    }
    if (!_canSuggest) return;
    setState(() => _suggesting = true);
    try {
      final suggested = await _skillSuggester.suggest(
        sport: _sport!,
        title: _title.text.trim(),
        description: _description.text.trim(),
        extraContext: [
          ?_highlightType,
          ?_ageGroup,
        ],
      );
      if (!mounted) return;
      if (suggested.isEmpty) {
        // Nothing matched — tell the user instead of silently doing nothing.
        _snack('AI couldn\'t find matching skills — try a more detailed '
            'title or description.');
        setState(() => _suggesting = false);
        return;
      }
      final merged = List<String>.from(_selectedSkills);
      final newlyAdded = <String>[];
      for (final s in suggested) {
        if (!merged.any((e) => e.toLowerCase() == s.toLowerCase())) {
          merged.add(s);
          newlyAdded.add(s);
        }
      }
      setState(() {
        _selectedSkills = merged.take(8).toList();
        _aiSuggested = true;
        _suggesting = false;
      });
      if (newlyAdded.isNotEmpty) {
        _snack('✨ AI added ${newlyAdded.length} skill'
            '${newlyAdded.length == 1 ? '' : 's'}: '
            '${newlyAdded.take(4).join(', ')}');
      } else {
        _snack('AI suggested: ${suggested.take(4).join(', ')} — '
            'already selected');
      }
    } catch (_) {
      // Quota/network/config problem — hide the feature silently; the
      // manual skill picker keeps working exactly as before.
      if (mounted) {
        setState(() {
          _aiAvailable = false;
          _suggesting = false;
        });
      }
    }
  }

  // -------------------------------------------------------------------------
  // Pick & upload
  // -------------------------------------------------------------------------

  Future<void> _pickVideo() async {
    try {
      final picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
      if (picked != null) {
        setState(() => _video = picked);
        _aiSuggested = false;
        await _initPreview(picked);
      }
    } catch (e) {
      if (mounted) {
        _snack('Failed to pick video: $e');
      }
    }
  }

  // -------------------------------------------------------------------------
  // Field styling — explicit so labels/typed text stay readable in both
  // themes regardless of global theme gaps.
  // -------------------------------------------------------------------------

  TextStyle get _fieldStyle => GoogleFonts.inter(
        fontSize: 15,
        color: Theme.of(context).colorScheme.onSurface,
      );

  InputDecoration _fieldDeco(
    String label, {
    String? hint,
    IconData? icon,
    bool alignLabelWithHint = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: cs.surfaceContainer,
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: cs.onSurfaceVariant,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: cs.onSurfaceVariant,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 15,
        color: cs.onSurfaceVariant.withValues(alpha: 0.55),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSRadius.input),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSRadius.input),
        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSRadius.input),
        borderSide: BorderSide(color: cs.onSurface, width: 1),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Video area UI
  // -------------------------------------------------------------------------

  Widget _buildVideoArea(BuildContext context) {
    if (_video == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam,
              size: 30,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: DSSpacing.md),
          Text(
            'Tap to pick a video\n(max 60 seconds)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      );
    }

    final ctrl = _previewCtrl;
    if (ctrl != null && ctrl.value.isInitialized) {
      // Cover-fill the whole tile (like Instagram): size the player to fully
      // cover the box at the video's aspect ratio and let ClipRRect crop the
      // overflow. Never shrinks portrait videos into a tiny letterbox.
      return ClipRRect(
        borderRadius: BorderRadius.circular(DSRadius.card - 2),
        child: LayoutBuilder(
          builder: (context, cons) {
            final ratio = ctrl.value.aspectRatio;
            double w = cons.maxWidth;
            double h = w / ratio;
            if (h < cons.maxHeight) {
              h = cons.maxHeight;
              w = h * ratio;
            }
            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: VideoPlayer(ctrl),
                  ),
                ),
                // Tap target for play/pause
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    behavior: HitTestBehavior.opaque,
                    child: ctrl.value.isPlaying
                        ? const SizedBox.shrink()
                        : Center(
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow,
                                  size: 34, color: Colors.white),
                            ),
                          ),
                  ),
                ),
                // Mute toggle
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(
                      ctrl.value.volume > 0
                          ? Icons.volume_up
                          : Icons.volume_off,
                      size: 17,
                      color: Colors.white,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
                // Duration + manual scrub bar (drag to any timestamp)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                    padding:
                        const EdgeInsets.fromLTRB(10, 18, 10, 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: ctrl,
                          builder: (context, v, _) => Text(
                            '${_formatDuration(v.position)} / ${_formatDuration(v.duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        VideoProgressIndicator(
                          ctrl,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.white,
                            bufferedColor: Color(0x40FFFFFF),
                            backgroundColor: Color(0x33FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Change / Remove actions
                Positioned(
                  right: 8,
                  bottom: 44,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PlayerActionPill(
                        icon: Icons.refresh,
                        label: 'Change',
                        onTap: _uploading ? null : _pickVideo,
                      ),
                      const SizedBox(width: 6),
                      _PlayerActionPill(
                        icon: Icons.delete_outline,
                        label: 'Remove',
                        onTap: _uploading ? null : _removeVideo,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Player not ready (still initializing or unsupported platform) —
    // show the lightweight picked-file view.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_previewFailed) ...[
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: DSSpacing.md),
        ] else ...[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 32,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: DSSpacing.sm),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DSSpacing.md),
          child: Text(
            _video!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        SizedBox(height: DSSpacing.xs),
        Text(
          'Tap to change video',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  List<String> _generateTags() {
    final tags = <String>[];
    if (_location != null && _location!.isNotEmpty) {
      tags.add(_location!);
    }
    if (_sport != null && _sport!.isNotEmpty) {
      tags.add(_sport!);
    }
    if (_ageGroup != null && _ageGroup!.isNotEmpty) {
      tags.add(_ageGroup!);
    }
    if (_position != null && _position!.isNotEmpty) {
      tags.add(_position!);
    }
    if (_highlightType != null && _highlightType!.isNotEmpty) {
      tags.add(_highlightType!);
    }
    for (final skill in _selectedSkills) {
      if (!tags.contains(skill)) {
        tags.add(skill);
      }
    }
    return tags.take(10).toList();
  }

  String _buildSearchableText() {
    final parts = <String>[];
    if (_sport != null) parts.add(_sport!);
    if (_position != null) parts.add(_position!);
    if (_ageGroup != null) parts.add(_ageGroup!);
    if (_location != null) parts.add(_location!);
    if (_highlightType != null) parts.add(_highlightType!);
    parts.addAll(_selectedSkills);
    parts.add(_title.text.trim());
    parts.add(_description.text.trim());
    return parts.where((p) => p.isNotEmpty).join(' ').toLowerCase();
  }

  Future<void> _upload() async {
    final auth = context.read<AuthProvider>();
    final db = context.read<Database>();
    final user = auth.user;
    final profile = auth.profile;
    if (user == null || profile == null) return;
    if (_video == null) {
      _snack('Please pick a video first.');
      return;
    }
    if (_title.text.trim().isEmpty) {
      _snack('Please add a title.');
      return;
    }
    if (_sport == null) {
      _snack('Please select a sport.');
      return;
    }
    if (_position == null) {
      _snack('Please select a position.');
      return;
    }

    setState(() => _uploading = true);
    _uploadProgress.value = 0;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _UploadProgressDialog(progress: _uploadProgress),
      );
    }

    try {
      // The preview player is no longer needed once uploading starts.
      _disposePreviewController();

      final bytes = await _video!.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_video!.name}';
      final tags = _generateTags();
      final searchableText = _buildSearchableText();

      models.Clip clipData({
        required String id,
        required String videoUrl,
      }) =>
          models.Clip(
            id: id,
            playerId: user.uid,
            playerName: profile.displayName,
            videoUrl: videoUrl,
            title: _title.text.trim(),
            sport: _sport!,
            position: _position!,
            description: _description.text.trim(),
            createdAt: DateTime.now(),
            highlightType: _highlightType,
            skills: _selectedSkills,
            tags: tags,
            ageGroup: _ageGroup,
            location: _location,
            searchableText: searchableText,
          );

      final url = await db.uploadVideo(
        clipData(id: '', videoUrl: ''),
        bytes,
        fileName,
        onProgress: (p) => _uploadProgress.value = p,
      );
      final clipId = await db.addClip(clipData(id: '', videoUrl: url));
      if (!mounted) return;
      Navigator.of(context).pop(); // close progress dialog
      await auth.refreshProfile();
      if (!mounted) return;
      // Show the published clip instead of silently dropping the user back.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              UploadSuccessScreen(clip: clipData(id: clipId, videoUrl: url)),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _snack('Upload failed: $e');
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DSRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final tags = _generateTags();

    // Portrait clips get a tall reels-style preview; landscape ones stay
    // compact. Never let the video shrink into a tiny strip.
    final previewReady = _previewCtrl?.value.isInitialized == true;
    final previewRatio =
        previewReady ? _previewCtrl!.value.aspectRatio : null;
    final videoTileHeight = previewRatio == null
        ? 230.0
        : (600 / previewRatio).clamp(240.0, 480.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Clip')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DSSpacing.lg),
        child: Center(
          // Keeps the form usable on wide desktop windows instead of
          // stretching every card edge-to-edge.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Video area
                GestureDetector(
                  onTap: _uploading ? null : _pickVideo,
                  child: Container(
                    height: videoTileHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(DSRadius.card),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                alignment: Alignment.center,
                padding:
                    (_video != null && previewReady)
                        ? EdgeInsets.zero
                        : EdgeInsets.all(DSSpacing.xl),
                child: _buildVideoArea(context),
              ),
            ),
            SizedBox(height: DSSpacing.xl),

            // Details section
            DSCard(
              padding: EdgeInsets.all(DSSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(text: 'Details'),
                  SizedBox(height: DSSpacing.md),
                  TextFormField(
                    controller: _title,
                    style: _fieldStyle,
                    decoration: _fieldDeco(
                      'Title',
                      hint: 'e.g. Match winning goal',
                      icon: DSIcons.textT,
                    ),
                  ),
                  SizedBox(height: DSSpacing.md),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    minLines: 1,
                    style: _fieldStyle,
                    decoration: _fieldDeco(
                      'Description (optional)',
                      hint: 'Tournament, opponent, highlights...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  SizedBox(height: DSSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _sport,
                    isExpanded: true,
                    style: _fieldStyle,
                    dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
                    iconDisabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    decoration: _fieldDeco('Sport', icon: DSIcons.trophy),
                    items: AppConstants.sportList
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s, style: _fieldStyle)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _sport = v;
                      _position = null;
                      _selectedSkills = [];
                      _highlightType = null;
                    }),
                  ),
                  if (_sport != null) ...[
                    SizedBox(height: DSSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _position,
                      isExpanded: true,
                      style: _fieldStyle,
                      dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
                      iconDisabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration:
                          _fieldDeco('Position', icon: DSIcons.sportsRounded),
                      items: (AppConstants.positionsBySport[_sport] ?? const [])
                          .map((p) => DropdownMenuItem(
                              value: p, child: Text(p, style: _fieldStyle)))
                          .toList(),
                      onChanged: (v) => setState(() => _position = v),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: DSSpacing.lg),

            // Auto-populated profile data
            if (profile != null) ...[
              DSCard(
                padding: EdgeInsets.all(DSSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(text: 'From your profile'),
                    SizedBox(height: DSSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (profile.sport != null)
                          _AutoTag(label: 'Sport: ${profile.sport}', icon: Icons.sports),
                        if (profile.position != null)
                          _AutoTag(label: 'Position: ${profile.position}', icon: Icons.person),
                        if (profile.city != null)
                          _AutoTag(label: '${profile.city}', icon: Icons.location_on),
                      ],
                    ),
                    SizedBox(height: DSSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _ageGroup,
                      isExpanded: true,
                      style: _fieldStyle,
                      dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
                      iconDisabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration: _fieldDeco('Age Group', icon: Icons.group),
                      items: AppConstants.ageGroups
                          .map((a) => DropdownMenuItem(
                              value: a, child: Text(a, style: _fieldStyle)))
                          .toList(),
                      onChanged: (v) => setState(() => _ageGroup = v),
                    ),
                    SizedBox(height: DSSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _highlightType,
                      isExpanded: true,
                      style: _fieldStyle,
                      dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
                      iconDisabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration:
                          _fieldDeco('Highlight Type', icon: Icons.videocam),
                      items: (AppConstants.highlightTypesBySport[_sport] ??
                              AppConstants.highlightTypes)
                          .map((h) => DropdownMenuItem(
                              value: h, child: Text(h, style: _fieldStyle)))
                          .toList(),
                      onChanged: (v) => setState(() => _highlightType = v),
                    ),
                    SizedBox(height: DSSpacing.md),
                    TextFormField(
                      initialValue: _location,
                      style: _fieldStyle,
                      decoration: _fieldDeco(
                        'Highlight Location (optional)',
                        hint: 'e.g. Bangalore',
                        icon: Icons.location_on_outlined,
                      ),
                      onChanged: (v) =>
                          setState(() => _location = v.trim().isEmpty ? null : v.trim()),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DSSpacing.lg),
            ],

            // Skills section
            DSCard(
              padding: EdgeInsets.all(DSSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: SectionHeader(text: 'What does this highlight demonstrate?')),
                      if (_aiAvailable) ...[
                        const SizedBox(width: DSSpacing.sm),
                        // Filled pill: dark-on-light / light-on-dark, always
                        // readable against the card background.
                        GestureDetector(
                          onTap: _canSuggest ? _onSuggestSkills : null,
                          child: AnimatedOpacity(
                            opacity:
                                (_canSuggest || _suggesting) ? 1.0 : 0.45,
                            duration: DSMotion.fast,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_suggesting)
                                    SizedBox(
                                      width: 13,
                                      height: 13,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                    )
                                  else
                                    Icon(
                                      _aiSuggested
                                          ? Icons.check_circle
                                          : Icons.auto_awesome,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _suggesting
                                        ? 'Thinking…'
                                        : _aiSuggested
                                            ? 'Suggested ✓'
                                            : 'Suggest',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: DSSpacing.xs),
                  Text(
                    'Select the skills, techniques or moments shown in your highlight.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: DSSpacing.md),
                  SkillSelector(
                    sport: _sport,
                    selectedSkills: _selectedSkills,
                    onSkillsChanged: (skills) => setState(() => _selectedSkills = skills),
                  ),
                ],
              ),
            ),
            SizedBox(height: DSSpacing.lg),

            // Hashtags preview
            if (tags.isNotEmpty) ...[
              DSCard(
                padding: EdgeInsets.all(DSSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tag, size: 18, color: Theme.of(context).colorScheme.onSurface),
                        SizedBox(width: 6),
                        Text(
                          'Hashtags',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: DSSpacing.sm),
                    Text(
                      'These tags help others discover your highlight.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: DSSpacing.md),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text('#$tag', style: TextStyle(fontSize: 11)),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DSRadius.chip),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DSSpacing.lg),
            ],

            if (_uploading) ...[
              LinearProgressIndicator(
                color: Theme.of(context).colorScheme.onSurface,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              SizedBox(height: DSSpacing.md),
            ],
            DSButton(
              label: _uploading ? 'Uploading...' : 'Upload Clip',
              leadingIcon: _uploading ? null : DSIcons.cloudArrowUp,
              loading: _uploading,
              fullWidth: true,
              onPressed: _uploading ? null : _upload,
            ),
          ], // Column.children
          ), // Column
          ), // ConstrainedBox
        ), // Center
      ), // SingleChildScrollView
    ); // Scaffold
  }
}

class _PlayerActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _PlayerActionPill({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadProgressDialog extends StatelessWidget {
  final ValueNotifier<double> progress;

  const _UploadProgressDialog({required this.progress});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          // Cap at 95% while bytes are in flight — Cloudinary still has to
          // process/transcode after the last byte arrives.
          final pct = ((progress.value.clamp(0.0, 1.0)) * 95.0);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: pct / 100,
                  color: Theme.of(context).colorScheme.onSurface,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: DSSpacing.lg),
              Text(
                'Uploading ${pct.toStringAsFixed(0)}%…',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: DSSpacing.sm),
              Text(
                'Processing your highlight once the upload completes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AutoTag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _AutoTag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.chip),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
