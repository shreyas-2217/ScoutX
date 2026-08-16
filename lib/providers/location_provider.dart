import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  LatLng? _currentLocation;
  String? _currentCity;
  bool _isLoading = false;
  LocationPermissionStatus? _permissionStatus;
  String? _error;

  LatLng? get currentLocation => _currentLocation;
  String? get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  LocationPermissionStatus? get permissionStatus => _permissionStatus;
  String? get error => _error;
  bool get hasLocation => _currentLocation != null;

  /// Try to get current location on app start
  Future<void> initLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _permissionStatus = await _locationService.requestPermission();
      
      if (_permissionStatus == LocationPermissionStatus.granted) {
        _currentLocation = await _locationService.getCurrentPosition();
        if (_currentLocation != null) {
          _currentCity = await _locationService.reverseGeocode(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search for locations
  Future<List<PlaceResult>> searchLocation(String query) async {
    return await _locationService.searchLocation(query);
  }

  /// Set location from a place result
  void setLocation(PlaceResult place) {
    _currentLocation = place.location;
    _currentCity = place.address;
    _error = null;
    notifyListeners();
  }

  /// Set location from coordinates
  Future<void> setCoordinates(double lat, double lng) async {
    _currentLocation = LatLng(lat, lng);
    _currentCity = await _locationService.reverseGeocode(lat, lng);
    notifyListeners();
  }

  /// Clear location
  void clearLocation() {
    _currentLocation = null;
    _currentCity = null;
    notifyListeners();
  }

  /// Calculate distance from current location to a point
  double? distanceTo(double lat, double lng) {
    if (_currentLocation == null) return null;
    return LocationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      lat,
      lng,
    );
  }

  /// Format distance for display
  String formatDistance(double km) => LocationService.formatDistance(km);
  
  /// Get distance label
  String getDistanceLabel(double? km) => LocationService.getDistanceLabel(km);
}
