import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../cloudinary_config.dart';
import '../../services/database.dart';
import '../../widgets/location_picker.dart';
import '../../widgets/sport_icons.dart';
import 'widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _contactEmail = TextEditingController();
  final _phone = TextEditingController();
  final _teamName = TextEditingController();

  String? _sport;
  String? _position;
  String? _ageGroup;
  String? _city;
  double? _latitude;
  double? _longitude;
  String? _profileImageUrl;
  Uint8List? _pendingImageBytes;
  bool _loading = false;

  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _name.text = widget.profile.displayName;
    _username.text = widget.profile.username ?? '';
    _bio.text = widget.profile.bio ?? '';
    _height.text = widget.profile.heightCm?.toString() ?? '';
    _weight.text = widget.profile.weightKg?.toString() ?? '';
    _contactEmail.text = widget.profile.contactEmail ?? '';
    _phone.text = widget.profile.phone ?? '';
    _teamName.text = widget.profile.teamName ?? '';
    _sport = widget.profile.sport;
    _position = widget.profile.position;
    _ageGroup = widget.profile.ageGroup;
    _city = widget.profile.city;
    _latitude = widget.profile.latitude;
    _longitude = widget.profile.longitude;
    _profileImageUrl = widget.profile.profileImageUrl;

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
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    _height.dispose();
    _weight.dispose();
    _contactEmail.dispose();
    _phone.dispose();
    _teamName.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _pendingImageBytes = bytes;
        _profileImageUrl = null;
      });
    } catch (_) {}
  }

  Future<String?> _uploadImage() async {
    if (_pendingImageBytes == null) return _profileImageUrl;
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return null;
    try {
      final cloudinary = CloudinaryService(scoutxCloudinary);
      final url = await cloudinary.uploadImage(user.uid, _pendingImageBytes!, 'profile.jpg');
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await LocationPicker.show(
      context,
      initialAddress: _city,
      title: 'Select Your Location',
      showVenueField: false,
    );
    if (result != null && mounted) {
      setState(() {
        _city = result.city ?? result.address ?? _city;
        _latitude = result.coordinates?.latitude ?? _latitude;
        _longitude = result.coordinates?.longitude ?? _longitude;
      });
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      _showSnack('Please enter your name.');
      return;
    }
    if (_sport == null) {
      _showSnack('Please select a sport.');
      return;
    }
    if (widget.profile.isPlayer && _position == null) {
      _showSnack('Please select a position.');
      return;
    }
    if (_city == null || _city!.isEmpty) {
      _showSnack('Location is required. Please select your location.');
      return;
    }

    setState(() => _loading = true);

    final imageUrl = await _uploadImage();

    final updates = <String, dynamic>{
      'displayName': _name.text.trim(),
      'username': _username.text.trim().isEmpty ? null : _username.text.trim(),
      'bio': _bio.text.trim(),
      'sport': _sport,
      'position': _position,
      'ageGroup': _ageGroup,
      'city': _city,
      'latitude': _latitude,
      'longitude': _longitude,
    };

    if (imageUrl != null) updates['profileImageUrl'] = imageUrl;

    if (widget.profile.isPlayer) {
      updates['heightCm'] = int.tryParse(_height.text);
      updates['weightKg'] = int.tryParse(_weight.text);
      updates['contactEmail'] = _contactEmail.text.trim().isEmpty ? null : _contactEmail.text.trim();
      updates['phone'] = _phone.text.trim().isEmpty ? null : _phone.text.trim();
    }
    if (widget.profile.isCoach) {
      updates['teamName'] = _teamName.text.trim().isEmpty ? null : _teamName.text.trim();
    }

    if (!mounted) return;
    await context.read<AuthProvider>().updateProfile(updates);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isPlayer = widget.profile.isPlayer;
    final isCoach = widget.profile.isCoach;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DSSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Picture
                  _buildProfilePicture(theme),
                  SizedBox(height: DSSpacing.xl),

                  // Basic Info
                  DSCard(
                    padding: EdgeInsets.all(DSSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(text: 'Basic Information'),
                        SizedBox(height: DSSpacing.md),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            prefixIcon: Icon(DSIcons.user),
                          ),
                        ),
                        SizedBox(height: DSSpacing.md),
                        TextFormField(
                          controller: _username,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.alternate_email, size: 20),
                            helperText: 'Your unique @handle',
                          ),
                        ),
                        SizedBox(height: DSSpacing.md),
                        TextFormField(
                          controller: _bio,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            hintText: 'Tell scouts about yourself...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: DSSpacing.md),

                  // Sport & Position
                  DSCard(
                    padding: EdgeInsets.all(DSSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(text: 'Sport & Position'),
                        SizedBox(height: DSSpacing.md),
                        DropdownButtonFormField<String>(
                          value: _sport,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Sport',
                            prefixIcon: Icon(SportIcons.getSportIcon(_sport)),
                          ),
                          items: AppConstants.sportList
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _sport = v;
                            _position = null;
                          }),
                        ),
                        if (isPlayer && _sport != null) ...[
                          SizedBox(height: DSSpacing.md),
                          DropdownButtonFormField<String>(
                            value: _position,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Position',
                              prefixIcon: Icon(PositionIcons.getPositionIcon(_position)),
                            ),
                            items: (AppConstants.positionsBySport[_sport] ?? [])
                                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (v) => setState(() => _position = v),
                          ),
                        ],
                        SizedBox(height: DSSpacing.md),
                        DropdownButtonFormField<String>(
                          value: _ageGroup,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Age Group',
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                          items: AppConstants.ageGroups
                              .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                              .toList(),
                          onChanged: (v) => setState(() => _ageGroup = v),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: DSSpacing.md),

                  // Location
                  DSCard(
                    padding: EdgeInsets.all(DSSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(text: 'Location'),
                        SizedBox(height: DSSpacing.sm),
                        Text(
                          'Required for players and coaches',
                          style: TextStyle(fontSize: 12, color: DSColors.onSurfaceVariant),
                        ),
                        SizedBox(height: DSSpacing.md),
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
                                  child: Text(
                                    _city!,
                                    style: TextStyle(fontWeight: FontWeight.w600, color: DSColors.volt),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _openLocationPicker,
                                  child: Text('Change'),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          _LocationButton(
                            icon: Icons.my_location_outlined,
                            label: 'Use Current Location',
                            onTap: _openLocationPicker,
                          ),
                          SizedBox(height: DSSpacing.sm),
                          _LocationButton(
                            icon: Icons.search,
                            label: 'Search Location',
                            onTap: _openLocationPicker,
                          ),
                          SizedBox(height: DSSpacing.sm),
                          _LocationButton(
                            icon: Icons.map_outlined,
                            label: 'Choose on Map',
                            onTap: _openLocationPicker,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: DSSpacing.md),

                  // Physical Stats (Player)
                  if (isPlayer) ...[
                    DSCard(
                      padding: EdgeInsets.all(DSSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(text: 'Physical Stats'),
                          SizedBox(height: DSSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _height,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Height (cm)',
                                    prefixIcon: Icon(DSIcons.arrowsVertical),
                                  ),
                                ),
                              ),
                              SizedBox(width: DSSpacing.md),
                              Expanded(
                                child: TextFormField(
                                  controller: _weight,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Weight (kg)',
                                    prefixIcon: Icon(DSIcons.scale),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: DSSpacing.md),
                          SectionHeader(text: 'Contact'),
                          SizedBox(height: DSSpacing.sm),
                          TextFormField(
                            controller: _contactEmail,
                            decoration: InputDecoration(
                              labelText: 'Public contact email',
                              prefixIcon: Icon(DSIcons.envelope),
                            ),
                          ),
                          SizedBox(height: DSSpacing.md),
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Public phone number',
                              prefixIcon: Icon(DSIcons.phone),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: DSSpacing.md),
                  ],

                  // Team (Coach)
                  if (isCoach) ...[
                    DSCard(
                      padding: EdgeInsets.all(DSSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(text: 'Team'),
                          SizedBox(height: DSSpacing.sm),
                          TextFormField(
                            controller: _teamName,
                            decoration: InputDecoration(
                              labelText: 'Team / Club name',
                              prefixIcon: Icon(DSIcons.shield),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: DSSpacing.md),
                  ],

                  // Save button
                  DSButton(
                    label: _loading ? 'Saving...' : 'Save Changes',
                    leadingIcon: _loading ? null : DSIcons.floppyDisk,
                    loading: _loading,
                    fullWidth: true,
                    onPressed: _loading ? null : _save,
                  ),
                  SizedBox(height: DSSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(ThemeData theme) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: DSColors.surfaceContainerHighest,
              backgroundImage: _pendingImageBytes != null
                  ? MemoryImage(_pendingImageBytes!)
                  : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? NetworkImage(_profileImageUrl!)
                      : null) as ImageProvider?,
              child: (_pendingImageBytes == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                  ? Icon(SportIcons.getSportIcon(_sport), size: 40, color: DSColors.onSurfaceVariant)
                  : null,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: DSColors.volt,
                  shape: BoxShape.circle,
                  boxShadow: DSElevation.cardShadow,
                ),
                child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LocationButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(DSRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 20, color: DSColors.volt),
              SizedBox(width: DSSpacing.sm),
              Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
              Spacer(),
              Icon(Icons.chevron_right, size: 20, color: DSColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
