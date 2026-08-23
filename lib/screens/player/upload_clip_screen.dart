import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/clip.dart' as models;
import '../../providers/auth_provider.dart'
    show AuthProvider;
import '../../services/database.dart'
    show Database;
import '../../widgets/skill_selector.dart';
import '../shared/widgets.dart'
    show DSColors, DSSpacing, DSIconSize, DSRadius, DSCard, DSButton, SectionHeader;

class UploadClipScreen extends StatefulWidget {
  const UploadClipScreen({super.key});

  @override
  State<UploadClipScreen> createState() => _UploadClipScreenState();
}

class _UploadClipScreenState extends State<UploadClipScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  XFile? _video;
  String? _sport;
  String? _position;
  String? _highlightType;
  String? _ageGroup;
  String? _location;
  List<String> _selectedSkills = [];
  bool _uploading = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
      if (picked != null) {
        setState(() => _video = picked);
      }
    } catch (e) {
      if (mounted) {
        _snack('Failed to pick video: $e');
      }
    }
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

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _UploadProgressDialog(),
      );
    }

    try {
      final bytes = await _video!.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_video!.name}';
      final tags = _generateTags();
      final searchableText = _buildSearchableText();

      final uploadTask = db.uploadVideo(
        models.Clip(
          id: '',
          playerId: user.uid,
          playerName: profile.displayName,
          videoUrl: '',
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
        ),
        bytes,
        fileName,
      );
      final url = await uploadTask;
      await db.addClip(
        models.Clip(
          id: '',
          playerId: user.uid,
          playerName: profile.displayName,
          videoUrl: url,
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
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await auth.refreshProfile();
      if (!mounted) return;
      Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Clip')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video area
            GestureDetector(
              onTap: _uploading ? null : _pickVideo,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: DSColors.surface,
                  borderRadius: BorderRadius.circular(DSRadius.card),
                  border: Border.all(
                    color: DSColors.outlineVariant,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.all(DSSpacing.xl),
                child: _video == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: DSColors.onSurface.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.videocam,
                            size: DSIconSize.xxl,
                            color: DSColors.onSurface,
                          ),
                        ),
                        SizedBox(height: DSSpacing.md),
                        Text(
                          'Tap to pick a video\n(max 60 seconds)',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: DSColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: DSColors.green.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: DSIconSize.xxl,
                            color: DSColors.green,
                          ),
                        ),
                        SizedBox(height: DSSpacing.md),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: DSSpacing.md),
                          child: Text(
                            _video!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: DSColors.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(height: DSSpacing.xs),
                        Text(
                          'Tap to change video',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: DSColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. Match winning goal',
                      prefixIcon: Icon(DSIcons.textT),
                    ),
                  ),
                  SizedBox(height: DSSpacing.md),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Tournament, opponent, highlights...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  SizedBox(height: DSSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _sport,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Sport',
                      prefixIcon: Icon(DSIcons.trophy),
                    ),
                    items: AppConstants.sportList
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
                      decoration: InputDecoration(
                        labelText: 'Position',
                        prefixIcon: Icon(DSIcons.sportsRounded),
                      ),
                      items: (AppConstants.positionsBySport[_sport] ?? const [])
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
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
                      decoration: InputDecoration(
                        labelText: 'Age Group',
                        prefixIcon: Icon(Icons.group),
                      ),
                      items: AppConstants.ageGroups
                          .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                          .toList(),
                      onChanged: (v) => setState(() => _ageGroup = v),
                    ),
                    SizedBox(height: DSSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _highlightType,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Highlight Type',
                        prefixIcon: Icon(Icons.videocam),
                      ),
                      items: (AppConstants.highlightTypesBySport[_sport] ?? AppConstants.highlightTypes)
                          .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                          .toList(),
                      onChanged: (v) => setState(() => _highlightType = v),
                    ),
                    SizedBox(height: DSSpacing.md),
                    TextFormField(
                      initialValue: _location,
                      decoration: InputDecoration(
                        labelText: 'Highlight Location (optional)',
                        hintText: 'e.g. Bangalore',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      onChanged: (v) => setState(() => _location = v.trim().isEmpty ? null : v.trim()),
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
                  SectionHeader(text: 'What does this highlight demonstrate?'),
                  SizedBox(height: DSSpacing.xs),
                  Text(
                    'Select the skills, techniques or moments shown in your highlight.',
                    style: TextStyle(
                      fontSize: 13,
                      color: DSColors.onSurfaceVariant,
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
                        Icon(Icons.tag, size: 18, color: DSColors.onSurface),
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
                        color: DSColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: DSSpacing.md),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text('#$tag', style: TextStyle(fontSize: 11)),
                          backgroundColor: DSColors.surfaceContainerHigh,
                          side: BorderSide(color: DSColors.outlineVariant),
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
                color: DSColors.onSurface,
                backgroundColor: DSColors.surfaceContainerHigh,
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
          ],
        ),
      ),
    );
  }
}

class _UploadProgressDialog extends StatelessWidget {
  const _UploadProgressDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(color: DSColors.onSurface, strokeWidth: 3),
          ),
          SizedBox(height: DSSpacing.lg),
          Text(
            'Uploading your highlight...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: DSSpacing.sm),
          Text(
            'This may take a moment depending on video size.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: DSColors.onSurfaceVariant),
          ),
        ],
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
        color: DSColors.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.chip),
        border: Border.all(color: DSColors.onSurface.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: DSColors.onSurface),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: DSColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
