import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/trial.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../../services/location_service.dart';
import '../../widgets/location_picker.dart';
import '../shared/widgets.dart'
    show DSColors, DSSpacing, DSIconSize, DSRadius, DSMotion, DSElevation, DSCard, EmptyState, DSButton, DSButtonVariant, SectionHeader, AnimatedPage;

class PostTrialScreen extends StatefulWidget {
  const PostTrialScreen({super.key});

  @override
  State<PostTrialScreen> createState() => _PostTrialScreenState();
}

class _PostTrialScreenState extends State<PostTrialScreen>
    with SingleTickerProviderStateMixin {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _date = TextEditingController();

  String? _sport;
  String? _position;
  String? _skillLevel;
  bool _loading = false;

  // Location state
  LatLng? _trialCoordinates;
  String? _trialVenue;
  String? _trialAddress;

  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.normal,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: DSMotion.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _date.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await LocationPicker.show(
      context,
      initialVenue: _trialVenue,
      initialAddress: _trialAddress,
      title: 'Trial Location',
    );

    if (result != null) {
      setState(() {
        _trialCoordinates = result.coordinates;
        _trialVenue = result.venue;
        _trialAddress = result.address;
      });
    }
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final db = context.read<Database>();
    final user = auth.user;
    final profile = auth.profile;
    if (user == null || profile == null) return;
    if (_title.text.trim().isEmpty) {
      _snack('Give the trial a title.');
      return;
    }
    if (_sport == null || _position == null || _skillLevel == null) {
      _snack('Select sport, position and skill level.');
      return;
    }
    setState(() => _loading = true);
    try {
      // Build location string from venue/address
      String? locationStr;
      if (_trialVenue != null && _trialVenue!.isNotEmpty) {
        locationStr = _trialVenue;
        if (_trialAddress != null && _trialAddress!.isNotEmpty) {
          locationStr = '$_trialVenue, $_trialAddress';
        }
      } else if (_trialAddress != null && _trialAddress!.isNotEmpty) {
        locationStr = _trialAddress;
      }

      final trial = Trial(
        id: '',
        coachId: user.uid,
        coachName: profile.displayName,
        teamName: profile.teamName ?? 'My team',
        title: _title.text.trim(),
        sport: _sport!,
        position: _position!,
        skillLevel: _skillLevel!,
        location: locationStr,
        date: _date.text.trim().isEmpty ? null : _date.text.trim(),
        description: _description.text.trim(),
        createdAt: DateTime.now(),
        latitude: _trialCoordinates?.latitude,
        longitude: _trialCoordinates?.longitude,
        venue: _trialVenue,
        address: _trialAddress,
      );
      await db.addTrial(trial);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      _snack('Failed to post trial: $e');
      if (mounted) setState(() => _loading = false);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Trial')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnim.value,
            child: Transform.translate(
              offset: _slideAnim.value * 30,
              child: child,
            ),
          );
        },
        child: AnimatedPage(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DSCard(
                  padding: EdgeInsets.all(DSSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(text: 'Basic Info'),
                      SizedBox(height: DSSpacing.md),
                      TextFormField(
                        controller: _title,
                        decoration: InputDecoration(
                          labelText: 'Trial title',
                          hintText: 'e.g. U17 Central Midfielder trials',
                          prefixIcon: Icon(DSIcons.textT),
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
                        }),
                      ),
                      if (_sport != null) ...[
                        SizedBox(height: DSSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _position,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Position wanted',
                            prefixIcon: Icon(DSIcons.sports_rounded),
                          ),
                          items: (AppConstants.positionsBySport[_sport] ?? const [])
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (v) => setState(() => _position = v),
                        ),
                      ],
                      SizedBox(height: DSSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: _skillLevel,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Skill level',
                          prefixIcon: Icon(DSIcons.trendUp),
                        ),
                        items: AppConstants.skillLevels
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _skillLevel = v),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: DSSpacing.md),

                // Location section
                DSCard(
                  padding: EdgeInsets.all(DSSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(text: 'Trial Location'),
                      SizedBox(height: DSSpacing.md),

                      // Location picker button
                      Material(
                        color: DSColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _pickLocation,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: DSColors.volt.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _trialCoordinates != null
                                        ? Icons.check_circle
                                        : Icons.location_on_outlined,
                                    color: DSColors.volt,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _trialCoordinates != null
                                            ? (_trialVenue ?? _trialAddress ?? 'Location selected')
                                            : 'Set trial location',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _trialCoordinates != null
                                              ? DSColors.volt
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      if (_trialCoordinates != null && _trialAddress != null)
                                        Text(
                                          _trialAddress!,
                                          style: TextStyle(fontSize: 12, color: DSColors.onSurfaceVariant),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      else
                                        Text(
                                          'GPS, search, or enter coordinates',
                                          style: TextStyle(fontSize: 12, color: DSColors.onSurfaceVariant),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: DSColors.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (_trialCoordinates != null) ...[
                        SizedBox(height: DSSpacing.md),
                        // Location preview
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DSColors.volt.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: DSColors.volt),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_trialCoordinates!.latitude.toStringAsFixed(4)}°N, ${_trialCoordinates!.longitude.toStringAsFixed(4)}°E',
                                  style: TextStyle(fontSize: 12, color: DSColors.volt),
                                ),
                              ),
                              TextButton(
                                onPressed: _pickLocation,
                                child: Text('Change', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: DSSpacing.md),

                // Details section
                DSCard(
                  padding: EdgeInsets.all(DSSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(text: 'Details'),
                      SizedBox(height: DSSpacing.md),
                      TextFormField(
                        controller: _date,
                        decoration: InputDecoration(
                          labelText: 'Date (optional)',
                          hintText: 'e.g. 20 Sep 2026',
                          prefixIcon: Icon(DSIcons.calendar),
                        ),
                      ),
                      SizedBox(height: DSSpacing.md),
                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Trial details',
                          hintText: 'What you\'re looking for, trial format, contact…',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: DSSpacing.xl),
                DSButton(
                  label: _loading ? 'Posting…' : 'Post Trial',
                  leadingIcon: DSIcons.megaphone,
                  loading: _loading,
                  fullWidth: true,
                  onPressed: _loading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
