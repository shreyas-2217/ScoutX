import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../../theme.dart';
import '../../widgets/location_picker.dart';
import '../shared/widgets.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with SingleTickerProviderStateMixin {
  final _name = TextEditingController();
  String _role = 'viewer';
  String? _sport;
  String? _position;
  String? _city;
  double? _latitude;
  double? _longitude;
  bool _loading = false;

  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.slow,
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
    _name.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter your name.')));
      return;
    }
    if ((_role == 'player' || _role == 'coach') && (_city == null || _city!.isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Location is required for players and coaches.')));
      return;
    }
    setState(() => _loading = true);
    try {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        role: _role,
        displayName: _name.text.trim(),
        sport: _sport,
        position: _position,
        city: _city,
        latitude: _latitude,
        longitude: _longitude,
        createdAt: DateTime.now(),
      );
      await context.read<Database>().createUserProfile(profile);
      await auth.refreshProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await LocationPicker.show(
      context,
      title: 'Select Your Location',
      showVenueField: false,
    );
    if (result != null && mounted) {
      setState(() {
        _city = result.city ?? result.address;
        _latitude = result.coordinates?.latitude;
        _longitude = result.coordinates?.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: EdgeInsets.all(DSSpacing.xl),
        child: AnimatedBuilder(
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(DSIcons.user),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                SizedBox(height: DSSpacing.xl),
                Text(
                  'How will you use ScoutX?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: DSColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: DSSpacing.md),
                for (final r in [
                  ('player', 'Player', DSIcons.trophy),
                  ('coach', 'Coach', DSIcons.shield),
                  ('viewer', 'Viewer', DSIcons.smart_display_rounded),
                ])
                  Padding(
                    padding: EdgeInsets.only(bottom: DSSpacing.sm),
                    child: InkWell(
                      onTap: () => setState(() => _role = r.$1),
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      child: AnimatedContainer(
                        duration: DSMotion.fast,
                        padding: EdgeInsets.all(DSSpacing.md),
                        decoration: BoxDecoration(
                          color: _role == r.$1
                              ? DSColors.volt.withValues(alpha: 0.08)
                              : DSColors.surface,
                          borderRadius: BorderRadius.circular(DSRadius.md),
                          border: Border.all(
                            color: _role == r.$1
                                ? DSColors.volt
                                : DSColors.outline,
                            width: _role == r.$1 ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(r.$3, color: DSColors.volt),
                            SizedBox(width: DSSpacing.md),
                            Expanded(
                              child: Text(
                                r.$2,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(
                              _role == r.$1
                                  ? DSIcons.radio_button_checked_rounded
                                  : DSIcons.radio_button_unchecked_rounded,
                              size: DSIconSize.md,
                              color: _role == r.$1
                                  ? DSColors.volt
                                  : DSColors.onSurfaceDisabled,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Sport & Position for Players
                if (_role == 'player') ...[
                  SizedBox(height: DSSpacing.xl),
                  DropdownButtonFormField<String>(
                    value: _sport,
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
                      value: _position,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Position',
                        prefixIcon: Icon(DSIcons.sports_rounded),
                      ),
                      items: (AppConstants.positionsBySport[_sport] ?? [])
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => setState(() => _position = v),
                    ),
                  ],
                ],

                // Location for Player/Coach
                if (_role == 'player' || _role == 'coach') ...[
                  SizedBox(height: DSSpacing.xl),
                  Text(
                    'Location',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: DSColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: DSSpacing.sm),
                  if (_city != null && _city!.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(DSSpacing.md),
                      decoration: BoxDecoration(
                        color: DSColors.volt.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(DSRadius.md),
                        border: Border.all(color: DSColors.volt.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: DSColors.volt, size: 20),
                          SizedBox(width: DSSpacing.sm),
                          Expanded(
                            child: Text(_city!, style: TextStyle(fontWeight: FontWeight.w600, color: DSColors.volt)),
                          ),
                          TextButton(
                            onPressed: _openLocationPicker,
                            child: Text('Change'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    InkWell(
                      onTap: _openLocationPicker,
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      child: Container(
                        padding: EdgeInsets.all(DSSpacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(color: DSColors.outline),
                          borderRadius: BorderRadius.circular(DSRadius.md),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_location_alt_outlined, color: DSColors.volt),
                            SizedBox(width: DSSpacing.sm),
                            Text('Select your location', style: TextStyle(color: DSColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],

                SizedBox(height: DSSpacing.xl),
                DSButton(
                  label: 'Continue',
                  leadingIcon: DSIcons.arrow_forward_rounded,
                  loading: _loading,
                  fullWidth: true,
                  onPressed: _loading ? null : _create,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
