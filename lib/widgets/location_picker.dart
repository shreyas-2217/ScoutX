import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoutx/design_system.dart';
import '../services/location_service.dart';
import '../providers/location_provider.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class LocationPickerResult {
  final LatLng? coordinates;
  final String? venue;
  final String? address;
  final String? city;
  final LocationSource source;

  const LocationPickerResult({
    this.coordinates,
    this.venue,
    this.address,
    this.city,
    this.source = LocationSource.searched,
  });
}

enum LocationSource { current, searched, map }

class LocationPicker extends StatefulWidget {
  final String? initialVenue;
  final String? initialAddress;
  final String title;
  final bool showVenueField;

  const LocationPicker({
    super.key,
    this.initialVenue,
    this.initialAddress,
    this.title = 'Select Location',
    this.showVenueField = true,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();

  /// Show location picker as a bottom sheet
  static Future<LocationPickerResult?> show(
    BuildContext context, {
    String? initialVenue,
    String? initialAddress,
    String title = 'Select Location',
    bool showVenueField = true,
  }) {
    return showModalBottomSheet<LocationPickerResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => LocationPicker(
        initialVenue: initialVenue,
        initialAddress: initialAddress,
        title: title,
        showVenueField: showVenueField,
      ),
    );
  }
}

class _LocationPickerState extends State<LocationPicker> {
  final _venueController = TextEditingController();
  final _searchController = TextEditingController();
  List<PlaceResult> _searchResults = [];
  bool _isSearching = false;
  PlaceResult? _selectedPlace;
  LatLng? _selectedCoords;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    if (widget.initialVenue != null) _venueController.text = widget.initialVenue!;
    if (widget.initialAddress != null) _selectedAddress = widget.initialAddress;
  }

  @override
  void dispose() {
    _venueController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isSearching = true;
      _selectedAddress = 'Getting location...';
    });

    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.initLocation();

      if (locationProvider.currentLocation != null && mounted) {
        setState(() {
          _selectedCoords = locationProvider.currentLocation;
          _selectedAddress = locationProvider.currentCity ?? 'Current Location';
          _selectedPlace = null;
          _isSearching = false;
        });
      } else if (mounted) {
        // Fallback: try direct browser geolocation
        await _useCurrentLocationWebFallback();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _selectedAddress = null;
        });
      }
    }
  }

  Future<void> _useCurrentLocationWebFallback() async {
    try {
      final geo = html.window.navigator.geolocation;
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 15),
      );
      final lat = pos.coords!.latitude!.toDouble();
      final lng = pos.coords!.longitude!.toDouble();
      final ls = LocationService();
      final address = await ls.reverseGeocode(lat, lng);
      if (mounted) {
        setState(() {
          _selectedCoords = LatLng(lat, lng);
          _selectedAddress = address;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _selectedAddress = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location. Please search manually.')),
        );
      }
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final ls = LocationService();
      final results = await ls.searchLocation(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _selectPlace(PlaceResult place) {
    setState(() {
      _selectedPlace = place;
      _selectedCoords = place.location;
      _selectedAddress = place.address;
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _confirm() {
    final result = LocationPickerResult(
      coordinates: _selectedCoords,
      venue: _venueController.text.trim().isEmpty ? null : _venueController.text.trim(),
      address: _selectedAddress,
      city: _selectedAddress,
      source: _selectedPlace != null ? LocationSource.searched : LocationSource.current,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DSColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          
          // Use Current Location button
          _LocationOption(
            icon: Icons.my_location_outlined,
            label: 'Use Current Location',
            subtitle: 'Get your current GPS location',
            onTap: _isSearching ? null : _useCurrentLocation,
            isLoading: _isSearching && _selectedCoords == null,
          ),
          const SizedBox(height: 12),
          
          // Search Location
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search city or address...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, size: 18),
                            tooltip: 'Search',
                            onPressed: _searchLocation,
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          ),
                        ],
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _searchLocation(),
              onChanged: (v) => setState(() {}),
            ),
          ),
          
          // Search results
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DSColors.outlineVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: DSColors.outlineVariant.withValues(alpha: 0.5)),
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  final displayName = place.name.length > 40
                      ? '${place.name.substring(0, 37)}...'
                      : place.name;
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, size: 20, color: DSColors.onSurface),
                    title: Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text(place.address, style: TextStyle(fontSize: 12, color: DSColors.onSurfaceVariant)),
                    onTap: () => _selectPlace(place),
                  );
                },
              ),
            ),
          ],
          
          // Selected location display
          if (_selectedCoords != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DSColors.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DSColors.onSurface.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: DSColors.onSurface, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAddress ?? 'Location selected',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: DSColors.onSurface,
                          ),
                        ),
                        if (_selectedCoords != null)
                          Text(
                            '${_selectedCoords!.latitude.toStringAsFixed(4)}°N, ${_selectedCoords!.longitude.toStringAsFixed(4)}°E',
                            style: TextStyle(fontSize: 11, color: DSColors.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Venue field
          if (widget.showVenueField) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue name (optional)',
                hintText: 'e.g. Bangalore Football Arena',
                prefixIcon: Icon(Icons.store_outlined, size: 20),
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _selectedCoords != null ? _confirm : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: DSColors.onSurface,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: DSColors.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm Location'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const _LocationOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DSColors.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: DSColors.onSurface),
                      )
                    : Icon(icon, color: DSColors.onSurface, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
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
    );
  }
}
