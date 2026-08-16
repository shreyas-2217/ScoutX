import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../../widgets/location_picker.dart';
import '../shared/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _teamName = TextEditingController();

  String _role = 'player';
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
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _teamName.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == 'player' && _sport == null) {
      _showSnack('Please select your sport.');
      return;
    }
    if ((_role == 'player' || _role == 'coach') && (_city == null || _city!.isEmpty)) {
      _showSnack('Location is required for players and coaches.');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            email: _email.text,
            password: _password.text,
            displayName: _name.text,
            role: _role,
            sport: _sport,
            position: _position,
            teamName: _role == 'coach' ? _teamName.text : null,
            city: _city,
            latitude: _latitude,
            longitude: _longitude,
          );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        final errorMsg = context.read<AuthProvider>().error;
        if (errorMsg != null) {
          _showSnack(errorMsg);
        } else {
          _showSnack('Registration failed. Please try again.');
        }
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
    final error = context.watch<AuthProvider>().error;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(DSIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: DSColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: BrandLogo(
                            markSize: 64,
                            fontSize: 38,
                            animate: false,
                          ),
                        ),
                        SizedBox(height: DSSpacing.md),
                        Text(
                          'Tell us about you',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: DSColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: DSSpacing.xxl),
                        DSCard(
                          padding: EdgeInsets.all(DSSpacing.xl),
                          animate: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'I am a\u2026',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: DSColors.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: DSSpacing.md),
                              _roleSelector(theme),
                              SizedBox(height: DSSpacing.xl),
                              TextFormField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Full name',
                                  prefixIcon: Icon(DSIcons.user),
                                ),
                                validator: (v) => (v == null ||
                                        v.trim().isEmpty)
                                    ? 'Enter your name'
                                    : null,
                              ),
                              SizedBox(height: DSSpacing.md),
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(DSIcons.envelope),
                                ),
                                validator: (v) => (v == null ||
                                        !v.contains('@'))
                                    ? 'Enter a valid email'
                                    : null,
                              ),
                              SizedBox(height: DSSpacing.md),
                              TextFormField(
                                controller: _password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(DSIcons.lock),
                                  helperText: 'At least 6 characters',
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Password must be 6+ characters'
                                    : null,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              if (_role == 'player') ...[
                                SizedBox(height: DSSpacing.xl),
                                _dropdown<String>(
                                  value: _sport,
                                  label: 'Sport',
                                  icon: DSIcons.trophy,
                                  items: AppConstants.sportList,
                                  onChanged: (v) => setState(() {
                                    _sport = v;
                                    _position = null;
                                  }),
                                ),
                                if (_sport != null) ...[
                                  SizedBox(height: DSSpacing.md),
                                  _dropdown<String>(
                                    value: _position,
                                    label: 'Position',
                                    icon: DSIcons.sports_rounded,
                                    items:
                                        AppConstants.positionsBySport[_sport] ??
                                            const [],
                                    onChanged: (v) =>
                                        setState(() => _position = v),
                                  ),
                                ],
                              ],
                              if (_role == 'coach') ...[
                                SizedBox(height: DSSpacing.xl),
                                TextFormField(
                                  controller: _teamName,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    labelText: 'Team / Club name (optional)',
                                    prefixIcon: Icon(DSIcons.shield),
                                  ),
                                ),
                              ],
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
                              SizedBox(height: DSSpacing.xxl),
                              DSButton(
                                label: 'Sign Up',
                                leadingIcon: DSIcons.arrow_forward_rounded,
                                loading: _loading,
                                fullWidth: true,
                                onPressed: _loading ? null : _submit,
                              ),
                              if (error != null) ...[
                                SizedBox(height: DSSpacing.md),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: DSColors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleSelector(ThemeData theme) {
    final roles = [
      ('player', 'Player', DSIcons.trophy,
          'Upload clips & get scouted'),
      ('coach', 'Coach', DSIcons.shield, 'Find players, post trials'),
      ('viewer', 'Viewer', DSIcons.smart_display_rounded, 'Just scroll reels'),
    ];
    return Column(
      children: [
        for (final r in roles)
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
                    Icon(
                      r.$3,
                      color: _role == r.$1
                          ? DSColors.volt
                          : DSColors.onSurfaceVariant,
                    ),
                    SizedBox(width: DSSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.$2,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: DSSpacing.xs),
                          Text(
                            r.$4,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: DSColors.onSurfaceVariant,
                            ),
                          ),
                        ],
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
      ],
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
          .toList(),
      onChanged: onChanged,
    );
  }
}
