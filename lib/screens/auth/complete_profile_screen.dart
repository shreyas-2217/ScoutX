import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/database.dart';
import '../../widgets/location_picker.dart';

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
      auth.setProfileDirectly(profile);
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        color: DSColors.onSurfaceDisabled,
      ),
      filled: true,
      fillColor: DSColors.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSRadius.input),
        borderSide: const BorderSide(color: DSColors.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSRadius.input),
        borderSide: const BorderSide(color: DSColors.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSRadius.input),
        borderSide: const BorderSide(color: DSColors.onSurface, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.surface,
      appBar: AppBar(
        backgroundColor: DSColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(DSIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SCOUTX',
          style: GoogleFonts.barlowCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.32,
            color: DSColors.onSurface,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: DSSpacing.md),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DSColors.surfaceContainer,
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(color: DSColors.outlineVariant),
            ),
            child: Icon(
              DSIcons.user,
              size: 18,
              color: DSColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.lg,
            ),
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
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        minHeight: 4,
                        backgroundColor: DSColors.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(DSColors.onSurface),
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),

                    // Heading
                    Text(
                      'COMPLETE YOUR PROFILE',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.32,
                        color: DSColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    Text(
                      'Set up your credentials to begin scouting or getting scouted',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: DSColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),

                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: DSColors.surfaceContainer,
                              shape: BoxShape.circle,
                              border: Border.all(color: DSColors.outlineVariant),
                            ),
                            child: Icon(
                              DSIcons.user,
                              size: 36,
                              color: DSColors.onSurfaceDisabled,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: DSColors.onSurface,
                                shape: BoxShape.circle,
                                border: Border.all(color: DSColors.surface, width: 2),
                              ),
                              child: Icon(
                                DSIcons.add,
                                size: 14,
                                color: DSColors.surface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),

                    // Display Name
                    Text(
                      'DISPLAY NAME',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: DSColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      style: GoogleFonts.inter(fontSize: 16, color: DSColors.onSurface),
                      decoration: _inputDecoration('e.g. John Doe'),
                    ),
                    const SizedBox(height: DSSpacing.xl),

                    // Account Role
                    Text(
                      'ACCOUNT ROLE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: DSColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    Row(
                      children: [
                        Expanded(child: _roleButton('PLAYER', 'player')),
                        const SizedBox(width: DSSpacing.sm),
                        Expanded(child: _roleButton('COACH', 'coach')),
                        const SizedBox(width: DSSpacing.sm),
                        Expanded(child: _roleButton('VIEWER', 'viewer')),
                      ],
                    ),
                    const SizedBox(height: DSSpacing.xl),

                    // Sport & Position for Players
                    if (_role == 'player') ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              value: _sport,
                              label: 'PRIMARY SPORT',
                              items: AppConstants.sportList,
                              onChanged: (v) => setState(() {
                                _sport = v;
                                _position = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: DSSpacing.sm),
                          Expanded(
                            child: _buildDropdown<String>(
                              value: _position,
                              label: 'POSITION',
                              items: AppConstants.positionsBySport[_sport] ?? const [],
                              onChanged: (v) => setState(() => _position = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DSSpacing.md),
                    ],

                    // Location for Player/Coach
                    if (_role == 'player' || _role == 'coach') ...[
                      Text(
                        'BASE LOCATION',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: DSColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      if (_city != null && _city!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(DSSpacing.md),
                          decoration: BoxDecoration(
                            color: DSColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(DSRadius.input),
                            border: Border.all(color: DSColors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              const Icon(DSIcons.mapPin, size: 18, color: DSColors.onSurfaceVariant),
                              const SizedBox(width: DSSpacing.sm),
                              Expanded(
                                child: Text(
                                  _city!,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: DSColors.onSurface,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _openLocationPicker,
                                child: Text(
                                  'Change',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: DSColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _openLocationPicker,
                          child: Container(
                            padding: const EdgeInsets.all(DSSpacing.md),
                            decoration: BoxDecoration(
                              color: DSColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(DSRadius.input),
                              border: Border.all(color: DSColors.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                const Icon(DSIcons.mapPin, size: 18, color: DSColors.onSurfaceVariant),
                                const SizedBox(width: DSSpacing.sm),
                                Text(
                                  'City, State, Country',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: DSColors.onSurfaceDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: DSSpacing.xl),

                    // Get Started button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _loading ? null : _create,
                        style: FilledButton.styleFrom(
                          backgroundColor: DSColors.onSurface,
                          foregroundColor: DSColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DSRadius.button),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: DSColors.surface,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'GET STARTED',
                                    style: GoogleFonts.barlowCondensed(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.32,
                                    ),
                                  ),
                                  const SizedBox(width: DSSpacing.sm),
                                  const Icon(DSIcons.arrowForwardRounded, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String label, String value) {
    final isSelected = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: AnimatedContainer(
        duration: DSMotion.fast,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? DSColors.onSurface : DSColors.surfaceContainer,
          borderRadius: BorderRadius.circular(DSRadius.button),
          border: Border.all(
            color: isSelected ? DSColors.onSurface : DSColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.barlowCondensed(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.32,
              color: isSelected ? DSColors.surface : DSColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: DSColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
          decoration: BoxDecoration(
            color: DSColors.surfaceContainer,
            borderRadius: BorderRadius.circular(DSRadius.input),
            border: Border.all(color: DSColors.outlineVariant, width: 1),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: DSColors.surface,
            style: GoogleFonts.inter(fontSize: 16, color: DSColors.onSurface),
            items: items
                .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
